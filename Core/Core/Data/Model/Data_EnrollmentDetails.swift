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
        public let enrollmentDetail: EnrollmentDetail?
        public let coursewareAccessDetails: CoursewareAccessDetails?
        
        enum CodingKeys: String, CodingKey {
            case id
            case discussionURL = "discussion_url"
            case enrollmentDetail = "enrollment_details"
            case coursewareAccessDetails = "course_access_details"
        }
        
        public init(
            id: String,
            discussionURL: String? = nil,
            enrollmentDetail: EnrollmentDetail? = nil,
            coursewareAccessDetails: CoursewareAccessDetails? = nil
        ) {
            self.id = id
            self.discussionURL = discussionURL
            self.enrollmentDetail = enrollmentDetail
            self.coursewareAccessDetails = coursewareAccessDetails
        }
        
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            id = try values.decode(String.self, forKey: .id)
            discussionURL = try? values.decode(String.self, forKey: .discussionURL)
            enrollmentDetail = try? values.decode(EnrollmentDetail.self, forKey: .enrollmentDetail)
            coursewareAccessDetails = try? values.decode(CoursewareAccessDetails.self, forKey: .coursewareAccessDetails)
        }
    }
    
    struct EnrollmentDetail: Codable {
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
        
        let enrollmentDetail = EnrollmentDetail(
            created: enrollmentDetail?.created,
            mode: enrollmentDetail?.mode,
            isActive: enrollmentDetail?.isActive,
            upgradeDeadline: enrollmentDetail?.upgradeDeadline
        )
        
        return EnrollmentDetails(
            id: id,
            discussionURL: discussionURL,
            enrollmentDetail: enrollmentDetail,
            coursewareAccess: coursewareAccess
        )
    }
}
