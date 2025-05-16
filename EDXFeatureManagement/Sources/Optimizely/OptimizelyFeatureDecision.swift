//
//  OptimizelyFeatureDecision.swift
//  EDXFeatureManagement
//
//  Created by Muhammad Tayyab Akram on 4/7/25.
//

public struct OptimizelyFeatureDecision: FeatureDecision {
    public let key: String
    public let value: Any?
    public let metadata: [String: Any]

    public var isEnabled: Bool {
        return metadata[MetadataKey.isEnabled] as? Bool ?? false
    }

    public var variationKey: String? {
        return metadata[MetadataKey.variationKey] as? String
    }

    public var variables: [String: Any] {
        return (metadata[MetadataKey.variables] as? [String: Any]) ?? [:]
    }

    public var ruleKey: String? {
        return metadata[MetadataKey.ruleKey] as? String
    }

    public var reasons: [String] {
        return (metadata[MetadataKey.reasons] as? [String]) ?? []
    }
}
