//
//  UIKitEx.swift
//  Base
//
//  Created by remy on 2017/12/22.
//  Copyright © 2017年 remy. All rights reserved.
//

import UIKit

extension UIApplication {
    
    public enum Setting: String {
        case `default` = ""
        case general = "root=General"
        case wifi = "root=WIFI"
        case store = "root=STORE"
        case iCloud = "root=CASTLE"
        case battery = "root=BATTERY_USAGE"
        case bluetooth = "root=Bluetooth"
        case display = "root=DISPLAY"
        case sound = "root=Sounds"
        case keyboard = "root=General&path=Keyboard"
        case about = "root=General&path=About"
        case accessibility = "root=General&path=ACCESSIBILITY"
    }
    
    private static var settingPrefix: String = "prefs:"
    
    /// 打开设置,ios11+只能跳到设置主页面或上一次停留的设置页面
    public static func openMainSetting(_ setting: Setting = .default) {
        self.openStrURL(settingPrefix + setting.rawValue)
    }
    
    /// 打开app设置
    public static func openAppSetting() {
        self.openStrURL(UIApplication.openSettingsURLString)
    }
    
    public static func openStrURL(_ str: String) {
        guard let url = URL(string: str) else { return }
        UIApplication.openURL(url)
    }
    
    public static func openURL(_ url: URL?) {
        guard let url = url else { return }
        UIApplication.shared.open(url)
    }
    
    public static func topVC(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topVC(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topVC(selected)
        }
        if let presented = base?.presentedViewController {
            return topVC(presented)
        }
        return base
    }
    
    public static var screenOrientation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
}

private weak var _firstResponder: UIResponder?
extension UIResponder {
    
    /// 事件冒泡
    @objc open func routerEvent(name: String, data: [AnyHashable: Any]? = nil) {
        self.next?.routerEvent(name: name, data: data)
    }
    
    /// 获取最上层响应者
    public static var firstResponder: UIResponder? {
        _firstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _firstResponder
    }
    
    @objc private func findFirstResponder(_ sender: AnyObject) {
        _firstResponder = self
    }
    
    /// 获取当前响应者之下指定类型的最上层响应者
    public func firstResponder<T: UIResponder>(_ type: T.Type) -> T? {
        var res = self
        while true {
            if let res = res as? T {
                return res
            }
            guard let next = res.next else { return nil }
            res = next
        }
    }
    /// 获取当前响应者之下最上层控制器
    public var firstVC: UIViewController? {
        return self.firstResponder(UIViewController.self)
    }
    
    /// 获取当前响应者之下指定类型的最下层响应者
    public func lastResponder<T: UIResponder>(_ type: T.Type) -> T? {
        var res = self
        var target: T?
        while true {
            if let res = res as? T {
                target = res
            }
            guard let next = res.next else { return target }
            res = next
        }
    }
    /// 获取当前响应者之下最下层控制器
    public var lastVC: UIViewController? {
        return self.lastResponder(UIViewController.self)
    }
}
    
extension UIScreen {
    
    public static var size: CGSize {
        return UIScreen.main.bounds.size
    }
    
    public static var width: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    public static var height: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    public static var center: CGPoint {
        return CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    }
}
