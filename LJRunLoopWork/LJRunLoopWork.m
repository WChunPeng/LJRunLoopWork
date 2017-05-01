//
//  LJRunLoopWork.m
//  LJRunLoopWork
//
//  Created by LJ on 2017/2/10.
//  Copyright © 2017年 LJ. All rights reserved.
//

#import "LJRunLoopWork.h"

//DEBUG模式，暂时没做
#define LJRunLoopWork_DEBUG 1

@interface LJRunLoopWork ()

/*!
 用于存放runloop执行的block
 */
@property (nonatomic, strong) NSMutableArray *tasks;

/*!
 用于存放runloop执行的block所对应的key
 */
@property (nonatomic, strong) NSMutableArray *tasksKeys;

////定时器相关，可以不用
////定时器调用间隔，直接设置就行，不用再管定时器（默认0.1）
//@property (nonatomic, assign) NSTimeInterval timeInterval;
////开启定时器
//- (void)startTimer;
////关闭定时器
//- (void)stopTimer;

//定时器，定时器可以不用写，这个定时器不写，图片的加载也是正常的
//@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LJRunLoopWork


- (void)removeAllTasks {
    [self.tasks removeAllObjects];
    [self.tasksKeys removeAllObjects];
}
- (void)addTask:(LJRunLoopWorkUnit)unit withKey:(id)key {
    [self.tasks addObject:unit];
    [self.tasksKeys addObject:key];
    if (self.tasks.count > self.maximumQueueLength) {
        [self.tasks removeObjectAtIndex:0];
        [self.tasksKeys removeObjectAtIndex:0];
    }
}

- (instancetype)init {
    if ((self = [super init])) {
        _maximumQueueLength = 30;
        _tasks = [NSMutableArray array];
        _tasksKeys = [NSMutableArray array];
    }
    return self;
}
//- (void)startTimer {
//    if (_timer == nil) {
//        _timeInterval = _timeInterval == 0.0 ? 0.1 : _timeInterval;
//        _timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(timerFiredMethod:) userInfo:nil repeats:YES];
//    }
//}
//- (void)stopTimer {
//    [_timer invalidate];
//    _timer = nil;
//}
//- (void)setTimeInterval:(NSTimeInterval)timeInterval {
//    if (_timeInterval != timeInterval && _timer != nil && timeInterval > 0.0) {
//        _timeInterval = timeInterval;
//        //重启定时器
//        [self stopTimer];
//        [self startTimer];
//    }
//}
//- (void)timerFiredMethod:(NSTimer *)timer {
//    //We do nothing here
//}

- (void)setMaximumQueueLength:(NSUInteger)maximumQueueLength {
    if (_maximumQueueLength > maximumQueueLength && _tasks.count > maximumQueueLength) {
        [_tasks removeObjectsInRange:NSMakeRange(0, _tasks.count - maximumQueueLength)];
        [_tasksKeys removeObjectsInRange:NSMakeRange(0, _tasks.count - maximumQueueLength)];
    }
    _maximumQueueLength = maximumQueueLength;
}

+ (instancetype)sharedRunLoopWorkDistribution {
    static LJRunLoopWork *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        //单例
        singleton = [[LJRunLoopWork alloc] init];
        //注册对runloop的观察
        [self registerRunLoopWorkDistributionAsMainRunloopObserver:singleton];
    });
    return singleton;
}

+ (void)registerRunLoopWorkDistributionAsMainRunloopObserver:(LJRunLoopWork *)runLoopWork {
    static CFRunLoopObserverRef defaultModeObserver;
    registerObserver(kCFRunLoopBeforeWaiting, defaultModeObserver, NSIntegerMax - 999, kCFRunLoopDefaultMode, (__bridge void *)runLoopWork, &defaultModeRunLoopWorkCallback);
}

static void registerObserver(CFOptionFlags activities, CFRunLoopObserverRef observer, CFIndex order, CFStringRef mode, void *info, CFRunLoopObserverCallBack callback) {
    //获取runloop，当前runloop，在这里当前runloop 就是mainRunLoop
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    //创建上下文
    CFRunLoopObserverContext context = {
        0,
        info,//info就是self，因为是c代码，所以桥接成void * 类似id
        &CFRetain,
        &CFRelease,
        NULL
    };
    //创建观察者
    observer = CFRunLoopObserverCreate(     NULL,
                                       activities,
                                       YES,
                                       order,
                                       callback,
                                       &context);
    CFRunLoopAddObserver(runLoop, observer, mode);
    CFRelease(observer);
}

//最终runloop执行的函数
static void runLoopWorkCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    LJRunLoopWork *runLoopWork = (__bridge LJRunLoopWork *)info;
    if (runLoopWork.tasks.count == 0) {
        return;
    }
    BOOL result = NO;
    while (result == NO && runLoopWork.tasks.count) {
        LJRunLoopWorkUnit unit  = runLoopWork.tasks.firstObject;
        result = unit();
        [runLoopWork.tasks removeObjectAtIndex:0];
        [runLoopWork.tasksKeys removeObjectAtIndex:0];
    }
}

static void defaultModeRunLoopWorkCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    runLoopWorkCallback(observer, activity, info);
}

@end
