//
//  Data_Upgrade.swift
//  Core
//
//  Created by Saeed Bashir on 4/23/24.
//

import Foundation

public extension DataLayer {
    struct FulfillOrder: Codable {
        let orderId: String
        let orderNumber: String
        
        enum CodingKeys: String, CodingKey {
            case orderId = "order_id"
            case orderNumber = "order_number"
        }
        
        public init(orderId: String, orderNumber: String) {
            self.orderId = orderId
            self.orderNumber = orderNumber
        }
    }
}

public extension DataLayer.FulfillOrder {
    var domain: FulfillOrder {
        FulfillOrder(orderId: orderId, orderNumber: orderNumber)
    }
}
