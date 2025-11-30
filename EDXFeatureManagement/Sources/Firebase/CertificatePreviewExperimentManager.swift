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
}

public final class CertificateExperimentAssignmentStore: ExperimentAssignmentStore {
    private let key = "exp.show_certificate_preview"
    public init() {}
    public var showCertificatePreview: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

public struct FirebaseFeatureDecision: FeatureDecision {
    public let key: String
    public let value: Any?
    public let metadata: [String: Any]
}

public final class CertificatePreviewExperimentManager: FeatureManagerProtocol {
    private var assignmentStore: ExperimentAssignmentStore
    private var analytics: AnalyticsTracking

    public init(assignmentStore: ExperimentAssignmentStore, analytics: AnalyticsTracking) {
        self.assignmentStore = assignmentStore
        self.analytics = analytics
    }

    public func identifyUser(id: String, attributes: [String: Any]?) {
        guard let intId = Int(id) else { return }
        let inTreatment = intId % 2 == 0
        assignmentStore.showCertificatePreview = inTreatment
    }

    public func resetUser() {
        assignmentStore.showCertificatePreview = false
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
}
