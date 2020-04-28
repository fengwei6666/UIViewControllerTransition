//
//  UIViewController+LBLDefinePresentViewController.h
//  testTransition
//
//  Created by 君若见故 on 2018/7/13.
//  Copyright © 2018年 君若见故. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBLTrasitionViewController.h"

@interface UIViewController (LBLDefinePresentViewController)

// 自定义转场(默认从左至右)
- (void)lblDefinePresentViewController:(UIViewController *)viewController;

- (void)lblDefinePresentViewController:(UIViewController *)viewController formDirection:(TransitionDirection)direction;

- (void)lblDefinePresentViewController:(UIViewController *)viewController animate:(BOOL)animate
                         formDirection:(TransitionDirection)direction;

// 添加返回手势
- (void)addBackGesture;
// 移除返回手势
- (void)removeBackGesture;

@end
