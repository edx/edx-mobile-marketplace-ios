//
//  CertificatePreviewManager.swift
//  OpenEdX
//
//  Created by Sumanta Roy on 01/04/26.
//

import Foundation
import EDXFeatureManagement
import Core
import WebKit

// MARK: - Adapter

final class CertificatePreviewManager: CertificatePreviewManaging, UserSessionManaging {
    private let experimentManager: CertificatePreviewExperimentManager

    init(_ experimentManager: CertificatePreviewExperimentManager) {
        self.experimentManager = experimentManager
    }

    // MARK: CertificatePreviewManaging

    func shouldShowCertificatePreview() -> Bool {
        experimentManager.decision(forKey: FeatureKeys.showCertificatePreview)?.boolValue ?? false
    }

    func recordCertificatePreviewShownAttempt(forCourseId courseId: String) {
        experimentManager.recordCertificatePreviewShownAttempt(forCourseId: courseId)
    }

    func attemptsSinceLastCertificatePreviewAndReset(forCourseId courseId: String) -> Int {
        experimentManager.attemptsSinceLastCertificatePreviewAndReset(forCourseId: courseId)
    }

    func trackEvent(_ name: String, properties: [String: Any]?) {
        experimentManager.trackEvent(name, properties: properties)
    }

    // MARK: UserSessionManaging

    func identifyUser(id: String) {
        experimentManager.identifyUser(id: id, attributes: nil)
    }

    func resetUser() {
        experimentManager.resetUser()
    }
}

