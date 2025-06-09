//
//  StoreProductInfo.swift
//  Core
//
//  Created by Vadim Kuznetsov on 22.05.24.
//

import Foundation

// NEEDS WORK: delete 'public' when moved all files to plugin
public struct StoreProductInfo: Sendable {
    var price: NSDecimalNumber
    var localizedPrice: String?
    var currencySymbol: String?
}
