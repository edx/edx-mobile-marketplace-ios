//
//  Data_NotificationsCountByApp.swift
//  Notifications
//
//  Created by Saeed Bashir on 12/17/24.
//

import Core

public extension DataLayer {
    struct NotificationsCountByAppResponse: Codable {
        public let countByAppName: NotificationsCountByApp
        
        enum CodingKeys: String, CodingKey {
            case countByAppName = "count_by_app_name"
        }
        
        public init(
            countByAppName: NotificationsCountByApp
        ) {
            self.countByAppName = countByAppName
        }
    }
    
    struct NotificationsCountByApp: Codable {
        var discussion: Int
        var updates: Int
        var grading: Int
        
        enum CodingKeys: String, CodingKey {
            case discussion
            case updates
            case grading
        }
        
        public init(discussion: Int, updates: Int, grading: Int) {
            self.discussion = discussion
            self.updates = updates
            self.grading = grading
        }
    }
}

public extension DataLayer.NotificationsCountByAppResponse {
    var domain: NotificationsCountByApp {
        return NotificationsCountByApp(
            discussion: countByAppName.discussion,
            updates: countByAppName.updates,
            grading: countByAppName.grading
        )
    }
}
