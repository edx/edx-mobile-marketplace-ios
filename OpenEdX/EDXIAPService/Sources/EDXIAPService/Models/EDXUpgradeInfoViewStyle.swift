//
//  EDXUpgradeInfoViewStyle.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import OEXFoundation
import SwiftUI

public struct EDXUpgradeInfoViewStyle {
    public let backgroundColor: Color
    
    public init(backgroundColor: Color? = nil) {
        self.backgroundColor = backgroundColor ?? Assets.Colors.background.swiftUI()
    }
}
