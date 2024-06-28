//
//  CourseUpgradeUnlockView.swift
//  Core
//
//  Created by Saeed Bashir on 5/8/24.
//

import SwiftUI
import Theme

public struct CourseUpgradeUnlockView: View {
    @Environment(\.isHorizontal) var isHorizontal
    public init() {}
    
    public var body: some View {
        if isHorizontal {
            horizontalLayout
        } else {
            verticalLayout
        }
    }

    @ViewBuilder
    var verticalLayout: some View {
        ZStack(alignment: .center) {
            Theme.Colors.background
            VStack(spacing: 0) {
                VStack(spacing: 25) {
                    Spacer()
                    ThemeAssets.campaignLaunch.swiftUIImage
                        .resizable()
                        .frame(maxWidth: 125, maxHeight: 125)
                    
                    VStack(spacing: 0) {
                        Text(CoreLocalization.CourseUpgrade.unlockingText)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .font(Theme.Fonts.headlineSmall)
                            .padding(0)
                        Text(CoreLocalization.CourseUpgrade.unlockingFullAccess)
                            .foregroundColor(Theme.Colors.accentColor)
                            .font(Theme.Fonts.headlineSmall)
                            .fontWeight(.heavy)
                            .padding(0)
                        Text(CoreLocalization.CourseUpgrade.unlockingToCourse)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .font(Theme.Fonts.headlineSmall)
                            .padding(0)
                    }
                    .accessibilityIdentifier("unlock_text")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                ZStack {
                    ProgressBar(size: 45, lineWidth: 8)
                        .padding(20)
                        .accessibilityIdentifier("progressbar")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    var horizontalLayout: some View {
        ZStack(alignment: .center) {
            Theme.Colors.background
            VStack(spacing: 0) {
                VStack(spacing: 25) {
                    
                    ThemeAssets.campaignLaunch.swiftUIImage
                        .resizable()
                        .frame(maxWidth: 125, maxHeight: 125)
                    
                    VStack(spacing: 0) {
                        Text(CoreLocalization.CourseUpgrade.unlockingText)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .font(Theme.Fonts.headlineSmall)
                            .padding(0)
                        Text(CoreLocalization.CourseUpgrade.unlockingFullAccess)
                            .foregroundColor(Theme.Colors.accentColor)
                            .font(Theme.Fonts.headlineSmall)
                            .fontWeight(.heavy)
                            .padding(0)
                        Text(CoreLocalization.CourseUpgrade.unlockingToCourse)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .font(Theme.Fonts.headlineSmall)
                            .padding(0)
                    }
                    .accessibilityIdentifier("unlock_text")
                }
                ZStack {
                    ProgressBar(size: 45, lineWidth: 8)
                        .padding(20)
                        .accessibilityIdentifier("progressbar")
                }
            }
        }
        .ignoresSafeArea()
    }
}
