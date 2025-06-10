//
//  ThemeManager.swift
//  Core
//
//  Created by Muhammad Tayyab Akram on 5/26/25.
//

import UIKit

public final class ThemeManager: ThemeManagerProtocol {
    private var storage: CoreStorage

    public init(storage: CoreStorage) {
        self.storage = storage
    }

    public var currentTheme: AppTheme {
        get {
            return storage.selectedTheme ?? .system
        }
        set {
            storage.selectedTheme = newValue
            applyTheme(newValue)
        }
    }

    public func applySavedTheme() {
        applyTheme(currentTheme)
    }

    private func applyTheme(_ theme: AppTheme) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        for window in windowScene.windows {
            switch theme {
            case .system:
                window.overrideUserInterfaceStyle = .unspecified
            case .light:
                window.overrideUserInterfaceStyle = .light
            case .dark:
                window.overrideUserInterfaceStyle = .dark
            }
        }
    }
}
