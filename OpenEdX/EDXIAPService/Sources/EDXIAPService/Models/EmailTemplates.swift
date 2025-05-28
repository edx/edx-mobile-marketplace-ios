//
//  EmailTemplates.swift
//  EDXIAPService
//
//  Created by Anton Yarmolenka on 27/05/2025.
//

import Foundation
import UIKit

struct EmailTemplates {
    @MainActor
    public static func contactSupport(email: String, emailSubject: String, errorMessage: String? = nil) -> URL? {
        let osVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let deviceModel = UIDevice.current.model
        let feedbackDetails = "OS version: \(osVersion)\nApp version: \(appVersion)\nDevice model: \(deviceModel)"
        
        var emailBody = "\n\n\(feedbackDetails)\n"
        
        if let errorMessage {
            emailBody.append(errorMessage)
        }
        
        let emailURL = URL(string: "mailto:\(email)?subject=\(emailSubject)&body=\(emailBody)")
        
        return emailURL
    }
}
