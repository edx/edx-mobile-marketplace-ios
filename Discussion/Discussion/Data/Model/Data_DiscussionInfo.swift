//
//  Data_DiscussionInfo.swift
//  Discussion
//
//  Created by Eugene Yatsenko on 19.03.2024.
//

import Foundation
import Core

public extension DataLayer {
    struct DiscussionInfo: Codable {
        var isPostingEnabled: Bool?

        enum CodingKeys: String, CodingKey {
            case isPostingEnabled = "is_posting_enabled"
        }
    }
}

public extension DataLayer.DiscussionInfo {
    var domain: DiscussionInfo {
        .init(isPostingEnabled: isPostingEnabled)
    }
}
