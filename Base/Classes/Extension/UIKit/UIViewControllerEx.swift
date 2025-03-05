//
//  UIViewControllerEx.swift
//  Base
//
//  Created by remy on 2018/3/19.
//

import UIKit

func modalNC(_ nc: UINavigationController.Type, opaque: Bool, vc: UIViewController) -> UIViewController {
    var root = vc
    if !vc.isKind(of: UINavigationController.self) {
        root = nc.init(rootViewController: vc)
    }
    if !opaque {
        root.modalPresentationStyle = .custom
        root.modalPresentationCapturesStatusBarAppearance = true
    }
    return root
}

extension UIViewController {
    
    // http://stackoverflow.com/questions/23620276/check-if-view-controller-is-presented-modally-or-pushed-on-a-navigation-stack
    public var isModal: Bool {
        if presentingViewController != nil {
            return true
        }
        if let nc = navigationController?.presentingViewController?.presentedViewController, nc === navigationController {
            return true
        }
        if tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        return false
    }
    
    public func presentNC(_ vc: UIViewController, nc: UINavigationController.Type = UINavigationController.self, animated: Bool = true, completion: (() -> Void)? = nil) {
        let root = modalNC(nc, opaque: true, vc: vc)
        root.modalPresentationStyle = .fullScreen
        present(root, animated: animated, completion: completion)
    }
    
    public func presentTransparentNC(_ vc: UIViewController, nc: UINavigationController.Type = UINavigationController.self, animated: Bool = true, completion: (() -> Void)? = nil) {
        let root = modalNC(nc, opaque: false, vc: vc)
        present(root, animated: animated, completion: completion)
    }
    
    public func presentVC(_ vc: UIViewController, sourceView: UIView? = nil, sourceRect: CGRect = .null, animated: Bool = true, completion: (() -> Void)? = nil) {
        if let pop = vc.popoverPresentationController {
            if let sourceView = sourceView {
                pop.sourceView = sourceView
                pop.sourceRect = sourceRect == .null ? sourceView.bounds : sourceRect
            } else {
                pop.sourceView = UIApplication.shared.keyWindow
                pop.sourceRect = CGRect(x: ANSize.screenWidth / 2, y: ANSize.screenHeight, width: 0, height: 0)
            }
        }
        present(vc, animated: animated, completion: completion)
    }
    
    public func presentOnTop(angle: CGFloat = 0) {
        let win = UIWindow(frame: UIScreen.main.bounds)
        win.transform = CGAffineTransform(rotationAngle: angle)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert
        win.makeKeyAndVisible()
        vc.presentVC(self)
    }
}

private func run(_ block: () -> Void, completion: (() -> Void)?) {
    if let completion = completion {
        // MARK: pushVC会导致生命周期(viewDidLoad等)提前执行
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        block()
        CATransaction.commit()
    } else {
        block()
    }
}

extension UIViewController {
    
    public func pushVC(_ vc: UIViewController,
                       animated: Bool = true,
                       completion: ((UINavigationController) -> Void)? = nil) {
        guard let nc = navigationController else { return }
        run({ nc.pushViewController(vc, animated: animated) }) { completion?(nc) }
    }
    
    public func popVC(animated: Bool = true, completion: ((UINavigationController) -> Void)? = nil) {
        guard let nc = navigationController else { return }
        run({ nc.popViewController(animated: animated) }) { completion?(nc) }
    }
    
    public func popToVC(_ vc: UIViewController,
                        animated: Bool = true,
                        completion: ((UINavigationController) -> Void)? = nil) {
        guard let nc = navigationController else { return }
        run({ nc.popToViewController(vc, animated: animated) }) { completion?(nc) }
    }
    
    public func popToRootVC(animated: Bool = true, completion: ((UINavigationController) -> Void)? = nil) {
        guard let nc = navigationController else { return }
        run({ nc.popToRootViewController(animated: animated) }) { completion?(nc) }
    }
    
    public func popToVC(_ count: Int,
                        animated: Bool = true,
                        completion: ((UINavigationController, Bool) -> Void)? = nil) {
        guard let nc = navigationController else { return }
        guard count > 0 && count < nc.viewControllers.count else {
            completion?(nc, false)
            return
        }
        let vc = nc.viewControllers[nc.viewControllers.count - count - 1]
        run({ nc.popToViewController(vc, animated: animated) }) { completion?(nc, true) }
    }
    
    public func popAndPush(_ vc: UIViewController,
                           animated: Bool = true,
                           completion: ((UINavigationController) -> Void)? = nil) {
        guard let nc = navigationController else { return }
        if nc.viewControllers.count > 1 {
            nc.popViewController(animated: false)
        }
        run({ nc.pushViewController(vc, animated: animated) }) { completion?(nc) }
    }
    
    public func popAndPush(_ vc: UIViewController,
                           count: Int,
                           animated: Bool = true,
                           completion: ((UINavigationController) -> Void)? = nil) {
        guard let nc = navigationController else { return }
        var vcs = nc.viewControllers
        if vcs.count > count {
            vcs.removeSubrange((vcs.count - count)..<vcs.count)
        }
        nc.viewControllers = vcs
        run({ nc.pushViewController(vc, animated: animated) }) { completion?(nc) }
    }

    public func popToVC(_ cls: AnyClass,
                        animated: Bool = true,
                        completion: ((UINavigationController, Bool) -> Void)? = nil) {
        guard let nc = navigationController else { return }
        guard nc.viewControllers.count > 1 else { return }
        let past = nc.viewControllers[0..<nc.viewControllers.count-1].reversed()
        for vc in past {
            guard vc.isKind(of: cls) else { continue }
            return run({ nc.popToViewController(vc, animated: animated) }) { completion?(nc, true) }
        }
        completion?(nc, false)
    }
}

extension UIViewController {
    public func previousVC() -> String? {
        if let navigationController = navigationController,
           navigationController.viewControllers.count > 1 {
            let previousViewController = navigationController.viewControllers[navigationController.viewControllers.count - 2]
            let previousClassName = String(describing: type(of: previousViewController))
            return previousClassName
        } else if let presentingVC = presentingViewController {
            let previousClassName = String(describing: type(of: presentingVC))
            return previousClassName
        }
        return nil
    }
}
