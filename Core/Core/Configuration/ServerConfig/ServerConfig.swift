//
//  ServerConfig.swift
//  Core
//
//  Created by Saeed Bashir on 4/29/24.
//

import Foundation

private enum Keys: String, RawStringExtractable {
    case valuePropEnabled = "value_prop_enabled"
    case feedbackFormURL = "feedback_form_url"
}

public protocol ServerConfigProtocol {
    var valuePropEnabled: Bool { get }
    var iapConfig: IAPConfig { get }
    func initialize(serverConfig: String?)
    var feedbackURL: URL? { get }
    var subscriptionBannerConfig: SubscriptionBannerConfig { get }
}

public class ServerConfig: ServerConfigProtocol {
    var config: [String: Any] = [:]
    
    public init () {}
    
    public func initialize(serverConfig: String?) {
        guard let serverConfig = serverConfig,
                let configData = serverConfig.data(using: .utf8),
              let config = try? JSONSerialization.jsonObject(with: configData, options: []) as? [String: Any]
        else { return }
        
        self.config = config
    }
    
    public var valuePropEnabled: Bool {
        config[Keys.valuePropEnabled] as? Bool ?? false
    }
    
    public var feedbackURL: URL? {
        (config[Keys.feedbackFormURL] as? String).flatMap { URL(string: $0)}
    }
}

// Mark - For testing and SwiftUI preview
// swiftlint:disable all
#if DEBUG
public class ServerConfigProtocolMock: ServerConfigProtocol {
    
    let configString = "{\"iap_config\":{\"enabled\":true,\"experiment_enabled\":false,\"restore_enabled\":true,\"android_product_prefix\":\"mobile.android.usd\",\"ios_product_prefix\":\"mobile.ios.usd\",\"allowed_users\":[\"all_users\"]},\"value_prop_enabled\":true,\"feedback_form_url\":\"https://bit.ly/edx-apps-feedback\",\"disabled_countries\":[\"RU\"],\"course_dates_calendar_sync\":{\"ios\":{\"enabled\":true,\"self_paced_enabled\":true,\"instructor_paced_enabled\":true,\"deep_links_enabled\":true},\"android\":{\"enabled\":true,\"self_paced_enabled\":true,\"instructor_paced_enabled\":true,\"deep_links_enabled\":true}},\"subscription_banner\":{\"max_sessions\":4,\"url\":\"https://bit.ly/edx-apps-subscriptions\",\"subscription_banner_enabled\":true}}"

    var config: [String: Any] = [:]
    
    public var valuePropEnabled: Bool
    
    public var iapConfig: IAPConfig
    
    public func initialize(serverConfig: String?) {
        
    }
    
    public var feedbackURL: URL?

    public var subscriptionBannerConfig: SubscriptionBannerConfig

    public init() {
        valuePropEnabled = false
        iapConfig = IAPConfig(dictionary: ["enabled": true, "restore_enabled": true, "ios_product_prefix": "mobile.ios.usd"])
        subscriptionBannerConfig = SubscriptionBannerConfig(
            dictionary: [
                "max_sessions": 4,
                "url": "https://bit.ly/edx-apps-subscriptions",
                "subscription_banner_enabled": true
            ]
        )
        initialize(serverConfig: configString)
    }
}
#endif
// swiftlint:enable all
