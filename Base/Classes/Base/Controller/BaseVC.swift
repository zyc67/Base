//
//  BaseVC.swift
//  Base
//
//  Created by remy on 2018/3/18.
//

import UIKit

open class BaseVC: UIViewController {
    
    /// 导航栏类型
    public enum TopBarType {
        /// 系统导航栏
        case system
        /// 自定义导航栏
        case custom
        /// 禁用导航栏
        case none
    }
    
    /// 控制器是否处于顶层
    public private(set) var isViewAppearing: Bool = false
    /// 控制器是否在导航栈中
    public private(set) var hasViewAppeared: Bool = false
    /// 控制器内容frame
    public private(set) var contentFrame: CGRect = .zero
    /// 是否开启右滑返回手势
    public var gesturePopEnable: Bool = true
    /// 自定义导航栏
    public lazy var topBarView: ANTopBar = {
        return ANTopBar()
    }()
    /// 默认导航栏类型
    public static var defaultTopBarType: TopBarType = .custom
    /// 默认控制器背景色
    public static var defaultBGColor: UIColor = .clear
    /// 默认自定义导航栏左侧项
    public static var defaultLeftItem: ANTopBar.ItemType = .none
    /// 默认自定义导航栏左侧返回项
    public static var defaultLeftBackItem: ANTopBar.ItemType = .none
    /// 默认自定义导航栏左侧取消项
    public static var defaultLeftCancelItem: ANTopBar.ItemType = .none
    /// 默认自定义导航栏右侧项
    public static var defaultRightItem: ANTopBar.ItemType = .none
    /// 导航栏类型
    open var topBarType: TopBarType {
        return BaseVC.defaultTopBarType
    }

    public init(query: [AnyHashable: Any]? = nil) {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        hidesBottomBarWhenPushed = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isViewAppearing = true
        hasViewAppeared = true
        navigationController?.setNavigationBarHidden(topBarType != .system, animated: false)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewAppearing = false
    }
    
    open override func loadView() {
        super.loadView()
        view.backgroundColor = BaseVC.defaultBGColor
        automaticallyAdjustsScrollViewInsets = false
        contentFrame = view.bounds
        if topBarType != .none {
            contentFrame.origin.y = ANSize.topHeight
            contentFrame.size.height -= ANSize.topHeight
            if topBarType == .custom {
                view.addSubview(topBarView)
                let num = navigationController?.viewControllers.count ?? 0
                if num > 1 {
                    topBarView.leftItems = [BaseVC.defaultLeftBackItem]
                    topBarView.leftActions = [UITapGestureRecognizer(target: self, action: #selector(BaseVC.backAction))]
                } else {
                    if isModal {
                        topBarView.leftItems = [BaseVC.defaultLeftCancelItem]
                        topBarView.leftActions = [UITapGestureRecognizer(target: self, action: #selector(BaseVC.cancelAction))]
                    } else {
                        topBarView.leftItems = [BaseVC.defaultLeftItem]
                        topBarView.leftActions = [UITapGestureRecognizer(target: self, action: #selector(BaseVC.leftAction))]
                    }
                }
                topBarView.rightItems = [BaseVC.defaultRightItem]
                topBarView.rightActions = [UITapGestureRecognizer(target: self, action: #selector(BaseVC.rightAction))]
            }
        }
        if !hidesBottomBarWhenPushed && tabBarController != nil {
            contentFrame.size.height -= ANSize.bottomHeight
        }
    }
    
    /// 控制器返回
    @objc open func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 取消控制器模态
    @objc open func cancelAction() {
        dismiss(animated: true)
    }
    
    /// 导航栏左侧动作
    @objc open func leftAction() {}
    
    /// 导航栏右侧动作
    @objc open func rightAction() {}
    
    open override func didReceiveMemoryWarning() {
        if hasViewAppeared && !isViewAppearing {
            hasViewAppeared = false
        }
        super.didReceiveMemoryWarning()
    }
    
    open func popPanGestureRecognizer() -> UIGestureRecognizer? {
        if let gestureArr = navigationController?.view.gestureRecognizers {
            for panGesture in gestureArr {
                if panGesture.isKind(of: UIScreenEdgePanGestureRecognizer.self) {
                    return panGesture
                }
            }
        }
        return nil
    }
    
    deinit {
        ANPrint("\(self.metaTypeName) has deinit")
    }
}

// 根控制器为 BaseVC 的设置
extension BaseVC {
    
    public func presentNC(_ vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.presentNC(vc, nc: NavigationController.self, animated: animated, completion: completion)
    }
    
    public func presentTransparentNC(_ vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.presentTransparentNC(vc, nc: NavigationController.self, animated: animated, completion: completion)
    }
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var prefersStatusBarHidden: Bool {
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

// 根控制器为 UITabBarController 的设置
extension UITabBarController {
    
    public func presentNC(_ vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.presentNC(vc, nc: NavigationController.self, animated: animated, completion: completion)
    }
    
    public func presentTransparentNC(_ vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.presentTransparentNC(vc, nc: NavigationController.self, animated: animated, completion: completion)
    }
    
    open override var shouldAutorotate: Bool {
        return selectedViewController?.shouldAutorotate ?? false
    }
    
    open override var prefersStatusBarHidden: Bool {
        return selectedViewController?.prefersStatusBarHidden ?? false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return selectedViewController?.preferredStatusBarStyle ?? .default
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return selectedViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return selectedViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}
