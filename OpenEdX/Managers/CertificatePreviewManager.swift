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

final class CertificatePreviewManager: CertificatePreviewFeatureManaging, UserSessionManaging {
    private let featureManager: CertificatePreviewFeatureManager

    init(_ featureManager: CertificatePreviewFeatureManager) {
        self.featureManager = featureManager
    }

    // MARK: CertificatePreviewFeatureManaging

    func shouldShowCertificatePreview() -> Bool {
        featureManager.decision(forKey: FeatureKeys.showCertificatePreview)?.boolValue ?? false
    }

    func recordCertificatePreviewShownAttempt(forCourseId courseId: String) {
        featureManager.recordCertificatePreviewShownAttempt(forCourseId: courseId)
    }

    func attemptsSinceLastCertificatePreviewAndReset(forCourseId courseId: String) -> Int {
        featureManager.attemptsSinceLastCertificatePreviewAndReset(forCourseId: courseId)
    }

    func trackEvent(_ name: String, properties: [String: Any]?) {
        featureManager.trackEvent(name, properties: properties)
    }

    // MARK: UserSessionManaging

    func identifyUser(id: String) {
        featureManager.identifyUser(id: id, attributes: nil)
    }

    func resetUser() {
        featureManager.resetUser()
    }
}

