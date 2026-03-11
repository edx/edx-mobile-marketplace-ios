//
//  CertificatePreviewExperimentManager.swift
//  EDXFeatureManagement
//
//  Created by Sumanta Roy on 30/11/25.
//

import Foundation

public protocol AnalyticsTracking {
    func logEvent(_ name: String, parameters: [String: Any]?)
}

public protocol ExperimentAssignmentStore {
    var showCertificatePreview: Bool { get  set}
    func incrementAttempts(forCourseId courseId: String)
    func takeAndResetAttempts(forCourseId courseId: String) -> Int
    func resetAllCertificatePreviewAttempts()
}

public final class CertificateExperimentAssignmentStore: ExperimentAssignmentStore {
    private let key = "exp.show_certificate_preview"
    private let attemptsRegistryKey = "exp.show_certificate_preview.attempts.registry"
    public init() {}
    public var showCertificatePreview: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    // MARK: - Per-course attempts
    public func incrementAttempts(forCourseId courseId: String) {
        let key = attemptsKey(courseId: courseId)
        let current = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(current + 1, forKey: key)
        addCourseIdToRegistry(courseId)
    }

    public func takeAndResetAttempts(forCourseId courseId: String) -> Int {
        let key = attemptsKey(courseId: courseId)
        let attempts = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(0, forKey: key)
        addCourseIdToRegistry(courseId)
        return attempts
    }

    public func resetAllCertificatePreviewAttempts() {
        let registry = courseIdRegistry()
        guard !registry.isEmpty else { return }
        registry.forEach { courseId in
            let key = attemptsKey(courseId: courseId)
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.removeObject(forKey: attemptsRegistryKey)
    }

    // MARK: - Private

    private func attemptsKey(courseId: String) -> String {
        return "\(key).attempts.\(courseId)"
    }

    // Maintain a registry of course IDs that have attempts counters
    private func addCourseIdToRegistry(_ courseId: String) {
        var set = courseIdRegistry()
        if !set.contains(courseId) {
            set.insert(courseId)
            UserDefaults.standard.set(Array(set), forKey: attemptsRegistryKey)
        }
    }

    private func courseIdRegistry() -> Set<String> {
        let arr = UserDefaults.standard.array(forKey: attemptsRegistryKey) as? [String] ?? []
        return Set(arr)
    }
}

public struct FirebaseFeatureDecision: FeatureDecision {
    public let key: String
    public let value: Any?
    public let metadata: [String: Any]
}

public final class CertificatePreviewExperimentManager: FeatureManagerProtocol {
    public func identify(id: String, username: String?, email: String?) {
        
    }
    
    private var assignmentStore: ExperimentAssignmentStore
    private var analytics: AnalyticsTracking

    public init(assignmentStore: ExperimentAssignmentStore, analytics: AnalyticsTracking) {
        self.assignmentStore = assignmentStore
        self.analytics = analytics
    }

    public func identifyUser(id: String, attributes: [String: Any]?) {
        guard let intId = Int(id) else { return }
        let inTreatment = intId % 2 != 0
        assignmentStore.showCertificatePreview = inTreatment
    }

    public func resetUser() {
        assignmentStore.showCertificatePreview = false
        assignmentStore.resetAllCertificatePreviewAttempts()
    }

    public func decision(forKey key: String) -> FeatureDecision? {
        switch key {
        case FeatureKeys.showCertificatePreview:
            let value = assignmentStore.showCertificatePreview
            return FirebaseFeatureDecision(
                key: key,
                value: value,
                metadata: [:]
            )
        default:
            return nil
        }
    }

    public func trackEvent(_ name: String, properties: [String: Any]?) {
        analytics.logEvent(name, parameters: properties)
    }
        
    public func recordCertificatePreviewShownAttempt(forCourseId courseId: String) {
        assignmentStore.incrementAttempts(forCourseId: courseId)
    }
    
    public func attemptsSinceLastCertificatePreviewAndReset(forCourseId courseId: String) -> Int {
        assignmentStore.takeAndResetAttempts(forCourseId: courseId)
    }
}
