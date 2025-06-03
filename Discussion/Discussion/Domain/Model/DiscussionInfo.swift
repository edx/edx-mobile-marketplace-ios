//
//  DiscussionInfo.swift
//  Discussion
//
//  Created by Eugene Yatsenko on 19.03.2024.
//

import Foundation

public struct DiscussionInfo {
    public var isPostingEnabled: Bool?

    public var isBlackedOut: Bool {
        isPostingEnabled == false
    }
}
