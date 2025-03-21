//
//  Payload.swift
//  OpenEdX
//
//  Created by Muhammad Tayyab Akram on 3/17/25.
//

import Foundation

enum PayloadKey: String {
    case screenName = "screen_name"
    case notificationDomain = "notification_domain"
    case notificationType = "notification_type"
    case notificationID = "notification_id"
    case pathID = "path_id"
    case courseID = "course_id"
    case topicID = "topic_id"
    case threadID = "thread_id"
    case responseID = "response_id"
    case commentID = "comment_id"
    case componentID = "component_id"
}

struct Payload {
    private let dictionary: [AnyHashable: Any]

    init(dictionary: [AnyHashable: Any]) {
        self.dictionary = dictionary
    }

    subscript(key: PayloadKey) -> String? {
        return dictionary[key.rawValue] as? String
    }
}
