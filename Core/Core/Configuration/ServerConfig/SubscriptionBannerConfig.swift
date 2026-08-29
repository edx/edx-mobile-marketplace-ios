//
//  SubscriptionBannerConfig.swift
//  Core
//
//  Created by Sumanta Roy on 27/07/26.

import Foundation

public class SubscriptionBannerConfig: NSObject {

    enum Keys: String, RawStringExtractable {
        case maxSessions = "max_sessions"
        case url = "url"
        case enabled = "subscription_banner_enabled"
    }

    private enum Defaults {
        static let maxSessions = 4
        static let enabled = false
    }

    public let maxSessions: Int
    public let url: URL?
    public let enabled: Bool

    init(dictionary: [String: Any]) {
        maxSessions = dictionary[Keys.maxSessions] as? Int ?? Defaults.maxSessions
        url = (dictionary[Keys.url] as? String).flatMap { URL(string: $0) }
        enabled = dictionary[Keys.enabled] as? Bool ?? Defaults.enabled
    }
}

private let Key = "subscription_banner"

extension ServerConfig {
    public var subscriptionBannerConfig: SubscriptionBannerConfig {
        return SubscriptionBannerConfig(dictionary: config[Key] as? [String: AnyObject] ?? [:])
    }
}
