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
    case getAllNotifications(page: Int)
    
    var path: String {
        switch self {
        case .getNotificationsCount:
            "/api/notifications/count"
        case .getAllNotifications:
            "/api/notifications/"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getNotificationsCount:
                .get
        case .getAllNotifications:
                .get
        }
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var task: HTTPTask {
        switch self {
        case .getNotificationsCount:
            return .request
        case let .getAllNotifications(page):
            var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
            let params: Parameters = [
                "app_name": "discussion",
                "page": page,
                "page_size": idiom == .pad ? 24 : 12
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
}
