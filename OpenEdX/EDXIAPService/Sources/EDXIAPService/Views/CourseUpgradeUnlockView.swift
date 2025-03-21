//
//  CourseUpgradeUnlockView.swift
//  Core
//
//  Created by Saeed Bashir on 5/8/24.
//

import SwiftUI

public struct CourseUpgradeUnlockView: View {
    @Environment(\.isHorizontal) var isHorizontal
    
    private let style: EDXIAPStyle
    
    init(style: EDXIAPStyle) {
        self.style = style
    }
    
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
            style.colors.background
            VStack(spacing: 0) {
                VStack(spacing: 25) {
                    Spacer()
                    Assets.Images.campaignLaunch.swiftUI()
                        .resizable()
                        .frame(maxWidth: 125, maxHeight: 125)
                    
                    VStack(spacing: 0) {
                        Text(Texts.UpgradeInfo.unlockingText)
                            .foregroundColor(style.colors.textPrimary)
                            .font(Fonts.headlineSmall.swiftUI())
                            .padding(0)
                        Text(Texts.UpgradeInfo.unlockingFullAccess)
                            .foregroundColor(style.colors.accentColor)
                            .font(Fonts.headlineSmall.swiftUI())
                            .fontWeight(.heavy)
                            .padding(0)
                        Text(Texts.UpgradeInfo.unlockingToCourse)
                            .foregroundColor(style.colors.textPrimary)
                            .font(Fonts.headlineSmall.swiftUI())
                            .padding(0)
                    }
                    .accessibilityIdentifier("unlock_text")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                ZStack {
                    ProgressBar(size: 45, lineWidth: 8, accentColor: style.colors.accentColor)
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
            style.colors.background
            VStack(spacing: 0) {
                VStack(spacing: 25) {
                    
                    Assets.Images.campaignLaunch.swiftUI()
                        .resizable()
                        .frame(maxWidth: 125, maxHeight: 125)
                    
                    VStack(spacing: 0) {
                        Text(Texts.UpgradeInfo.unlockingText)
                            .foregroundColor(style.colors.textPrimary)
                            .font(Fonts.headlineSmall.swiftUI())
                            .padding(0)
                        Text(Texts.UpgradeInfo.unlockingFullAccess)
                            .foregroundColor(style.colors.accentColor)
                            .font(Fonts.headlineSmall.swiftUI())
                            .fontWeight(.heavy)
                            .padding(0)
                        Text(Texts.UpgradeInfo.unlockingToCourse)
                            .foregroundColor(style.colors.textPrimary)
                            .font(Fonts.headlineSmall.swiftUI())
                            .padding(0)
                    }
                    .accessibilityIdentifier("unlock_text")
                }
                ZStack {
                    ProgressBar(size: 45, lineWidth: 8, accentColor: style.colors.accentColor)
                        .padding(20)
                        .accessibilityIdentifier("progressbar")
                }
            }
        }
        .ignoresSafeArea()
    }
}

#if DEBUG
#Preview {
    CourseUpgradeUnlockView(style: EDXIAPStyle.init())
}
#endif
