//
//  Data_EnrollmentDetails.swift
//  Course
//
//  Created by Shafqat Muneer on 5/18/25.
//

import Foundation
import Core

public extension DataLayer {
    struct EnrollmentDetails: Decodable {
        public let id: String
        public let coursewareAccessDetails: CoursewareAccessDetails?
        
        enum CodingKeys: String, CodingKey {
            case id
            case coursewareAccessDetails = "course_access_details"
        }
        
        public init(
            id: String,
            coursewareAccessDetails: CoursewareAccessDetails? = nil
        ) {
            self.id = id
            self.coursewareAccessDetails = coursewareAccessDetails
        }
        
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            id = try values.decode(String.self, forKey: .id)
            coursewareAccessDetails = try? values.decode(CoursewareAccessDetails.self, forKey: .coursewareAccessDetails)
        }
    }
}

public extension DataLayer.EnrollmentDetails {
    var domain: EnrollmentDetails {
        let coursewareAccess = coursewareAccessDetails?.coursewareAccess.map { access in
            var coursewareError: CourseAccessError?
            if let error = access.errorCode {
                coursewareError = CourseAccessError(rawValue: error.rawValue) ?? .unknown
            }
            
            return CoursewareAccess(
                hasAccess: access.hasAccess,
                errorCode: coursewareError,
                developerMessage: access.developerMessage,
                userMessage: access.userMessage,
                additionalContextUserMessage: access.additionalContextUserMessage,
                userFragment: access.userFragment
            )
        }
        
        return EnrollmentDetails(
            id: id,
            coursewareAccess: coursewareAccess
        )
    }
}
