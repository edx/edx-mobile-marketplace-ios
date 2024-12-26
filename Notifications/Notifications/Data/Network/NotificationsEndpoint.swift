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
    case getNotificationsCount
    
    var path: String {
        switch self {
        case .getNotificationsCount:
            "/api/notifications/count"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getNotificationsCount:
            .get
        }
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var task: HTTPTask {
        switch self {
        case .getNotificationsCount:
                .request
        }
    }
}
