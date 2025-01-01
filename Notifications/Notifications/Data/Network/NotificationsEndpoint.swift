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
    case getPreferences
    case updatePreferences(value: Bool)
    
    var path: String {
        switch self {
        case .getNotificationsCount:
            "/api/notifications/count"
        case .getPreferences:
            "/api/notifications/configurations"
        case .updatePreferences:
            "/api/notifications/preferences/update-all/"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getNotificationsCount:
                .get
        case .getPreferences:
                .get
        case .updatePreferences:
                .post
        }
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var task: HTTPTask {
        switch self {
        case .getNotificationsCount:
            return .request
        case .getPreferences:
                return .request
        case let .updatePreferences(value):
            let params: [String: Any] = [
                "notification_app": "discussion",
                "notification_type": "core",
                "notification_channel": "push",
                "value": value
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        }
    }
}
