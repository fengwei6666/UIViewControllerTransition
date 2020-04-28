//
//  TransitionController.swift
//  transitionDemo
//
//  Created by wei.feng on 2020/1/7.
//  Copyright © 2020 weifeng. All rights reserved.
//

import UIKit

/// UIViewController转场代理对象
class TransitionController: NSObject {
    weak var currentTransitionInteractive : TranslateInteractive?
}

/// 
extension TransitionController : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        currentTransitionInteractive = presented.showInteractive
        presented.transitionAnimate?.animateType = .show
        return presented.transitionAnimate
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        currentTransitionInteractive = dismissed
        .hideInteractive
        dismissed.transitionAnimate?.animateType = .hide
        return dismissed.transitionAnimate
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if currentTransitionInteractive?.isDraging ?? false {
            return currentTransitionInteractive
        }
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if currentTransitionInteractive?.isDraging ?? false {
            return currentTransitionInteractive
        }
        return nil
    }
}

extension TransitionController : UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            currentTransitionInteractive = toVC.showInteractive
            toVC.transitionAnimate?.animateType = .show
            return toVC.transitionAnimate
        case .pop:
            currentTransitionInteractive = fromVC.hideInteractive
            fromVC.transitionAnimate?.animateType = .hide
            return fromVC.transitionAnimate
        default:
            currentTransitionInteractive = nil
            return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if currentTransitionInteractive?.isDraging ?? false {
            return currentTransitionInteractive
        }
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        //
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        //
    }
}

struct TransitionAssociatekeys {
    static var animateKey = 0
    static var showInteractiveKey = 5
    static var hideInteractiveKey = 6
    
    static var transitionControllerKey = 10
}

/// 扩展转场动画和交互配置项
extension UIViewController {
    
    /// 转场动画
    @objc var transitionAnimate : TransitionAnimate? {
        get{
            return objc_getAssociatedObject(self, &TransitionAssociatekeys.animateKey) as? TransitionAnimate
        }
        set(newValue) {
            objc_setAssociatedObject(self, &TransitionAssociatekeys.animateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
        
    /// 入场交互
    @objc var showInteractive : TranslateInteractive? {
        get{
            return objc_getAssociatedObject(self, &TransitionAssociatekeys.showInteractiveKey) as? TranslateInteractive
        }
        set(newValue) {
            objc_setAssociatedObject(self, &TransitionAssociatekeys.showInteractiveKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 退场交互
    @objc var hideInteractive : TranslateInteractive? {
        get{
            return objc_getAssociatedObject(self, &TransitionAssociatekeys.hideInteractiveKey) as? TranslateInteractive
        }
        set(newValue) {
            objc_setAssociatedObject(self, &TransitionAssociatekeys.hideInteractiveKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    //用自定义的方式present一个视图
//    @objc func presentViewController(presented : UIViewController, direction : TranslateDirection, animate : Bool = true, completion : (() -> Void)?) -> Void {
//        let transitionController = TransitionController()
//        presented.modalPresentationStyle = .custom
//        presented.transitioningDelegate = transitionController
//        
//        let transitionAnimate = TranslateTransition()
//        transitionAnimate.showDirection = direction
//        
//        switch direction {
//        case .leftToRight:
//            transitionAnimate.hideDirection = .rightToLeft
//            transitionAnimate.dockPosition = .leftCenter
//        case .rightToLeft:
//            transitionAnimate.hideDirection = .leftToRight
//            transitionAnimate.dockPosition = .rightCenter
//        case .topToBottom:
//            transitionAnimate.hideDirection = .bottomToTop
//            transitionAnimate.dockPosition = .topCenter
//        case .bottomToTop:
//            transitionAnimate.hideDirection = .topToBottom
//            transitionAnimate.dockPosition = .bottomCenter
//        }
//        
//        presented.transitionAnimate = transitionAnimate
//        
//        self.present(presented, animated: animate, completion: completion)
//    }
    
}

/// navigationController 自定义转场
extension UINavigationController {
    
    @objc var transitionController : TransitionController? {
        get{
            return objc_getAssociatedObject(self, &TransitionAssociatekeys.transitionControllerKey) as? TransitionController
        }
    }
    
    /// 创建自定义 push & pop 转场 (具体到每个界面的转场动画是什么，由ViewController自身的配置决定)
    @objc func setupCustomTransition() -> Void {
        if let t = self.transitionController {
            self.delegate = t
        }else {
            let transition = TransitionController()
            self.delegate = transition
            objc_setAssociatedObject(self, &TransitionAssociatekeys.transitionControllerKey, transition, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 销毁自定义转场配置
    @objc func destroyCustomTransition() -> Void {
        
        objc_setAssociatedObject(self, &TransitionAssociatekeys.transitionControllerKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
