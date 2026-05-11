//
//  DatadogConfig.swift
//  Core
//
//  Created by Sumanta Roy on 09/02/26.
//

import Foundation

private enum DatadogKey {
    static let enabled = "ENABLED"
    static let appID = "DATADOG_APPLICATION_ID"
    static let clientToken = "DATADOG_CLIENT_TOKEN"
    static let environment = "DATADOG_ENVIRONMENT"
}

public final class DatadogConfig: NSObject {
    public var enabled: Bool = false
    public var appID = ""
    public var clientToken = ""
    public var environment = ""

    init(dictionary: [String: AnyObject]) {
        super.init()
        appID = dictionary[DatadogKey.appID] as? String ?? ""
        clientToken = dictionary[DatadogKey.clientToken] as? String ?? ""
        environment = dictionary[DatadogKey.environment] as? String ?? ""
        enabled = !appID.isEmpty && dictionary[DatadogKey.enabled] as? Bool ?? false
    }
}

private let datadogKey = "DATADOG"

extension Config {
    public var dataDog: DatadogConfig {
        DatadogConfig(dictionary: self[datadogKey] as? [String: AnyObject] ?? [:])
    }
}
