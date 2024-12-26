//
//  Data_NotificationsCount.swift
//  Notifications
//
//  Created by Saeed Bashir on 12/17/24.
//

import Core

public extension DataLayer {
    struct NotificationsCountResponse: Codable {
        public let countByAppName: NotificationsCount
        
        enum CodingKeys: String, CodingKey {
            case countByAppName = "count_by_app_name"
        }
        
        public init(
            countByAppName: NotificationsCount
        ) {
            self.countByAppName = countByAppName
        }
    }
    
    struct NotificationsCount: Codable {
        var discussion: Int
        
        enum CodingKeys: String, CodingKey {
            case discussion
        }
        
        public init(discussion: Int, updates: Int, grading: Int) {
            self.discussion = discussion
        }
    }
}

public extension DataLayer.NotificationsCountResponse {
    var domain: NotificationsCount {
        return NotificationsCount(
            discussion: countByAppName.discussion
        )
    }
}
