//
//  LBLTrasitionViewController.h
//  testTransition
//
//  Created by 君若见故 on 2018/7/13.
//  Copyright © 2018年 君若见故. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBLAnimatedTransitioning.h"

/**
 转场控制器类，负责转场控制
 @参考文章 https://www.objccn.io/issue-12-3/
 @note 被转场控制器需实现preferredContentSize属性，标明自身大小。
       动画更改只需实现UIViewControllerAnimatedTransitioning协议。
       此处提供了一个从左至右的动画效果。
 */
@interface LBLTrasitionViewController : UIPresentationController<UIViewControllerTransitioningDelegate>

// 动画执行者
@property (nonatomic, strong) LBLAnimatedTransitioning *animTransition;

@end
