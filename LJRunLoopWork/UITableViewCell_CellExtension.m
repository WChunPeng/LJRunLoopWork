//
//  UITableViewCell_CellExtension.m
//  LJRunLoopWork
//
//  Created by LJ on 2017/2/10.
//  Copyright © 2017年 LJ. All rights reserved.
//

#import "UITableViewCell_CellExtension.h"
#import <objc/runtime.h>

@implementation UITableViewCell (CellExtension)

- (NSIndexPath *)currentIndexPath {
    NSIndexPath *indexPath = objc_getAssociatedObject(self, @selector(currentIndexPath));
    return indexPath;
}

- (void)setCurrentIndexPath:(NSIndexPath *)currentIndexPath {
    objc_setAssociatedObject(self, @selector(currentIndexPath), currentIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
