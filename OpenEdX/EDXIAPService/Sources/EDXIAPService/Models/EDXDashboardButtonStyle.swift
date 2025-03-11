//
//  EDXDashboardButtonStyle.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import OEXFoundation
import SwiftUI

public struct EDXDashboardButtonStyle {
    public var backgroundColor: Color
    public var strokeColor: Color
    public var foregroundColor: Color
    public var titleFont: Font
    
    public init(
        backgroundColor: Color? = nil,
        strokeColor: Color? = nil,
        foregroundColor: Color? = nil,
        titleFont: Font? = nil
    ) {
        self.backgroundColor = backgroundColor ?? Assets.Colors.primaryCardCourseUpgradeBG.swiftUI()
        self.strokeColor = strokeColor ?? Assets.Colors.cardViewStroke.swiftUI()
        self.foregroundColor = foregroundColor ?? Assets.Colors.textPrimary.swiftUI()
        self.titleFont = titleFont ?? Fonts.titleSmall.swiftUI()
    }
}
