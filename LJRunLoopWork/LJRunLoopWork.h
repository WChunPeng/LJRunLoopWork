//
//  LJRunLoopWork.h
//  LJRunLoopWork
//
//  Created by LJ on 2017/2/10.
//  Copyright © 2017年 LJ. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  runloop执行的block类型
 */
typedef BOOL(^LJRunLoopWorkUnit)(void);

@interface LJRunLoopWork : NSObject

/*!
 队列任务的最大数，超过最大数后，移除最前面一个（非线程安全，默认30）
 */
@property (nonatomic, assign) NSUInteger maximumQueueLength;

/**
 *  单例
 *
 *  @return  单例对象
 *
 *  @discussion     改runloop使用单例进行管理和操作
 */
+ (instancetype)sharedRunLoopWorkDistribution;


/**
 *  添加runloop将要执行的block
 *
 *  @param  unit    block块
 *  @param  key    对应的key，暂时没进行操作，留待扩展
 *
 *  @discussion     添加runloop执行的代码块，该代码块与最大队列数相关即与maximumQueueLength相关
 */
- (void)addTask:(LJRunLoopWorkUnit)unit withKey:(id)key;

/**
 *  移除所有runloop将要执行的任务
 *
 *  @discussion     移除所有的runloop运行任务
 */
- (void)removeAllTasks;

@end
