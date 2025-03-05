//
//  ANMask.swift
//  Source
//
//  Created by remy on 2020/1/18.
//  Copyright © 2020 com.Base. All rights reserved.
//

open class ANMask {
    
    public class Stage {
        private let type: Int
        internal weak var view: UIView?
        private init(_ type: Int) {
            self.type = type
        }
        public static func window(_ onKeyWindow: Bool) -> Stage {
            let stage = Stage(onKeyWindow ? 0 : 1)
            return stage
        }
        public static func view(_ view: UIView) -> Stage {
            let stage = Stage(2)
            stage.view = view
            return stage
        }
        public var isKeyWindow: Bool { return type == 0 }
        public var isNewWindow: Bool { return type == 1 }
        public var isView: Bool { return type == 2 }
    }
    public struct Options {
        /// 视图出现时是否关闭其他已显示视图
        public var solo: Bool = true
        /// 父元素
        public var stage: Stage = .window(true)
        /// 是否点击蒙层关闭
        public var maskTapHide: Bool = true
        /// 蒙层颜色
        public var maskColor: UIColor = UIColor.black.withAlphaComponent(0.4)
        /// 关闭回调
        public var didHideAction: (() -> Void)?
        public init() {}
    }
    public typealias OptionsClosure = (inout Options) -> Void
    public static var global: Options = Options()
    private var options: Options
    private static var masks: [ANMask] = []
    /// 根视图
    public private(set) var rootView: UIView?
    private weak static var originWindow: UIWindow?
    
    @discardableResult
    public static func show(frame: CGRect = UIScreen.main.bounds,
                            view: UIView? = nil,
                            closure: OptionsClosure? = nil) -> ANMask {
        masks = masks.filter {
            // view类型时,检查之前因没关闭而出现的内存泄漏
            guard $0.options.stage.isView else { return true }
            return $0.rootView?.superview != nil
        }
        let mask = ANMask(closure: closure)
        masks.append(mask)
        let options = mask.options
        if options.stage.isNewWindow {
            if self.originWindow == nil {
                // 记录原始keyWindow
                self.originWindow = UIApplication.shared.keyWindow
            }
            let rootView = UIWindow(frame: frame)
            rootView.windowLevel = UIWindow.Level.alert
            // 必须调用makeKeyAndVisible,否则该window下的组件无法通过代码主动获取焦点
            rootView.makeKeyAndVisible()
            rootView.isHidden = false
            let bgView = UIView(frame: rootView.bounds, color: options.maskColor)
            rootView.addSubview(bgView)
            if options.maskTapHide {
                bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideTap(_:))))
            }
            if let view = view { rootView.addSubview(view) }
            mask.rootView = rootView
        } else {
            let rootView = UIView(frame: frame)
            if options.stage.isView {
                options.stage.view?.addSubview(rootView)
            } else {
                UIApplication.shared.keyWindow?.addSubview(rootView)
            }
            let bgView = UIView(frame: rootView.bounds, color: options.maskColor)
            rootView.addSubview(bgView)
            if options.maskTapHide {
                bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideTap(_:))))
            }
            if let view = view { rootView.addSubview(view) }
            mask.rootView = rootView
        }
        return mask
    }
    
    private init(closure: OptionsClosure? = nil) {
        var options = ANMask.global
        closure?(&options)
        self.options = options
        if options.solo { ANMask.hideAll() }
    }
    
    deinit {
        ANPrint("\(String(describing: self)) has deinit")
    }
    
    public static func hideAll() {
        self.originWindow?.makeKeyAndVisible()
        self.originWindow = nil
        // 防止didHideAction调用hideAll死循环,先清空ANMask.masks
        let masks = ANMask.masks
        ANMask.masks.removeAll()
        masks.forEach {
            if !$0.options.stage.isNewWindow {
                $0.rootView?.removeFromSuperview()
            }
            $0.options.didHideAction?()
        }
    }
    
    public static func hide(_ mask: ANMask) {
        mask.hide()
    }
    
    public func hide() {
        if !self.options.stage.isNewWindow {
            self.rootView?.removeFromSuperview()
        }
        ANMask.masks.removeAll(where: { $0 === self })
        var hasOtherNewWindow: Bool = false
        if ANMask.masks.count > 0 {
            // 存在其他新建window类型的mask时遵循后进先出原则设为keyWindow
            for mask in ANMask.masks.reversed() where mask.options.stage.isNewWindow {
                (mask.rootView as? UIWindow)?.makeKeyAndVisible()
                hasOtherNewWindow = true
                break
            }
        }
        if !hasOtherNewWindow {
            ANMask.originWindow?.makeKeyAndVisible()
            ANMask.originWindow = nil
        }
        self.options.didHideAction?()
    }
    
    private static func hideByRootView(_ view: UIView?) {
        guard let view = view else { return }
        for mask in self.masks where mask.rootView == view {
            return mask.hide()
        }
    }
    
    @objc private static func hideTap(_ gestureRecognizer: UIGestureRecognizer) {
        hideByRootView(gestureRecognizer.view?.superview)
    }
}
