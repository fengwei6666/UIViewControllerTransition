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

// 自定义转场(默认从底部向上弹出)
- (void)lblDefinePresentViewController:(UIViewController *)viewController;

- (void)lblDefinePresentViewController:(UIViewController *)viewController formDirection:(TranslateDirection)direction;

- (void)lblDefinePresentViewController:(UIViewController *)viewController
                         formDirection:(TranslateDirection)direction
                               animate:(BOOL)animate
                            completion:(void(^)(void))completion;

@end
