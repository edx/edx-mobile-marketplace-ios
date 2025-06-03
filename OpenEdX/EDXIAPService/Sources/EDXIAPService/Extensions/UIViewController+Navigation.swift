//
//  UIViewController+NavigationController.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 3.06.25.
//

import UIKit

extension UIViewController {
    func rootNavigationController() -> UINavigationController? {
        if let navigationController = navigationController {
            return navigationController.rootNavigationController()
        }
        
        if let presentingViewController,
            presentingViewController.navigationController != nil ||
            presentingViewController.presentingViewController != nil {
            return presentingViewController.rootNavigationController()
        }
        
        if let navigationController = self as? UINavigationController {
            return navigationController
        }
        return nil
    }
    
    func mostTopViewController() -> UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.mostTopViewController()
        }
        if let tabController = self as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return selected.mostTopViewController()
            }
        }
        if let presented = presentedViewController {
            return presented.mostTopViewController()
        }
        
        if let tabBarController = children.first(where: {$0 is UITabBarController}) as? UITabBarController {
            if let selected = tabBarController.selectedViewController {
                return selected.mostTopViewController()
            }
        }
        
        if let navigationController = children.first(where: {$0 is UINavigationController}) as? UINavigationController {
            return navigationController.visibleViewController?.mostTopViewController()
        }
        
        return self
    }
}
