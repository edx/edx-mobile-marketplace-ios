//
//  EnrollmentDetails.swift
//  Core
//
//  Created by Shafqat Muneer on 5/18/25.
//

import Foundation

public struct EnrollmentDetails: Hashable {
    public let id: String
    public let discussionURL: String?
    public let coursewareAccess: CoursewareAccess?
    
    public init(
        id: String,
        discussionURL: String?,
        coursewareAccess: CoursewareAccess?
    ) {
        self.id = id
        self.discussionURL = discussionURL
        self.coursewareAccess = coursewareAccess
    }
}
