//
//  FullfillCheckoutRequest.swift
//  EDXIAPService
//
//  Created by Anton Yarmolenka on 08/04/2025.
//

import Foundation

struct FullfillCheckoutRequest: EDXDataRequest {
    typealias Response = EDXReceiptStatus
    
    var url: String
    
    var method: HTTPMethod = .post
    
    var queryItems: [String: String]
    
    init(parameters: EDXFullfillParameters) {
        self.queryItems = [
            "basket_id": "\(parameters.backedID)",
            "price": "\(parameters.price)",
            "currency_code": parameters.currencyCode,
            "purchase_token": parameters.receipt,
            "payment_processor": BaseConfig.prodURL.rawValue
        ]
        self.url = "\(BaseConfig.prodURL.rawValue)/api/iap/v1/execute/"
    }
    
    func decode(_ data: Data) throws -> EDXReceiptStatus {
        let decoder = JSONDecoder()
        let response = try decoder.decode(EDXReceiptStatus.self, from: data)
        return response
    }
}
