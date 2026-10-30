//
//  CertificatePreviewFeatureManaging.swift
//  Core
//

import Foundation

public protocol CertificatePreviewFeatureManaging {
    func shouldShowCertificatePreview() -> Bool
    func recordCertificatePreviewShownAttempt(forCourseId courseId: String)
    func attemptsSinceLastCertificatePreviewAndReset(forCourseId courseId: String) -> Int
    func trackEvent(_ name: String, properties: [String: Any]?)
}

#if DEBUG
public struct CertificatePreviewFeatureManagingMock: CertificatePreviewFeatureManaging {
    public init() {}
    public func shouldShowCertificatePreview() -> Bool { false }
    public func recordCertificatePreviewShownAttempt(forCourseId courseId: String) {}
    public func attemptsSinceLastCertificatePreviewAndReset(forCourseId courseId: String) -> Int { 0 }
    public func trackEvent(_ name: String, properties: [String: Any]?) {}
}
#endif
