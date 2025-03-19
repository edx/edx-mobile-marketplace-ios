//
//  File.swift
//  EDXIAPService
//
//  Created by Anton Yarmolenka on 19/03/2025.
//

import SwiftUI

public struct MainColors {
    var accentColor: Color
    var whiteColor: Color
    var textPrimary: Color
    var background: Color
    
    public init(
        accentColor: Color? = nil,
        whiteColor: Color? = nil,
        textPrimary: Color? = nil,
        background: Color? = nil
    ) {
        self.accentColor = accentColor ?? Assets.Colors.accentColor.swiftUI()
        self.whiteColor = whiteColor ?? Assets.Colors.white.swiftUI()
        self.textPrimary = textPrimary ?? Assets.Colors.textPrimary.swiftUI()
        self.background = background ?? Assets.Colors.background.swiftUI()
    }
}
