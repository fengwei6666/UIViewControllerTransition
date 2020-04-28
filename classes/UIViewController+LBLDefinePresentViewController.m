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
    [self lblDefinePresentViewController:viewController formDirection:(TransitionDirectionFromLeft)];
}

- (void)lblDefinePresentViewController:(UIViewController *)viewController formDirection:(TransitionDirection)direction
{
    [self lblDefinePresentViewController:viewController animate:YES formDirection:direction];
}

- (void)lblDefinePresentViewController:(UIViewController *)viewController animate:(BOOL)animate formDirection:(TransitionDirection)direction
{
    LBLTrasitionViewController *controller = [[LBLTrasitionViewController alloc] initWithPresentedViewController:viewController presentingViewController:self];
    viewController.transitioningDelegate = controller;
    controller.animTransition.transitionDirection = direction;
    if (direction == TransitionDirectionFromLeft) {
        [viewController addBackGesture];
    }
    
    [self presentViewController:viewController animated:animate completion:nil];
}

- (void)addBackGesture {
    
    UIPanGestureRecognizer *panback = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [self.view addGestureRecognizer: panback];
    [self setPanBack:panback];
}

- (void)removeBackGesture {
    
    UIPanGestureRecognizer *panback = [self panBack];
    [self.view removeGestureRecognizer:panback];
}

#pragma mark - incident
- (void)panHandler:(UIPanGestureRecognizer *)pan {
 
    LBLTrasitionViewController *controller = (LBLTrasitionViewController *)self.transitioningDelegate;
    if (controller.animTransition.transitionDirection == TransitionDirectionFromLeft) {
        CGFloat space = 0.0;
        switch (pan.state) {
            case UIGestureRecognizerStateBegan: {
                CGFloat startX = [pan locationInView:self.view].x;
                [self setPanStartX:[NSNumber numberWithDouble:startX]];
            }break;
            case UIGestureRecognizerStateChanged: {
                CGFloat movieX = [pan locationInView:self.view].x;
                space = [[self panStartX] doubleValue] - movieX;
            }break;
            default:
                NSLog(@"...");
                break;
        }
        if (space > self.preferredContentSize.width * 0.3) {
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }
}

#pragma mark - private
#pragma mark - delegate
#pragma mark - getter/setter
- (UIPanGestureRecognizer *)panBack {
    
    return (UIPanGestureRecognizer *)objc_getAssociatedObject(self, _cmd);
}

- (void)setPanBack:(UIPanGestureRecognizer *)panBack {
    
    objc_setAssociatedObject(self, @selector(panBack), panBack, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPanStartX:(NSNumber *)panStartX {
    
    objc_setAssociatedObject(self, @selector(panStartX), panStartX, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)panStartX {
    
    return objc_getAssociatedObject(self, _cmd);
}

@end
