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
    public let enrollmentDetail: EnrollmentDetail?
    public let coursewareAccess: CoursewareAccess?
    
    public init(
        id: String,
        discussionURL: String?,
        enrollmentDetail: EnrollmentDetail?,
        coursewareAccess: CoursewareAccess?
    ) {
        self.id = id
        self.discussionURL = discussionURL
        self.enrollmentDetail = enrollmentDetail
        self.coursewareAccess = coursewareAccess
    }
}
