//
//  ProgramPurchaseConfig.swift
//  Core
//
//  Created by Sumanta Roy on 01/04/26.
//

import Foundation

public class ProgramPurchaseConfig: NSObject {

    private enum Keys: String {
        case enabled = "ENABLED"
        case sku = "SKU"
        case purchaseUrlHost = "PURCHASE_URL_HOST"
        case purchaseUrlPath = "PURCHASE_URL_PATH"
    }

    public var enabled: Bool
    public var sku: String
    public var purchaseUrlHost: String
    public var purchaseUrlPath: String

    init(dictionary: [String: Any]) {
        enabled = true//dictionary[Keys.enabled.rawValue] as? Bool ?? false
        sku = dictionary[Keys.sku.rawValue] as? String ?? ""
        purchaseUrlHost = dictionary[Keys.purchaseUrlHost.rawValue] as? String ?? ""
        purchaseUrlPath = dictionary[Keys.purchaseUrlPath.rawValue] as? String ?? ""
    }
}

private let programPurchaseConfigKey = "PROGRAM_PURCHASE"

extension Config {
    public var programPurchase: ProgramPurchaseConfig {
        ProgramPurchaseConfig(dictionary: dict(for: programPurchaseConfigKey) ?? [:])
    }
}
