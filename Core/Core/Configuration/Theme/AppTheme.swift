//
//  AppTheme.swift
//  Core
//
//  Created by Muhammad Tayyab Akram on 5/26/25.
//

public enum AppTheme: String {
    case system
    case light
    case dark

    public var analyticsValue: String {
        switch self {
        case .system:
            return "auto"
        case .light:
            return "light"
        case .dark:
            return "dark"
        }
    }
}
