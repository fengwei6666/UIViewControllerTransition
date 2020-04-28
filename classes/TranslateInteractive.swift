//
//  TranslateInteractive.swift
//  XiaoZhong
//
//  Created by wei.feng on 2019/12/24.
//

import UIKit

//MARK: 转场交互基类，请不要直接使用，而应该使用其子类
class BaseTransitionInteractive: UIPercentDrivenInteractiveTransition {

//    /// 转场类型
//    @objc enum TranslateInteractiveType : Int {
//        case hide
//        case show
//    }
//
//    @objc var interactiveType : TranslateInteractiveType = .hide

}

//MARK: 平移类交互转场
class TranslateInteractive: BaseTransitionInteractive {
    
    /// 转场方向
    @objc enum TranslateInteractiveDirection : Int {
        case leftToRight
        case rightToLeft
        case topToBottom
        case bottomToTop
    }
    
    var direction : TranslateInteractiveDirection = .leftToRight
    
    var directionString : String {
        switch direction {
        case .leftToRight:
            return "从左至右"
        case .rightToLeft:
            return "从右至左"
        case .topToBottom:
            return "从上到下"
        case .bottomToTop:
            return "从下到上"
        }
    }
    
    /// 转场手势载体view
    weak var dView : UIView?
    /// 转场手势
    @objc var interactiveGesture : UIPanGestureRecognizer?
    
    //是否处于交互手势操作中
    @objc var isDraging : Bool = false
    
    /// 交互事件开始：一般在这里处理push、pop、present、dismiss事件
    @objc var interactiveDidBegin : (() -> Bool)?

    //init
    @objc init(direction : TranslateInteractiveDirection) {
        super.init()
        self.direction = direction
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        pan.delegate = self
        interactiveGesture = pan
    }
        
    deinit {
        if let v = dView, let g = interactiveGesture {
            v.removeGestureRecognizer(g)
        }
    }
}

/// 手势
extension TranslateInteractive : UIGestureRecognizerDelegate {
    
    /// 添加转场手势
    /// - Parameter view: 被添加转场手势的view
    @objc func addInteractiveGestureToView(_ view : UIView) -> Void {
        if let g = interactiveGesture {
            if let e = dView {
                e.removeGestureRecognizer(g)
            }
            view.addGestureRecognizer(g)
        }
        dView = view
    }
    
    /// 交互手势处理
    @objc func handlePanGesture(_ gesture : UIPanGestureRecognizer) -> Void {
        
        if let v = gesture.view {
            let translate = gesture.translation(in: v)
            let velocity = gesture.velocity(in: v)
            
            var percent : CGFloat = 0.0
            var speed : CGFloat = 0.0
            
            switch direction {
            case .leftToRight:
                percent = translate.x/v.bounds.size.width
                speed = velocity.x;
            case .rightToLeft:
                percent = -translate.x/v.bounds.size.width
                speed = -velocity.x
            case .topToBottom:
                percent = translate.y/v.bounds.size.height;
                speed = velocity.y
            case .bottomToTop:
                percent = -translate.y/v.bounds.size.height
                speed = -velocity.y
            }
            
            switch gesture.state {
            case .began:
                var allow = false
                if let b = interactiveDidBegin {
                    allow = b()
                }
                if !allow {
                    gesture.state = .cancelled
                    isDraging = false
                }
                print("转场即将开始[\(directionString)]: translate \(translate); velocity \(velocity)")
            case .changed:
                percent = max(0.0, min(1.0, percent))
                self.update(percent)
            
            default:
                if speed > 100 || percent > 0.45 {
                    self.finish()
                }else{
                    self.cancel()
                }
                isDraging = false
            }
        }
    }
    
    /// 手势代理
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: gestureRecognizer.view)
            var tanValue : CGFloat = 0.0
            if velocity.x == 0 {
                tanValue = abs(velocity.y)
            }else{
                tanValue = abs(velocity.y/velocity.x)
            }
            
            var allow = false
            let angle1 = Double.pi / 6;
            let angle2 = Double.pi / 3;
            
            switch direction {
            case .leftToRight:
                allow = (tanValue < CGFloat(tan(angle1)) && velocity.x > 0)
            case .rightToLeft:
                allow = (tanValue < CGFloat(tan(angle1)) && velocity.x < 0)
            case .bottomToTop:
                allow = (tanValue > CGFloat(tan(angle2)) && velocity.y < 0)
            case .topToBottom:
                allow = (tanValue > CGFloat(tan(angle2)) && velocity.y > 0)
            }
            
            isDraging = allow
            
            return allow
        }
        return true
    }
}
