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
    }
    
    enum Images {
        static let trophy: UIImage = .image(named: "trophy")
        static let chevronRight: UIImage = .image(named: "chevron_right")
    }
    
}
