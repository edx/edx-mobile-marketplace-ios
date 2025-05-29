//
//  EDXBasket.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 30.05.25.
//

struct EDXBasket: Sendable, Decodable {
    let success: String
    let basketID: Int
    
    public init(success: String, basketID: Int) {
        self.success = success
        self.basketID = basketID
    }
}
