//
//  AddBasketRequest.swift
//  EDXIAPService
//
//  Created by Anton Yarmolenka on 08/04/2025.
//

import Foundation

struct AddBasketRequest: EDXDataRequest {
    typealias Response = EDXBasket
    
    var url: String
    
    var method: HTTPMethod = .get
    
    var sku: String
    
    public init(sku: String) {
        self.sku = sku
        self.url = "\(BaseConfig.prodURL.rawValue)/api/iap/v1/basket/add/?sku=\(sku)"
    }
    
    func decode(_ data: Data) throws -> EDXBasket {
        let decoder = JSONDecoder()
        let response = try decoder.decode(EDXBasket.self, from: data)
        return response
    }
}
