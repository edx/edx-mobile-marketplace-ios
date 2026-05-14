//
//  FeatureManagerProtocol.swift
//  EDXFeatureManagement
//
//  Created by Muhammad Tayyab Akram on 4/7/25.
//

import Foundation
import WebKit

public enum FeatureKeys {
    public static let showCertificatePreview = "show_certificate_preview_ios"
}

/// A service that manages feature flagging, A/B testing, and user identification across different vendors.
public protocol FeatureManagerProtocol {
    /// Identifies the active user for feature evaluation and tracking.
    ///
    /// - Parameters:
    ///   - id: The unique user identifier.
    ///   - attributes: Optional user attributes such as country, age, or subscription type.
    func identifyUser(id: String, attributes: [String: Any]?)
    func identify(id: String, username: String?, email: String?)
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
    /// featureManager.trackEvent("purchase", properties: [
    ///     "value": 29.99,
    ///     "currency": "USD",
    ///     "productId": "abc123"
    /// ])
    /// ```
    ///
    /// - Note: Platforms that don't support metadata or value will gracefully ignore unsupported fields.
    func trackEvent(_ name: String, properties: [String: Any]?)

    func recordCertificatePreviewShownAttempt(forCourseId courseId: String)

    func attemptsSinceLastCertificatePreviewAndReset(forCourseId courseId: String) -> Int

    func trackAutoEvents(_ hosts: Set<String>)

    func enableWebViewTracking(_ webView: WKWebView, _ hosts: Set<URL>)

    func disableWebViewTracking(_ webView: WKWebView)

    func trackURLSession(_ delegateClass: NSObject.Type)
    func setTrackingConsent(granted: Bool)
}

public extension FeatureManagerProtocol {
    /// Identifies the active user for feature evaluation and tracking.
    ///
    /// - Parameters:
    ///   - id: The unique user identifier.
    func identifyUser(id: String) {
        identifyUser(id: id, attributes: nil)
    }

    /// Tracks a user-generated event.
    ///
    /// - Parameters:
    ///   - name: The unique name of the event to be tracked.
    func trackEvent(_ name: String) {
        trackEvent(name, properties: nil)
    }

    /// Tracks a user-generated event with a numeric value.
    ///
    /// - Parameters:
    ///   - name: The unique name of the event to be tracked.
    ///   - value: A `Double` that represents the numeric value of the event.
    ///
    /// - Note: Platforms that don't support value will gracefully ignore it.
    func trackEvent(_ name: String, value: Double) {
        trackEvent(name, properties: [
            "value": value
        ])
    }

    func identifyUser(id: String, attributes: [String: Any]?) {

    }

    func resetUser() {

    }

    func decision(forKey key: String) -> (any FeatureDecision)? {
        return nil
    }

    func recordCertificatePreviewShownAttempt(forCourseId courseId: String) {

    }

    func attemptsSinceLastCertificatePreviewAndReset(forCourseId courseId: String) -> Int {
        return 0
    }

    func trackAutoEvents(_ hosts: Set<String>) {

    }

    func trackEvent(_ name: String, properties: [String: Any]?) {

    }

    func enableWebViewTracking(_ webView: WKWebView, _ hosts: Set<URL>) {

    }

    func disableWebViewTracking(_ webView: WKWebView) {

    }

    func trackURLSession(_ delegateClass: NSObject.Type) {

    }

    func setTrackingConsent(granted: Bool) {

    }
}

#if DEBUG
public final class FeatureManagerMock: FeatureManagerProtocol {
    public var userID: String?
    public var userAttributes: [String: Any]?
    public var featureDecisions: [String: FeatureDecisionMock] = [:]

    public var trackedEvents: [(name: String, properties: [String: Any]?)] = []

    public init() { }

    public func identifyUser(id: String, attributes: [String: Any]?) {
        self.userID = id
        self.userAttributes = attributes
    }

    public func resetUser() {
        userID = nil
        userAttributes = nil
    }

    public func decision(forKey key: String) -> FeatureDecision? {
        guard let userID else { return nil }
        return featureDecisions[key]
    }

    public func trackEvent(_ name: String, properties: [String: Any]?) {
        trackedEvents.append((name: name, properties: properties))
    }

    public func recordCertificatePreviewShownAttempt(forCourseId courseId: String) {

    }

    public func attemptsSinceLastCertificatePreviewAndReset(forCourseId courseId: String) -> Int {
        return 1
    }

    public func trackAutoEvents(_ hosts: Set<String>) {

    }

    public func identify(id: String, username: String?, email: String?) {

    }

    public func enableWebViewTracking(_ webView: WKWebView, _ hosts: Set<URL>) {

    }

    public func disableWebViewTracking(_ webView: WKWebView) {

    }

    public func trackURLSession(_ delegateClass: NSObject.Type) {

    }

    public func setTrackingConsent(granted: Bool) {

    }
}
#endif
