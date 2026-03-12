//
//  FeatureManager.swift
//  OpenEdX
//
//  Created by Sumanta Roy on 09/02/26.
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

final class DataDogFeatureManager: FeatureManagerProtocol, WebViewTrackingProtocol {
    private var dataDogManager: FeatureManagerProtocol?
    private(set) var config: ConfigProtocol!
    
    init(_ config: ConfigProtocol) {
        self.config = config
        if config.dataDog.enabled {
            dataDogManager = DatadogManager(appID: config.dataDog.appID,
                                            clientToken: config.dataDog.clientToken,
                                            environment: config.dataDog.environment)
        }
    }
    
    func trackAutoEvents(_ hosts: Set<String>) {
        if config?.dataDog.enabled ?? false {
            dataDogManager?.trackAutoEvents(hosts)
        }
    }
        
    func identify(id: String, username: String?, email: String?) {
        if config?.dataDog.enabled ?? false {
            dataDogManager?.identify(id: id, username: username, email: email)
        }
    }
    
    func trackEvent(_ name: String, properties: [String: Any]?) {
        if config?.dataDog.enabled ?? false {
            dataDogManager?.trackEvent(name, properties: properties)
        }
    }
    
    func enableWebViewTracking(_ webView: WKWebView, _ hosts: Set<URL>) {
        dataDogManager?.enableWebViewTracking(webView, hosts)
    }
    
    func disableWebViewTracking(_ webView: WKWebView) {
        dataDogManager?.disableWebViewTracking(webView)
    }
    
    func trackURLSession(_ delegateClass: NSObject.Type) {
        dataDogManager?.trackURLSession(delegateClass)
    }
}
