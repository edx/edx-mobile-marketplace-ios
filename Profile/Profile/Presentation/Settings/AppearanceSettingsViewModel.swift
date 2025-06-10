//
//  AppearanceSettingsViewModel.swift
//  Profile
//
//  Created by Muhammad Tayyab Akram on 5/23/25.
//

import Foundation
import Core

public final class AppearanceSettingsViewModel: ObservableObject {
    @Published private(set) var selectedMenu: AppearanceMenu

    private var themeManager: ThemeManagerProtocol
    private let router: ProfileRouter
    private let analytics: ProfileAnalytics

    public init(
        themeManager: ThemeManagerProtocol,
        router: ProfileRouter,
        analytics: ProfileAnalytics
    ) {
        self.themeManager = themeManager
        self.router = router
        self.analytics = analytics

        switch themeManager.currentTheme {
        case .light:
            selectedMenu = .lightMode
        case .dark:
            selectedMenu = .darkMode
        case .system:
            selectedMenu = .matchDevice
        }
    }

    func backButtonPressed() {
        router.back()
    }

    func menuSelected(_ menu: AppearanceMenu) {
        let oldTheme = themeManager.currentTheme
        let newTheme = menu.appTheme

        selectedMenu = menu
        themeManager.currentTheme = newTheme

        trackAppThemeChanged(to: newTheme, from: oldTheme)
    }

    private func trackAppThemeChanged(to newTheme: AppTheme, from oldTheme: AppTheme) {
        analytics.profileAppThemeChanged(
            newMode: newTheme.analyticsValue,
            previousMode: oldTheme.analyticsValue
        )
    }
}

enum AppearanceMenu: CaseIterable {
    case lightMode
    case darkMode
    case matchDevice

    var appTheme: AppTheme {
        switch self {
        case .lightMode:
            return .light
        case .darkMode:
            return .dark
        case .matchDevice:
            return .system
        }
    }

    var title: String {
        switch self {
        case .lightMode:
            return ProfileLocalization.Settings.appearanceLightMode
        case .darkMode:
            return ProfileLocalization.Settings.appearanceDarkMode
        case .matchDevice:
            return ProfileLocalization.Settings.appearanceMatchDevice
        }
    }

    var description: String? {
        switch self {
        case .lightMode, .darkMode:
            return nil
        case .matchDevice:
            return ProfileLocalization.Settings.appearanceMatchesDeviceSettings
        }
    }
}
