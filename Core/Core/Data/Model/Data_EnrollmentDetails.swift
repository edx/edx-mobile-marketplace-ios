//
//  Data_EnrollmentDetails.swift
//  Course
//
//  Created by Shafqat Muneer on 5/18/25.
//

import Foundation

public extension DataLayer {
    struct EnrollmentDetails: Decodable {
        public let id: String
        public let discussionURL: String?
        public let enrollmentMetadata: EnrollmentMetadata?
        public let coursewareAccessDetails: CoursewareAccessDetails?
        
        enum CodingKeys: String, CodingKey {
            case id
            case discussionURL = "discussion_url"
            case enrollmentMetadata = "enrollment_details"
            case coursewareAccessDetails = "course_access_details"
        }
        
        public init(
            id: String,
            discussionURL: String? = nil,
            enrollmentMetadata: EnrollmentMetadata? = nil,
            coursewareAccessDetails: CoursewareAccessDetails? = nil
        ) {
            self.id = id
            self.discussionURL = discussionURL
            self.enrollmentMetadata = enrollmentMetadata
            self.coursewareAccessDetails = coursewareAccessDetails
        }
        
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            id = try values.decode(String.self, forKey: .id)
            discussionURL = try? values.decode(String.self, forKey: .discussionURL)
            enrollmentMetadata = try? values.decode(EnrollmentMetadata.self, forKey: .enrollmentMetadata)
            coursewareAccessDetails = try? values.decode(CoursewareAccessDetails.self, forKey: .coursewareAccessDetails)
        }
    }
    
    struct EnrollmentMetadata: Codable {
        public let created: String
        public let isActive: Bool
        public let mode: Mode
        public let upgradeDeadline: String?
        
        public enum CodingKeys: String, CodingKey {
            case created
            case isActive = "is_active"
            case mode
            case upgradeDeadline = "upgrade_deadline"
        }
        
        init(created: String, isActive: Bool, mode: Mode, upgradeDeadline: String?) {
            self.created = created
            self.isActive = isActive
            self.mode = mode
            self.upgradeDeadline = upgradeDeadline
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
        
        let enrollmentMetadata = EnrollmentMetadata(
            created: enrollmentMetadata?.created,
            mode: enrollmentMetadata?.mode,
            isActive: enrollmentMetadata?.isActive,
            upgradeDeadline: enrollmentMetadata?.upgradeDeadline
        )
        
        return EnrollmentDetails(
            id: id,
            discussionURL: discussionURL,
            enrollmentMetadata: enrollmentMetadata,
            coursewareAccess: coursewareAccess
        )
    }
}
