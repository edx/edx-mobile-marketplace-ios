//
//  ThemeManagerProtocol.swift
//  Core
//
//  Created by Muhammad Tayyab Akram on 5/26/25.
//

import Foundation

public protocol ThemeManagerProtocol {
    var currentTheme: AppTheme { get set }

    func applySavedTheme()
}

// Mark - For testing and SwiftUI preview
#if DEBUG
public final class ThemeManagerMock: ThemeManagerProtocol {
    public var currentTheme: AppTheme = .system

    public init() {}
    public func applySavedTheme() {}
}
#endif
