//
//  BaseTransitionAnimate.swift
//  XiaoZhong
//
//  Created by wei.feng on 2019/12/25.
//

import UIKit

/// 底部视图的动画类型
@objc enum TTBelowViewAnimateType : Int {
    case noAnimate  /// 固定不动，没有动画
    case translate  /// 联动平移
    case zoom       /// 联动zoom
}

/// 停止的位置
@objc enum TTDockPosition : Int {
    case leftTop
    case leftCenter
    case leftBottom
    case rightTop
    case rightCenter
    case rightBottom
    case topCenter
    case bottomCenter
    case center
}

//MARK: 转场动画，可以继承使用，也可以直接用 animateBlock进行动画自定义
class TransitionAnimate: NSObject {

    //转场类型
    @objc enum TransitionAnimateType : Int {
        case hide   //消失
        case show   //出现
    }
    
    /// 转场类型
    @objc var animateType : TransitionAnimateType = .hide
    /// 转场时间
    @objc var animateDuration : TimeInterval = 0.25
    /// 转场动画
    @objc var animateBlock : ((_ transition : TransitionAnimate, _ transitionContext: UIViewControllerContextTransitioning) -> Void)?
    
    @objc var belowViewAnimateType : TTBelowViewAnimateType = .noAnimate
    @objc var dockPosition : TTDockPosition = .leftTop
}

extension TransitionAnimate : UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let b = animateBlock {
            b(self, transitionContext)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if animateDuration > 0.01 {
            return animateDuration
        }
        return 0.25
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        //
    }
}

/// 平移方向
@objc enum TranslateDirection : Int {
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop
}

//MARK: 平移类转场动画
class TranslateTransition : TransitionAnimate {
    
    @objc var showDirection : TranslateDirection = .rightToLeft
    @objc var hideDirection : TranslateDirection = .leftToRight
        
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //通过键值UITransitionContextToViewControllerKey获取需要呈现的视图控制器toVC
        
        if let tvc = transitionContext.viewController(forKey: .to), let fvc = transitionContext.viewController(forKey: .from) {

            //切换在containerView中完成，需要将toVC.view加到containerView中
            let containerView = transitionContext.containerView;
            let isShow = self.animateType == .show
            let translateView = isShow ? transitionContext.view(forKey: .to) : transitionContext.view(forKey: .from)

            if let view = translateView {

                let containerRect = containerView.bounds
                let size = isShow ? tvc.preferredContentSize : fvc.preferredContentSize
                var finalFrame = transitionContext.finalFrame(for: isShow ? tvc : fvc)
                if size != CGSize.zero {
                    finalFrame.size = size;
                }
                
                if finalFrame.size == CGSize.zero {
                    finalFrame = isShow ? tvc.view.bounds : fvc.view.bounds
                }

                finalFrame = self.fitSizeToRect(size: finalFrame.size, containerRect: containerRect, position: self.dockPosition)
                var startFrame = finalFrame

                switch self.animateType {
                case .show:
                    
                    switch self.showDirection {
                    case .leftToRight:
                        startFrame.origin.x = -startFrame.width
                    case .rightToLeft:
                        startFrame.origin.x = containerRect.width
                    case .topToBottom:
                        startFrame.origin.y = -startFrame.height
                    case .bottomToTop:
                        startFrame.origin.y = containerRect.height
                    }
                case .hide:
                    
                    switch self.hideDirection {
                    case .leftToRight:
                        finalFrame.origin.x = containerRect.width
                    case .rightToLeft:
                        finalFrame.origin.x = -startFrame.width
                    case .topToBottom:
                        finalFrame.origin.y = containerRect.height
                    case .bottomToTop:
                        finalFrame.origin.y = -startFrame.height
                    }
                }
                
                containerView.addSubview(fvc.view)
                if isShow {
                    containerView.insertSubview(tvc.view, aboveSubview: fvc.view)
                }else{
                    containerView.insertSubview(tvc.view, belowSubview: fvc.view)
                }
                
                let duration = self.transitionDuration(using: transitionContext)
                view.frame = startFrame
                UIView.animate(withDuration: duration, animations: {
                    view.frame = finalFrame

                }) { (finished) in
                    transitionContext.completeTransition(!(transitionContext.transitionWasCancelled))
                }
            }
        }
    }
    
    func fitSizeToRect(size : CGSize, containerRect : CGRect, position : TTDockPosition) -> CGRect {
        var rect = containerRect
        
        switch position {
        case .leftTop:
            rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        case .leftCenter:
            rect = CGRect(x: 0, y: (containerRect.height-size.height)/2.0, width: size.width, height: size.height)
        case .leftBottom:
            rect = CGRect(x: 0, y: containerRect.height-size.height, width: size.width, height: size.height)
        case .rightTop:
            rect = CGRect(x: containerRect.width-size.width, y: 0, width: size.width, height: size.height)
        case .rightCenter:
            rect = CGRect(x: containerRect.width-size.width, y: (containerRect.height-size.height)/2.0, width: size.width, height: size.height)
        case .rightBottom:
            rect = CGRect(x: containerRect.width-size.width, y: containerRect.height-size.height, width: size.width, height: size.height)
        case .topCenter:
            rect = CGRect(x: (containerRect.width-size.width)/2.0, y: 0, width: size.width, height: size.height)
        case .bottomCenter:
            rect = CGRect(x: (containerRect.width-size.width)/2.0, y: containerRect.height-size.height, width: size.width, height: size.height)
        default:
            rect = CGRect(x: (containerRect.width-size.width)/2.0, y: (containerRect.height-size.height)/2.0, width: size.width, height: size.height)
        }
         
        return rect
    }
}

//MARK: 淡入淡出转场动画
class FadeTransition: TransitionAnimate {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //通过键值UITransitionContextToViewControllerKey获取需要呈现的视图控制器toVC
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        if let tvc = toVC, let fvc = fromVC {

            //切换在containerView中完成，需要将toVC.view加到containerView中
            let containerView = transitionContext.containerView;
            var translateView = tvc.view
            
            switch self.animateType {
            case .show:
                translateView = tvc.view
                containerView.insertSubview(tvc.view, aboveSubview: fvc.view)
                
            case .hide:
                translateView = fvc.view
                containerView.insertSubview(tvc.view, belowSubview: fvc.view)
                
            }

            if let v = translateView {
                let isShow = (self.animateType == .show)
                v.alpha = isShow ? 0.0 : 1.0;
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                    v.alpha = isShow ? 1.0 : 0.0;
                }) { (finished) in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }
        }
    }
}
