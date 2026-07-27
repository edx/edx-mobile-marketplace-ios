//
//  SubscriptionBannerConfig.swift
//  Core
//
//  Created by Sumanta Roy on 27/07/26.

import Foundation

public class SubscriptionBannerConfig: NSObject {

    enum Keys: String, RawStringExtractable {
        case maxSessions = "max_sessions"
        case link = "link"
    }

    private enum Defaults {
        static let maxSessions = 4
    }

    public let maxSessions: Int
    public let link: URL?

    init(dictionary: [String: Any]) {
        maxSessions = dictionary[Keys.maxSessions] as? Int ?? Defaults.maxSessions
        link = (dictionary[Keys.link] as? String).flatMap { URL(string: $0) }
    }
}

private let Key = "subscription_banner"

extension ServerConfig {
    public var subscriptionBannerConfig: SubscriptionBannerConfig {
        return SubscriptionBannerConfig(dictionary: config[Key] as? [String: AnyObject] ?? [:])
    }
}
