//
//  CourseUpgradeEndpoint.swift
//  Core
//
//  Created by Saeed Bashir on 4/23/24.
//

import Foundation
import Alamofire

private let PaymentProcessor = "ios_iap"

enum CourseUpgradeEndpoint: EndPointType {
    case createOrder(
        courseRunKey: String,
        currencyCode: String,
        price: NSDecimalNumber,
        receipt: String
    )
    
    var path: String {
        switch self {
        case .createOrder:
            return "/iap/create-order/"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .createOrder:
            return .post
        }
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var baseURL: String {
        CourseUpgradeHandler.ecommerceURL
    }
    
    var task: HTTPTask {
        switch self {
        case let .createOrder(
            courseRunKey: courseRunKey,
            currencyCode: currencyCode,
            price: price,
            receipt: receipt
        ):
            let params: Parameters = [
                "course_run_key": courseRunKey,
                "currency_code": currencyCode,
                "price": price,
                "payment_processor": PaymentProcessor,
                "purchase_token": receipt
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        }
    }
}
