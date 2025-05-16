//
//  OptimizelyFeatureManager.swift
//  EDXFeatureManagement
//
//  Created by Muhammad Tayyab Akram on 4/7/25.
//

import Foundation
import Optimizely

public final class OptimizelyFeatureManager: FeatureManagerProtocol {
    private let client: OptimizelyClient
    private var userContext: OptimizelyUserContext?

    private static var logLevel: OptimizelyLogLevel {
        #if DEBUG
        return .debug
        #else
        return .off
        #endif
    }

    public init(sdkKey: String) {
        self.client = OptimizelyClient(
            sdkKey: sdkKey,
            defaultLogLevel: Self.logLevel
        )
        self.client.start()
    }

    public func identifyUser(id: String, attributes: [String: Any]?) {
        userContext = client.createUserContext(userId: id, attributes: attributes)
    }

    public func resetUser() {
        userContext = nil
    }

    public func decision(forKey key: String) -> FeatureDecision? {
        guard let userContext else { return nil }

        let decision = userContext.decide(key: key)

        var metadata: [String: Any] = [
            MetadataKey.isEnabled: decision.enabled,
            MetadataKey.variables: decision.variables.toMap(),
            MetadataKey.reasons: decision.reasons
        ]
        if let variationKey = decision.variationKey {
            metadata[MetadataKey.variationKey] = variationKey
        }
        if let ruleKey = decision.ruleKey {
            metadata[MetadataKey.ruleKey] = ruleKey
        }

        return OptimizelyFeatureDecision(
            key: key,
            value: decision.enabled ? (metadata[MetadataKey.variationKey] ?? true) : false,
            metadata: metadata
        )
    }

    public func trackEvent(_ name: String, properties: [String: Any]?) {
        guard let userContext else { return }

        try? userContext.trackEvent(eventKey: name, eventTags: properties)
    }
}
