//
//  UIScrollView+ANRefresh.swift
//  Base
//
//  Created by remy on 2018/5/6.
//

import UIKit

extension UIScrollView: ANSpaceCompatible {}

internal extension UIImage {
    
    static func resource(name: String) -> UIImage? {
        return UIImage(named: name, in: getResourceBundle(), compatibleWith: nil)
    }
    
    static func getResourceBundle() -> Bundle {
        let bundle = Bundle(for: ANRefreshComponent.self).path(forResource: "ANRefresh", ofType: "bundle")!
        return Bundle(path: bundle)!
    }
}

private var ANRHeaderKey: Void?
private var ANRFooterKey: Void?
extension ANSpace where Base: UIScrollView {
    
    public var ANRHeader: ANRefreshComponent? {
        get {
            return objc_getAssociatedObject(base, &ANRHeaderKey) as? ANRefreshComponent
        }
        set {
            objc_setAssociatedObject(base, &ANRHeaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var ANRFooter: ANRefreshComponent? {
        get {
            return objc_getAssociatedObject(base, &ANRFooterKey) as? ANRefreshComponent
        }
        set {
            objc_setAssociatedObject(base, &ANRFooterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func addRefresh<T: ANRefreshComponent>(_ actionHandler: @escaping () -> Void, cls: T.Type) -> T {
        base.isMultipleTouchEnabled = false
        base.panGestureRecognizer.maximumNumberOfTouches = 1
        let view = cls.init()
        view.actionHandler = actionHandler
        base.addSubview(view)
        return view
    }
    
    @discardableResult
    public func addTopRefresh(_ actionHandler: @escaping () -> Void) -> ANTopRefreshView {
        let r = addRefresh(actionHandler, cls: ANTopRefreshView.self)
        r.animator = ANRefreshComponent.defaultPullAnimator.init()
        removeANRHeader()
        ANRHeader = r
        return r
    }
    
    @discardableResult
    public func addTopAutoRefresh(_ actionHandler: @escaping () -> Void) -> ANTopAutoRefreshView {
        let r = addRefresh(actionHandler, cls: ANTopAutoRefreshView.self)
        r.animator = ANRefreshComponent.defaultAutoAnimator.init()
        removeANRHeader()
        ANRHeader = r
        return r
    }
    
    @discardableResult
    public func addBottomRefresh(_ actionHandler: @escaping () -> Void) -> ANBottomRefreshView {
        let r = addRefresh(actionHandler, cls: ANBottomRefreshView.self)
        r.animator = ANRefreshComponent.defaultPullAnimator.init(isTop: false)
        removeANRFooter()
        ANRFooter = r
        return r
    }
    
    @discardableResult
    public func addBottomAutoRefresh(_ actionHandler: @escaping () -> Void) -> ANBottomAutoRefreshView {
        let r = addRefresh(actionHandler, cls: ANBottomAutoRefreshView.self)
        r.animator = ANRefreshComponent.defaultAutoAnimator.init(isTop: false)
        removeANRFooter()
        ANRFooter = r
        return r
    }
    
    public func removeANRHeader() {
        guard let ANRHeader = ANRHeader else { return }
        ANRHeader.stopRefreshing()
        ANRHeader.removeFromSuperview()
        self.ANRHeader = nil
    }
    
    public func removeANRFooter() {
        guard let ANRFooter = ANRFooter else { return }
        ANRFooter.stopRefreshing()
        ANRFooter.removeFromSuperview()
        self.ANRFooter = nil
    }
}
