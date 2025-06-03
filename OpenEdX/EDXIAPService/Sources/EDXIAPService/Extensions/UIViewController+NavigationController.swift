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
}
