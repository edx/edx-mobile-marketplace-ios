//
//  DatadogConfig.swift
//  Core
//
//  Created by Sumanta Roy on 09/02/26.
//


import Foundation

private enum DatadogKey {
    static let enabled = "ENABLED"
    static let appID = "77b5731a-3143-44ad-8dfe-b1e6dcf88ab8"
    static let clientToken = "pub139dbaa28acbc5ce5eedb91a35ea8c54"
    static let environment = "stage"
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

private let datadogKey = "DATADOGKEY"

extension Config {
    public var dataDog: DatadogConfig {
        DatadogConfig(dictionary: self[datadogKey] as? [String: AnyObject] ?? [:])
    }
}
