//
//  EDXReceiptStatus.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 30.05.25.
//

struct EDXReceiptStatus: Sendable, Decodable {
    let status: String
    
    public init(status: String) {
        self.status = status
    }
}
