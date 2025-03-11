//
//  UIColor+SwiftUI.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import SwiftUI

extension UIColor {
    func swiftUI() -> SwiftUI.Color {
        Color(uiColor: self)
    }
    
    static func color(named: String) -> UIColor {
        guard let color = UIColor(named: named, in: .module, compatibleWith: nil) else {
            assertionFailure("UIColor with name `\(named)` doesn't exist")
            return UIColor()
        }
        return color
    }
}
