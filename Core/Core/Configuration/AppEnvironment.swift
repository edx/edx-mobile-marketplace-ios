//
//  AppEnvironment.swift
//  Core
//
//  Created by Muhammad Tayyab Akram on 1/16/25.
//

import Foundation

public enum AppEnvironment {
    public static var isPreview: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        return false
        #endif
    }
}
