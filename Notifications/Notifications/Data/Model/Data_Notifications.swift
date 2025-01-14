//
//  Data_Notifications.swift
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

public extension DataLayer {
    struct NotificationsPreferencesResponse: Codable {
        public let response: DiscussionPreferencesResponse
        
        enum CodingKeys: String, CodingKey {
            case response = "data"
        }
        
        public init(response: DiscussionPreferencesResponse) {
            self.response = response
        }
    }
    
    struct DiscussionPreferencesResponse: Codable {
        public let discussion: DiscussionPreferences
        
        enum CodingKeys: String, CodingKey {
            case discussion
        }
        
        public init(discussion: DiscussionPreferences) {
            self.discussion = discussion
        }
    }
    
    struct DiscussionPreferences: Codable {
        let enabled: Bool
        let notificationType: DiscussionNotificationsType
        
        enum CodingKeys: String, CodingKey {
            case enabled = "enabled"
            case notificationType = "notification_types"
        }
        
        init(
            enabled: Bool,
            notificationType: DiscussionNotificationsType
        ) {
            self.enabled = enabled
            self.notificationType = notificationType
        }
    }
    
    struct DiscussionNotificationsType: Codable {
        let core: DiscussionNotificationsTypeCore
        
        enum CodingKeys: String, CodingKey {
            case core
        }
        
        init(core: DiscussionNotificationsTypeCore) {
            self.core = core
        }
    }
        
    struct DiscussionNotificationsTypeCore: Codable {
        let push: Bool
        
        enum CodingKeys: String, CodingKey {
            case push
        }
        
        init(push: Bool) {
            self.push = push
        }
    }
}

public extension DataLayer.NotificationsPreferencesResponse {
    var domain: NotificationsPreferences {
        return NotificationsPreferences(
            discussionsEnabled: response.discussion.enabled,
            coreEnabled: response.discussion.notificationType.core.push
        )
    }
}

public extension DataLayer {
    struct NotificationsPreferencesUpdateResponse: Decodable {
        public let status: String
        public let response: NotificationsPreferencesUpdate
        
        enum CodingKeys: String, CodingKey {
            case status
            case response = "data"
        }
        
        public init(
            status: String,
            response: NotificationsPreferencesUpdate
        ) {
            self.status = status
            self.response = response
        }
    }
    
    struct NotificationsPreferencesUpdate: Decodable {
        public let updatedValue: Bool
        public let notificationType: String
        public let channel: String
        public let app: String
        
        enum CodingKeys: String, CodingKey {
            case updatedValue = "updated_value"
            case notificationType = "notification_type"
            case channel
            case app
        }
    }
}

public extension DataLayer.NotificationsPreferencesUpdateResponse {
    var domain: NotificationsPreferencesUpdate {
        return NotificationsPreferencesUpdate(
            status: status,
            updatedValue: response.updatedValue,
            notificationType: response.notificationType,
            channel: response.channel,
            app: response.app
        )
    }
}

public extension DataLayer {
    struct NotificationsSeenReadResponse: Decodable {
        let message: String
        
        enum CodingKeys: String, CodingKey {
            case message
        }
        
        public init(message: String) {
            self.message = message
        }
    }
}

public extension DataLayer.NotificationsSeenReadResponse {
    var domain: NotificationsSeenRead {
        return NotificationsSeenRead(message: message)
    }
}
