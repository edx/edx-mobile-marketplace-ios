//
//  Colors.swift
//  EDXIAPService
//
//  Created by Anton Yarmolenka on 19/03/2025.
//

import SwiftUI

public struct Colors {
    var accentColor: Color
    var accentButtonColor: Color
    var whiteColor: Color
    var textPrimary: Color
    var styledButtonText: Color
    var background: Color
    var cardViewStroke: Color
    var primaryCardCourseUpgradeBG: Color
    var datesSectionStroke: Color
    var datesSectionBackground: Color
    
    public init(
        accentColor: Color? = nil,
        accentButtonColor: Color? = nil,
        whiteColor: Color? = nil,
        textPrimary: Color? = nil,
        styledButtonText: Color? = nil,
        background: Color? = nil,
        cardViewStroke: Color? = nil,
        primaryCardCourseUpgradeBG: Color? = nil,
        datesSectionStroke: Color? = nil,
        datesSectionBackground: Color? = nil
    ) {
        self.accentColor = accentColor ?? Assets.Colors.accentColor.swiftUI()
        self.accentButtonColor = accentButtonColor ?? Assets.Colors.accentButtonColor.swiftUI()
        self.whiteColor = whiteColor ?? Assets.Colors.white.swiftUI()
        self.textPrimary = textPrimary ?? Assets.Colors.textPrimary.swiftUI()
        self.styledButtonText = styledButtonText ?? Assets.Colors.styledButtonText.swiftUI()
        self.background = background ?? Assets.Colors.background.swiftUI()
        self.cardViewStroke = cardViewStroke ?? Assets.Colors.cardViewStroke.swiftUI()
        self.primaryCardCourseUpgradeBG = primaryCardCourseUpgradeBG ??
        Assets.Colors.primaryCardCourseUpgradeBG.swiftUI()
        self.datesSectionStroke = datesSectionStroke ?? Assets.Colors.datesSectionStroke.swiftUI()
        self.datesSectionBackground = datesSectionBackground ?? Assets.Colors.datesSectionBackground.swiftUI()
    }
}
