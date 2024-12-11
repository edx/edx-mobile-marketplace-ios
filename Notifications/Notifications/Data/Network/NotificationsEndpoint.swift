//
//  NotificationsEndpoint.swift
//  Notifications
//
//  Created by Saeed Bashir on 11.12.2024.
//

import Foundation
import Core
import Alamofire

enum NotificationsEndpoint: EndPointType {
    var path: String {
        return ""
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var task: HTTPTask {
        let params: [String: Encodable] = [:]
        return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
    }
}
