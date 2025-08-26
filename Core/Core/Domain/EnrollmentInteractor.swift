//
//  CourseEnrollmentInteractor.swift
//  Core
//
//  Created by Shafqat Muneer on 7/28/25.
//

import Foundation

//sourcery: AutoMockable
public protocol EnrollmentInteractorProtocol {
    func getEnrollmentDetails(courseID: String) async throws -> EnrollmentDetails
}

public class EnrollmentInteractor: EnrollmentInteractorProtocol {
    
    private let repository: EnrollmentRepositoryProtocol
    
    public init(
        repository: EnrollmentRepositoryProtocol
    ) {
        self.repository = repository
    }
    
    public func getEnrollmentDetails(courseID: String) async throws -> EnrollmentDetails {
        return try await repository.getEnrollmentDetails(courseID: courseID)
    }
}

// Mark - For testing and SwiftUI preview
#if DEBUG
public extension EnrollmentInteractor {
    static let mock = EnrollmentInteractor(
        repository: EnrollmentRepositoryMock()
    )
}
#endif
