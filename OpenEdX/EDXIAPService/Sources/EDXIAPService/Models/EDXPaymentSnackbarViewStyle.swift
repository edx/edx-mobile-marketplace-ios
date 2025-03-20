//
//  EDXPaymentSnackbarViewStyle.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import OEXFoundation
import SwiftUI

public struct EDXPaymentSnackbarViewStyle {
    public let stroke: Color
    public let background: Color
    
    public init(stroke: Color? = nil, background: Color? = nil) {
        self.stroke = stroke ?? Assets.Colors.datesSectionStroke.swiftUI()
        self.background = background ?? Assets.Colors.datesSectionBackground.swiftUI()
    }
}
