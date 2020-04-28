//
//  LBLAnimatedTransitioning.m
//  testTransition
//
//  Created by 君若见故 on 2018/7/13.
//  Copyright © 2018年 君若见故. All rights reserved.
//

#import "LBLAnimatedTransitioning.h"

@implementation LBLAnimatedTransitioning

#pragma mark - UIViewControllerAnimatedTransitioning
// 动画时长
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    return [transitionContext isAnimated] ? 0.25 : 0;
}

// 动画效果的实现
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    __unused UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    
    // 获取源控制器、目标控制器 的View，但是注意二者在开始动画，消失动画，身份是不一样的,取反。
    // 也可以直接通过上面获取控制器获取，比如：toViewController.view
    // For a Presentation:
    //      fromView = The presenting view.
    //      toView   = The presented view.
    // For a Dismissal:
    //      fromView = The presented view.
    //      toView   = The presenting view.
    // 控制器和上述类同。
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [containerView addSubview:toView];  //必须添加到动画容器View上。
    // 判断是present 还是 dismiss
    BOOL isPresenting = (fromViewController == self.presentingViewController);
    
    // 动画实现
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    CGRect containerRect = [transitionContext containerView].bounds;
    CGSize size = isPresenting ? toViewController.preferredContentSize : fromViewController.preferredContentSize;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = containerRect.size;
    }
    
    CGRect fromRect = CGRectMake(0, 0, size.width, size.height);
    CGRect toRect = fromRect;
    switch (self.transitionDirection) {
        case TransitionDirectionFromTop:
            fromRect = CGRectMake(CGRectGetWidth(containerRect)/2 - size.width/2, -size.height, size.width, size.height);
            toRect = CGRectMake(CGRectGetWidth(containerRect)/2 - size.width/2, 0, size.width, size.height);
            break;
        case TransitionDirectionFromLeft:
            fromRect = CGRectMake(-size.width, CGRectGetHeight(containerRect)/2 - size.height/2, size.width, size.height);
            toRect = CGRectMake(0, CGRectGetHeight(containerRect)/2 - size.height/2, size.width, size.height);
            break;
        case TransitionDirectionFromRight:
            fromRect = CGRectMake(size.width, CGRectGetHeight(containerRect)/2 - size.height/2, size.width, size.height);
            toRect = CGRectMake(CGRectGetWidth(containerRect) - size.width, CGRectGetHeight(containerRect)/2 - size.height/2, size.width, size.height);
            break;
        case TransitionDirectionCenter:
            fromRect = CGRectMake(CGRectGetWidth(containerRect)/2 - size.width/2, CGRectGetHeight(containerRect), size.width, size.height);
            toRect = CGRectMake(CGRectGetWidth(containerRect)/2 - size.width/2, CGRectGetHeight(containerRect)/2 - size.height/2, size.width, size.height);
            break;
        case TransitionDirectionFromBottom:
        default:
            fromRect = CGRectMake(CGRectGetWidth(containerRect)/2 - size.width/2, CGRectGetHeight(containerRect), size.width, size.height);
            toRect = CGRectMake(CGRectGetWidth(containerRect)/2 - size.width/2, CGRectGetHeight(containerRect) - size.height, size.width, size.height);
            break;
    }

    if (isPresenting) {
        toView.frame = fromRect;
    } else {
        toView.frame = toRect;
    }
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (isPresenting) {
            toView.frame = toRect;
        } else {
            fromView.frame = fromRect;
        }
    } completion:^(BOOL finished) {
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancelled];
    }];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    // 动画结束...
}

@end
