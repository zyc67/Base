//
//  NavigationController.swift
//  Base
//
//  Created by remy on 2018/3/18.
//

import UIKit

public class NavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
    var gesturePopEnable: Bool = true
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let transitionCoordinator = transitionCoordinator, transitionCoordinator.isAnimated {
            return false
        }
        if viewControllers.count > 1 {
            if let topVC = viewControllers.last as? BaseVC {
                return topVC.gesturePopEnable
            }
        } else {
            return false
        }
        return gesturePopEnable
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hidesBottomBarWhenPushed = viewControllers.count > 0
        super.pushViewController(viewController, animated: animated)
    }
}

// 根控制器为 NavigationController 的设置
extension NavigationController {
    
    public override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? false
    }
    
    public override var prefersStatusBarHidden: Bool {
        return topViewController?.prefersStatusBarHidden ?? false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}
