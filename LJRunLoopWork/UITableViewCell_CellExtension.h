//
//  UITableViewCell_CellExtension.h
//  LJRunLoopWork
//
//  Created by LJ on 2017/2/10.
//  Copyright © 2017年 LJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (CellExtension)

//当前cell所对应的IndexPath
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@end
