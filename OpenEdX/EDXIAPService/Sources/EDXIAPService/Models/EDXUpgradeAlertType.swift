//
//  EDXUpgradeAlertType.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 29.05.25.
//

public enum EDXUpgradeAlertType: String {
    case priceFetch = "price_fetch"
    case basket
    case checkout
    case payment
    case execute
    case restore
    case unfulfilled
    case unknown
}
