//
//  UINavigationController.swift
//  Core
//
//  Created by Anton Yarmolenka on 04/03/2025.
//

import UIKit
import Theme

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
        navigationBar.barTintColor = .clear
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        
        let image = CoreAssets.arrowLeft.image
        navigationBar.backIndicatorImage = image.withTintColor(Theme.UIColors.accentXColor)
        navigationBar.backIndicatorTransitionMaskImage = image.withTintColor(Theme.UIColors.accentXColor)
        navigationBar.titleTextAttributes = [
            .foregroundColor: Theme.UIColors.navigationBarTintColor,
            .font: Theme.UIFonts.titleMedium()
        ]
        
        UISegmentedControl.appearance().setTitleTextAttributes(
            [
                .foregroundColor: Theme.Colors.textPrimary.uiColor(),
                .font: Theme.UIFonts.labelLarge()
            ],
            for: .normal
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [
                .foregroundColor: Theme.Colors.primaryButtonTextColor.uiColor(),
                .font: Theme.UIFonts.labelLarge()
            ],
            for: .selected
        )
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Theme.Colors.accentXColor)
        
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = Theme.UIColors.accentXColor
    }
}
