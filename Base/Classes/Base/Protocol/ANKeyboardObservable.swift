//
//  ANKeyboardManager.swift
//  Andmix
//
//  Created by remy on 2018/7/16.
//

import UIKit

/// 键盘通知管理者
public class ANKeyboardManager {
    
    /// 单例
    public static let shared = ANKeyboardManager()
    /// 当前最上层监听者
    private weak var topKBObserver: (UIResponder&ANKeyboardObservable)?
    /// 响应者是否在监听范围
    private var KBIdleResponderKey: Void?
    /// 是否开启键盘事件监听,默认关闭
    public var enable: Bool = false {
        willSet {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
            if newValue {
                NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
            }
        }
    }
    public static var defaultTopBar: UIView?
    
    private init() {}
    
    private func isNotifyEnable(_ target: ANKeyboardObservable) -> Bool {
        return objc_getAssociatedObject(target, &KBNotifyEnableKey) as? Bool ?? true
    }
    
    private func getTopBar(_ target: ANKeyboardObservable) -> UIView? {
        return objc_getAssociatedObject(target, &KBTopBarKey) as? UIView
    }
    
    private func isIdleResponder(_ target: UIResponder) -> Bool {
        return objc_getAssociatedObject(target, &KBIdleResponderKey) as? Bool ?? false
    }
}

extension ANKeyboardManager {
    
    @objc func keyboardWillShow(_ notification: Notification) {
        self.topKBObserver = nil
        guard let firstResponder = UIApplication.firstResponder else { return }
        if let target = objc_getAssociatedObject(firstResponder, &KBObserverKey) as? UIResponder&ANKeyboardObservable {
            // 找出当前响应者保存的键盘监听者
            self.topKBObserver = target
        } else {
            // 如果当前响应者没有保存键盘监听者,判断是否是普通元素
            guard !isIdleResponder(firstResponder) else { return }
            var res: UIResponder = firstResponder
            while true {
                if let res = res as? UIResponder&ANKeyboardObservable {
                    // 找出离当前响应者最近的键盘监听者并保存
                    objc_setAssociatedObject(firstResponder, &KBObserverKey, res, .OBJC_ASSOCIATION_ASSIGN)
                    self.topKBObserver = res
                    break
                }
                guard let next = res.next else {
                    // 如果没有最近的键盘监听者则标记为普通元素
                    objc_setAssociatedObject(firstResponder, &KBIdleResponderKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    break
                }
                res = next
            }
        }
        animateKeyboard(notification, appearing: true)
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        animateKeyboard(notification, appearing: false)
    }
    @objc func keyboardDidShow(_ notification: Notification) {
        guard let observer = self.topKBObserver, isNotifyEnable(observer) else { return }
        if var frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            if let topBar = getTopBar(observer) {
                frame = CGRect(x: frame.origin.x, y: frame.origin.y - topBar.height, width: frame.size.width, height: frame.size.height + topBar.height)
            }
            observer.keyboardDidAppear(animated: false, frame: frame)
        }
    }
    @objc func keyboardDidHide(_ notification: Notification) {
        guard let observer = self.topKBObserver, isNotifyEnable(observer) else { return }
        if var frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            if let topBar = getTopBar(observer) {
                frame = CGRect(x: frame.origin.x, y: frame.origin.y - topBar.height, width: frame.size.width, height: frame.size.height + topBar.height)
            }
            observer.keyboardDidDisappear(animated: false, frame: frame)
        }
    }
    func animateKeyboard(_ notification: Notification, appearing: Bool) {
        guard let observer = self.topKBObserver else { return }
        if let info = notification.userInfo, var frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect, let curveValue = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int, let curve = UIView.AnimationCurve(rawValue: curveValue), let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationCurve(curve)
            UIView.setAnimationDuration(duration)
            if let topBar = getTopBar(observer), let topView = UIApplication.topVC()?.view {
                if appearing {
                    topView.addSubview(topBar)
                    topBar.transform = CGAffineTransform(translationX: 0.0, y: -frame.size.height - topBar.height)
                } else {
                    topBar.transform = .identity
                }
                frame = CGRect(x: frame.origin.x, y: frame.origin.y - topBar.height, width: frame.size.width, height: frame.size.height + topBar.height)
            }
            if isNotifyEnable(observer) {
                if appearing {
                    observer.keyboardWillAppear(animated: true, frame: frame)
                } else {
                    observer.keyboardWillDisappear(animated: true, frame: frame)
                }
            }
            UIView.commitAnimations()
        }
    }
}

/// 组件协议
public protocol ANKeyboardObservable: ANSpaceCompatible where Self: UIResponder {
    func keyboardWillAppear(animated: Bool, frame: CGRect)
    func keyboardWillDisappear(animated: Bool, frame: CGRect)
    func keyboardDidAppear(animated: Bool, frame: CGRect)
    func keyboardDidDisappear(animated: Bool, frame: CGRect)
}
public extension ANKeyboardObservable {
    func keyboardWillAppear(animated: Bool, frame: CGRect) {}
    func keyboardWillDisappear(animated: Bool, frame: CGRect) {}
    func keyboardDidAppear(animated: Bool, frame: CGRect) {}
    func keyboardDidDisappear(animated: Bool, frame: CGRect) {}
}
/// 键盘topBar的key
private var KBTopBarKey: Void?
/// 响应者所属的监听者key
private var KBObserverKey: Void?
/// 监听者是否开启监听key
private var KBNotifyEnableKey: Void?

extension ANSpace where Base: ANKeyboardObservable {
    
    /// 键盘topBar,设置nil以禁止
    public var kbTopBar: UIView? {
        get {
            return objc_getAssociatedObject(base, &KBTopBarKey) as? UIView
        }
        set {
            objc_setAssociatedObject(base, &KBTopBarKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    /// 是否开启键盘监听
    public var kbNotifyEnable: Bool {
        get {
            return (objc_getAssociatedObject(base, &KBNotifyEnableKey) as? Bool) ?? true
        }
        set {
            objc_setAssociatedObject(base, &KBNotifyEnableKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    /// 绑定输入视图,默认为离当前输入视图最近的键盘监听者
    public func bindInputView(_ view: UIResponder) {
        objc_setAssociatedObject(view, &KBObserverKey, base, .OBJC_ASSOCIATION_ASSIGN)
    }
}
