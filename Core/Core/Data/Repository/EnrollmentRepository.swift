//
//  CourseEnrollmentRepository.swift
//  Core
//
//  Created by Shafqat Muneer on 7/28/25.
//

import Foundation

//sourcery: AutoMockable
public protocol EnrollmentRepositoryProtocol {
    func getEnrollmentDetails(courseID: String) async throws -> EnrollmentDetails
}

public class EnrollmentRepository: EnrollmentRepositoryProtocol {
    
    private let api: API
    
    public init(
        api: API
    ) {
        self.api = api
    }
    
    public func getEnrollmentDetails(courseID: String) async throws -> EnrollmentDetails {
        let enrollmentDetails = try await api.requestData(
            EnrollmentEndpoint.getEnrollmentDetails(courseID: courseID)
        ).mapResponse(DataLayer.EnrollmentDetails.self).domain
        return enrollmentDetails
    }
}

// Mark - For testing and SwiftUI preview
// swiftlint:disable all
#if DEBUG
class EnrollmentRepositoryMock: EnrollmentRepositoryProtocol {
    func getEnrollmentDetails(courseID: String) async throws -> EnrollmentDetails {
        return EnrollmentDetails(
            id: "",
            discussionURL: nil,
            enrollmentDetail: EnrollmentDetail(
                created: "2025-07-25T11:50:18Z",
                mode: .audit,
                isActive: true,
                upgradeDeadline: nil
            ),
            coursewareAccess: CoursewareAccess(
                hasAccess: false,
                errorCode: .notStarted,
                developerMessage: "Course does not start until 2025-07-15 04:00:00+00:00",
                userMessage: "Course does not start until July 15, 2025",
                additionalContextUserMessage: nil,
                userFragment: nil
            )
        )
    }
}
#endif
// swiftlint:enable all
