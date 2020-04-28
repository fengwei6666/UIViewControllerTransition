//
//  UIViewController+LBLDefinePresentViewController.m
//  testTransition
//
//  Created by 君若见故 on 2018/7/13.
//  Copyright © 2018年 君若见故. All rights reserved.
//

#import "UIViewController+LBLDefinePresentViewController.h"
#import <objc/runtime.h>

@implementation UIViewController (LBLDefinePresentViewController)

#pragma mark - lifeCycle
#pragma mark - public
- (void)lblDefinePresentViewController:(UIViewController *)viewController {
    [self lblDefinePresentViewController:viewController formDirection:(TranslateDirectionBottomToTop)];
}

- (void)lblDefinePresentViewController:(UIViewController *)viewController formDirection:(TranslateDirection)direction
{
    [self lblDefinePresentViewController:viewController formDirection:direction animate:YES completion:NULL];
}

- (void)lblDefinePresentViewController:(UIViewController *)viewController formDirection:(TranslateDirection)direction animate:(BOOL)animate completion:(void (^)(void))completion
{
    LBLTrasitionViewController *controller = [[LBLTrasitionViewController alloc] initWithPresentedViewController:viewController presentingViewController:self];
    viewController.transitioningDelegate = controller;
    TranslateTransition *translateAnimate = [[TranslateTransition alloc] init];
    translateAnimate.showDirection = direction;
    
    switch (direction) {
        case TranslateDirectionLeftToRight:
        {
            translateAnimate.hideDirection = TranslateDirectionRightToLeft;
            translateAnimate.dockPosition = TTDockPositionLeftCenter;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (viewController.view.superview) {
                    TranslateInteractive *hideInteractive = [[TranslateInteractive alloc] initWithDirection:TranslateInteractiveDirectionRightToLeft];
                    [hideInteractive addInteractiveGestureToView:viewController.view];
                    @weakify(viewController)
                    hideInteractive.interactiveDidBegin = ^BOOL{
                        [weak_viewController dismissViewControllerAnimated:YES completion:NULL];
                        return YES;
                    };
                    viewController.hideInteractive = hideInteractive;
                }
            });
            break;
        }
        case TranslateDirectionRightToLeft:
            translateAnimate.hideDirection = TranslateDirectionLeftToRight;
            translateAnimate.dockPosition = TTDockPositionRightCenter;
            break;
        case TranslateDirectionBottomToTop:
            translateAnimate.hideDirection = TranslateDirectionTopToBottom;
            translateAnimate.dockPosition = TTDockPositionBottomCenter;
            break;
        case TranslateDirectionTopToBottom:
            translateAnimate.hideDirection = TranslateDirectionBottomToTop;
            translateAnimate.dockPosition = TTDockPositionTopCenter;
            break;
        default:
            break;
    }

    viewController.transitionAnimate = translateAnimate;
    [self presentViewController:viewController animated:animate completion:completion];
}

#pragma mark - incident

#pragma mark - private
#pragma mark - delegate
#pragma mark - getter/setter

@end
