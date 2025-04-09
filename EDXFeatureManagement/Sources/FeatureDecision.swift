//
//  FeatureDecision.swift
//  EDXFeatureManagement
//
//  Created by Muhammad Tayyab Akram on 4/7/25.
//

import Foundation

/// A vendor-agnostic abstraction representing the result of a feature flag evaluation or experiment decision.
public protocol FeatureDecision {
    /// The unique key representing the feature flag or experiment.
    var key: String { get }

    /// The resolved value from the decision service.
    ///
    /// This could be:
    /// - A `Bool` for a feature flag (e.g., `true` if enabled).
    /// - A `String` for experiment variations (e.g., `"A"`, `"B"`).
    /// - A `Double` or `Int` for configuration values.
    var value: Any? { get }

    /// Any vendor-specific metadata, such as variables or explanation for the decision.
    var metadata: [String: Any] { get }
}
