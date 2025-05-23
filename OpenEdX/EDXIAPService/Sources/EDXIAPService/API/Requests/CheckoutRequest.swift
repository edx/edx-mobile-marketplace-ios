//
//  CheckoutRequest.swift
//  EDXIAPService
//
//  Created by Anton Yarmolenka on 08/04/2025.
//

import Foundation

struct CheckoutRequest: EDXDataRequest {
    typealias Response = String
    
    var url: String
    
    var method: HTTPMethod = .post
    
    var basketID: Int
    
    var queryItems: [String: String]
    
    init(basketID: Int, ecommerceURL: String, paymentProcessor: String) {
        self.basketID = basketID
        self.url = "\(ecommerceURL)/api/iap/v1/checkout/"
        self.queryItems = [
            "basket_id": "\(basketID)",
            "payment_processor": paymentProcessor
        ]
    }
}
