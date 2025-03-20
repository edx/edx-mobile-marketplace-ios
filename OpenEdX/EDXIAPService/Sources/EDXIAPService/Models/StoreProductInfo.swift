//
//  StoreProductInfo.swift
//  Core
//
//  Created by Vadim Kuznetsov on 22.05.24.
//

import Foundation

struct StoreProductInfo: Sendable {
    var price: NSDecimalNumber
    var localizedPrice: String?
    var currencySymbol: String?
}
