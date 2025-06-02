//
//  DiscussionInfo.swift
//  Discussion
//
//  Created by Eugene Yatsenko on 19.03.2024.
//

import Foundation

public struct DiscussionInfo {
    public var id: String?
    public var isPostingEnabled: Bool?
    public var blackouts: [DiscussionBlackout]?

    public func isBlackedOut() -> Bool {
        guard let isPostingEnabled else {
            return false
        }

        return !isPostingEnabled
    }
}
