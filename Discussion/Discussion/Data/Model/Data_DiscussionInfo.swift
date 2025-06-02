//
//  Data_DiscussionInfo.swift
//  Discussion
//
//  Created by Eugene Yatsenko on 19.03.2024.
//

import Foundation
import Core

public struct DiscussionBlackout {
    var start: String
    var end: String
}

public extension DataLayer {
    struct DiscussionInfo: Codable {
        var id: String?
        var isPostingEnabled: Bool?
        var blackouts: [DiscussionBlackout]?

        enum CodingKeys: String, CodingKey {
            case id
            case isPostingEnabled = "is_posting_enabled"
            case blackouts
        }
    }

    struct DiscussionBlackout: Codable {
        var start: String
        var end: String
    }
}

public extension DataLayer.DiscussionInfo {
    var domain: DiscussionInfo {
        .init(
            id: id,
            isPostingEnabled: isPostingEnabled,
            blackouts: blackouts?.compactMap { .init(start: $0.start, end: $0.end)  }
        )
    }
}
