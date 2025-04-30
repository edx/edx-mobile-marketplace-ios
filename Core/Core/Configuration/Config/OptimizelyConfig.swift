//
//  OptimizelyConfig.swift
//  Core
//
//  Created by Muhammad Tayyab Akram on 4/10/25.
//

import Foundation

private enum OptimizelyKey {
    static let enabled = "ENABLED"
    static let sdkKey = "SDK_KEY"
}

public final class OptimizelyConfig: NSObject {
    public var enabled: Bool = false
    public var sdkKey: String = ""

    init(dictionary: [String: AnyObject]) {
        super.init()
        sdkKey = dictionary[OptimizelyKey.sdkKey] as? String ?? ""
        enabled = !sdkKey.isEmpty && dictionary[OptimizelyKey.enabled] as? Bool ?? false
    }
}

private let optimizelyKey = "OPTIMIZELY"

extension Config {
    public var optimizely: OptimizelyConfig {
        OptimizelyConfig(dictionary: self[optimizelyKey] as? [String: AnyObject] ?? [:])
    }
}
