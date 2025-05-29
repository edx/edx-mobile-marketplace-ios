//
//  EDXFullfillParameters.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 30.05.25.
//
import Foundation

public struct EDXFullfillParameters {
    let backedID: Int
    let price: NSDecimalNumber
    let currencyCode: String
    let receipt: String
    
    public init(backedID: Int, price: NSDecimalNumber, currencyCode: String, receipt: String) {
        self.backedID = backedID
        self.price = price
        self.currencyCode = currencyCode
        self.receipt = receipt
    }
}
