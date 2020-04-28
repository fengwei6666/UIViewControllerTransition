//
//  LBLTrasitionViewController.m
//  testTransition
//
//  Created by 君若见故 on 2018/7/13.
//  Copyright © 2018年 君若见故. All rights reserved.
//

#import "LBLTrasitionViewController.h"

@interface LBLTrasitionViewController ()

// 阴影遮罩层
@property (nonatomic, strong) UIView *shadowView;

@end

@implementation LBLTrasitionViewController
{
    __weak TranslateInteractive *_currentInterActive;
}

#pragma mark - lifeCycle

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        // 自定义过场动画
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate
/*
 * 来告诉控制器，谁是动画主管(UIPresentationController)，因为此类继承了UIPresentationController，就返回了self
 */
- (UIPresentationController* )presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return self;
}

// 返回的对象控制Presented时的动画 (开始动画的具体细节负责类)
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    presented.transitionAnimate.animateType = TransitionAnimateTypeShow;
    _currentInterActive = presented.showInteractive;
    return presented.transitionAnimate;
}
// 由返回的控制器控制dismissed时的动画 (结束动画的具体细节负责类)
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    dismissed.transitionAnimate.animateType = TransitionAnimateTypeHide;
    _currentInterActive = dismissed.hideInteractive;
    return dismissed.transitionAnimate;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return _currentInterActive.isDraging ? _currentInterActive : nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return _currentInterActive.isDraging ? _currentInterActive : nil;
}

#pragma mark - 重写UIPresentationController方法

// 展示转场开始
- (void)presentationTransitionWillBegin {
 
    [self.containerView addSubview:self.shadowView];
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    self.shadowView.alpha = 0.0;
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.shadowView.alpha = 0.4;
    } completion:NULL];
}

// 展示转场结束
- (void)presentationTransitionDidEnd:(BOOL)completed {
    
    //...
}

// 消失转场开始
- (void)dismissalTransitionWillBegin {
    
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.shadowView.alpha = 0.0;
    } completion:NULL];
}

// 消失转场结束
- (void)dismissalTransitionDidEnd:(BOOL)completed {
    
    if (completed) {
        [self.shadowView removeFromSuperview];
        self.shadowView = nil;
    }
}

//| --------以下四个方法，是按照苹果官方Demo里的，都是为了计算目标控制器View的frame的----------------
//  当 presentation controller 接收到
//  -viewWillTransitionToSize:withTransitionCoordinator: message it calls this
//  method to retrieve the new size for the presentedViewController's view.
//  The presentation controller then sends a
//  -viewWillTransitionToSize:withTransitionCoordinator: message to the
//  presentedViewController with this size as the first argument.
//
//  Note that it is up to the presentation controller to adjust the frame
//  of the presented view controller's view to match this promised size.
//  We do this in -containerViewWillLayoutSubviews.
//
- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    
    if (container == self.presentedViewController)
        return ((UIViewController*)container).preferredContentSize;
    else
        return [super sizeForChildContentContainer:container withParentContainerSize:parentSize];
}

//在我们的自定义呈现中，被呈现的 view 并没有完全完全填充整个屏幕，
//被呈现的 view 的过渡动画之后的最终位置，是由 UIPresentationViewController 来负责定义的。
//我们重载 frameOfPresentedViewInContainerView 方法来定义这个最终位置
- (CGRect)frameOfPresentedViewInContainerView {
    
    CGRect containerViewBounds = self.containerView.bounds;
    CGSize presentedViewContentSize = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:containerViewBounds.size];
    
    // The presented view extends presentedViewContentSize.height points from
    // the bottom edge of the screen.
    CGRect presentedViewControllerFrame = containerViewBounds;
    presentedViewControllerFrame.size.height = presentedViewContentSize.height;
    presentedViewControllerFrame.origin.y = CGRectGetMaxY(containerViewBounds) - presentedViewContentSize.height;
    return presentedViewControllerFrame;
}

//  This method is similar to the -viewWillLayoutSubviews method in
//  UIViewController.  It allows the presentation controller to alter the
//  layout of any custom views it manages.
//
- (void)containerViewWillLayoutSubviews {
    
    [super containerViewWillLayoutSubviews];
    self.shadowView.frame = self.containerView.bounds;
}


//  This method is invoked whenever the presentedViewController's
//  preferredContentSize property changes.  It is also invoked just before the
//  presentation transition begins (prior to -presentationTransitionWillBegin).
//  建议就这样重写就行，这个应该是控制器内容大小变化时，就会调用这个方法， 比如适配横竖屏幕时，翻转屏幕时
//  可以使用UIContentContainer的方法来调整任何子视图控制器的大小或位置。
- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container {
    
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    
    if (container == self.presentedViewController)
        [self.containerView setNeedsLayout];
}


#pragma mark - public
#pragma mark - incident
- (void)clickShadowView:(UITapGestureRecognizer *)tap {
    
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}
#pragma mark - private
#pragma mark - getter/setter
- (UIView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[UIView alloc] init];
        _shadowView.backgroundColor = [UIColor blackColor];
        _shadowView.opaque = false;
        _shadowView.frame = self.containerView.bounds;
        [_shadowView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickShadowView:)]];
    }
    return _shadowView;
}

@end
