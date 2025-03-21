//
//  Assets.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import UIKit

enum Assets: Sendable {
    enum Colors {
        static let cardViewStroke: UIColor = .color(named: "CardViewStroke")
        static let textPrimary: UIColor = .color(named: "TextPrimary")
        static let primaryCardCourseUpgradeBG: UIColor = .color(named: "PrimaryCardCourseUpgradeBG")
        static let background: UIColor = .color(named: "Background")
        static let white: UIColor = .color(named: "white")
        static let accentColor: UIColor = .color(named: "accentColor")
        static let datesSectionStroke: UIColor = .color(named: "DatesSectionStroke")
        static let datesSectionBackground: UIColor = .color(named: "DatesSectionBackground")
        static let accentButtonColor: UIColor = .color(named: "AccentButtonColor")
        static let styledButtonText: UIColor = .color(named: "StyledButtonText")
    }
    
    enum Images {
        static let trophy: UIImage = .image(named: "trophy")
        static let chevronRight: UIImage = .image(named: "chevron_right")
        static let upgradeCheckmarkImage: UIImage = .image(named: "UpgradeCheckmarkImage")
        static let campaignLaunch: UIImage = .image(named: "campaign_launch")
    }
    
    enum Timeouts {
        public static let snackbarMessageLongTimeout: TimeInterval = 5
    }
    
}
