//
//  LiveChatConfig.swift
//  Core
//
//  Created by Anton Yarmolenka on 19/09/2024.
//

import Foundation

private enum Keys: String, RawStringExtractable {
    case enabled = "ENABLED"
    case xpertKey = "XPERTKEY"
    case useCase = "USECASE"
    case segmentKey = "SEGMENTKEY"
}

public final class LiveChatConfig {
    public var enabled: Bool = false
    public var xpertKey: String = ""
    public var useCase: String = ""
    public var segmentKey: String = ""
    
    init(dictionary: [String: AnyObject]) {
        xpertKey = dictionary[Keys.xpertKey] as? String ?? ""
        useCase = dictionary[Keys.useCase] as? String ?? ""
        segmentKey = dictionary[Keys.segmentKey] as? String ?? ""
        enabled = dictionary[Keys.enabled] as? Bool ?? false
    }
}

private let configKey = "XPERT_FIVE9"
extension Config {
    public var liveChat: LiveChatConfig {
        LiveChatConfig(dictionary: self[configKey] as? [String: AnyObject] ?? [:])
    }
}
