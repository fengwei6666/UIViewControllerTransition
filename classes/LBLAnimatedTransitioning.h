//
//  LBLAnimatedTransitioning.h
//  testTransition
//
//  Created by 君若见故 on 2018/7/13.
//  Copyright © 2018年 君若见故. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TransitionDirection) {
    TransitionDirectionFromLeft,
    TransitionDirectionFromRight,
    TransitionDirectionFromTop,
    TransitionDirectionFromBottom,
    TransitionDirectionCenter,
};

@interface LBLAnimatedTransitioning : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic) TransitionDirection transitionDirection;

/*
 获取转场双方控制器,来判断是present ？ 还是 dismiss ?
 */
@property (nonatomic, strong) UIViewController *presentingViewController;
@property (nonatomic, strong) UIViewController *presentedViewController;

@end
