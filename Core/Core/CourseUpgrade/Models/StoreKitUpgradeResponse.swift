//
//  StoreKitUpgradeResponse.swift
//  Core
//
//  Created by Vadim Kuznetsov on 22.05.24.
//

import Foundation

public struct StoreKitUpgradeResponse {
    public var success: Bool
    public var receipt: String?
    public var error: UpgradeError?
}
