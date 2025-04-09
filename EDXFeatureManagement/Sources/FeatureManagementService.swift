//
//  FeatureManagementService.swift
//  EDXFeatureManagement
//
//  Created by Muhammad Tayyab Akram on 4/7/25.
//

import Foundation

/// A service that manages feature flagging, A/B testing, and user identification across different vendors.
public protocol FeatureManagementService {
    /// Identifies the active user for feature evaluation and tracking.
    ///
    /// - Parameters:
    ///   - id: The unique user identifier.
    ///   - attributes: Optional user attributes such as country, age, or subscription type.
    func identifyUser(id: String, attributes: [String: Any]?)

    /// Resets the current user, clearing any associated data.
    ///
    /// - Note: This should be called upon logout to prevent data leakage between sessions.
    func resetUser()

    /// Evaluates a feature decision for a given key.
    ///
    /// The decision can return different types of values:
    /// - **Boolean (`true`/`false`)**: If the key represents a feature flag.
    /// - **String (`"A"`, `"B"`, etc.)**: If the key represents an A/B test variation.
    /// - **Numeric (`Int` / `Double`)**: If the key holds configuration values.
    ///
    /// - Parameter key: The identifier of the feature flag or experiment.
    /// - Returns: A `FeatureDecision` containing the evaluated value and associated metadata.
    func decision(forKey key: String) -> FeatureDecision?

    /// Tracks a user-generated event with optional parameters.
    ///
    /// - Parameters:
    ///   - name: The unique name of the event to be tracked.
    ///   - properties: A dictionary of additional information related to the event.
    ///
    /// ## Reserved Keys:
    /// - `"value"`: A `Double` that represents the numeric value of the event.
    ///
    /// ## Example:
    /// ```swift
    /// featureService.trackEvent("purchase", properties: [
    ///     "value": 29.99,
    ///     "currency": "USD",
    ///     "productId": "abc123"
    /// ])
    /// ```
    ///
    /// - Note: Platforms that don't support metadata or value will gracefully ignore unsupported fields.
    func trackEvent(_ name: String, properties: [String: Any]?)
}
