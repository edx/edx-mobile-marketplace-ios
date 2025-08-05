//
//  RecaptchaConfig.swift
//  Core
//
//  Created by Muhammad Tayyab  Akram on 7/28/25.
//

import Foundation

private enum RecaptchaKey {
    static let enabled = "ENABLED"
    static let siteKey = "SITE_KEY"
}

public final class RecaptchaConfig: NSObject {
    public var enabled: Bool = false
    public var siteKey: String = ""

    init(dictionary: [String: AnyObject]) {
        super.init()
        siteKey = dictionary[RecaptchaKey.siteKey] as? String ?? ""
        enabled = !siteKey.isEmpty && dictionary[RecaptchaKey.enabled] as? Bool ?? false
    }
}

private let recaptchaKey = "RECAPTCHA"

extension Config {
    public var recaptcha: RecaptchaConfig {
        RecaptchaConfig(dictionary: self[recaptchaKey] as? [String: AnyObject] ?? [:])
    }
}
