//
//  DashboardRepository.swift
//  Dashboard
//
//  Created by  Stepanok Ivan on 19.09.2022.
//

import Foundation
import Core

public protocol DashboardRepositoryProtocol {
    func getEnrollments(page: Int) async throws -> [CourseItem]
    func getEnrollmentsOffline() async throws -> [CourseItem]
    func getPrimaryEnrollment(pageSize: Int) async throws -> PrimaryEnrollment
    func getPrimaryEnrollmentOffline() async throws -> PrimaryEnrollment
    func getAllCourses(filteredBy: String, page: Int) async throws -> PrimaryEnrollment
}

public class DashboardRepository: DashboardRepositoryProtocol {
    
    private let api: API
    private let storage: CoreStorage
    private let config: ConfigProtocol
    private let persistence: DashboardPersistenceProtocol
    private let serverConfig: ServerConfigProtocol
    
    public init(
        api: API,
        storage: CoreStorage,
        config: ConfigProtocol,
        persistence: DashboardPersistenceProtocol,
        serverConfig: ServerConfigProtocol
    ) {
        self.api = api
        self.storage = storage
        self.config = config
        self.persistence = persistence
        self.serverConfig = serverConfig
    }
    
    public func getEnrollments(page: Int) async throws -> [CourseItem] {
        let result = try await api.requestData(
            DashboardEndpoint.getEnrollments(username: storage.user?.username ?? "", page: page)
        )
            .mapResponse(DataLayer.CourseEnrollments.self)
        serverConfig.initialize(serverConfig: result.configs?.config)
        let mappedResult = result.domain(
            baseURL: config.baseURL.absoluteString,
            iosProductPrefix: serverConfig.iapConfig.iosProductPrefix
        )
        
        persistence.saveEnrollments(items: mappedResult.0)
        persistence.saveServerConfig(configs: mappedResult.1)
        
        return mappedResult.0
    }
    
    public func getEnrollmentsOffline() async throws -> [CourseItem] {
        let config = try persistence.loadServerConfig()?.config
        serverConfig.initialize(serverConfig: config)
        return try await persistence.loadEnrollments()
    }
    
    public func getPrimaryEnrollment(pageSize: Int) async throws -> PrimaryEnrollment {
        let result = try await api.requestData(
            DashboardEndpoint.getPrimaryEnrollment(
                username: storage.user?.username ?? "",
                pageSize: pageSize
            )
        )
            .mapResponse(DataLayer.PrimaryEnrollment.self)
        serverConfig.initialize(serverConfig: result.configs?.config)
        let mappedResult = result.domain(
            baseURL: config.baseURL.absoluteString,
            iosProductPrefix: serverConfig.iapConfig.iosProductPrefix
        )
        
        persistence.savePrimaryEnrollment(enrollments: mappedResult.0)
        persistence.saveServerConfig(configs: mappedResult.1)
        
        serverConfig.initialize(serverConfig: mappedResult.1?.config)
        
        return mappedResult.0
    }
    
    public func getPrimaryEnrollmentOffline() async throws -> PrimaryEnrollment {
        let config = try persistence.loadServerConfig()?.config
        serverConfig.initialize(serverConfig: config)
        return try await persistence.loadPrimaryEnrollment()
    }
    
    public func getAllCourses(filteredBy: String, page: Int) async throws -> PrimaryEnrollment {
        let result = try await api.requestData(
            DashboardEndpoint.getAllCourses(
                username: storage.user?.username ?? "",
                filteredBy: filteredBy,
                page: page
            )
        )
            .mapResponse(DataLayer.PrimaryEnrollment.self)
            .domain(baseURL: config.baseURL.absoluteString, iosProductPrefix: "")
        return result.0
    }
}

// swiftlint:disable all
// Mark - For testing and SwiftUI preview
#if DEBUG
class DashboardRepositoryMock: DashboardRepositoryProtocol {
    func getCourseEnrollments(baseURL: String) async throws -> [CourseItem] {
        do {
            let courseEnrollments = try
            DashboardRepository.CourseEnrollmentsJSON.data(using: .utf8)!
                .mapResponse(DataLayer.CourseEnrollments.self)
                .domain(baseURL: baseURL, iosProductPrefix: "mobile.ios.usd")
            return courseEnrollments.0
        } catch {
            throw error
        }
    }

    func getEnrollments(page: Int) async throws -> [CourseItem] {
        var models: [CourseItem] = []
        for i in 0...10 {
            models.append(
                CourseItem(
                    name: "Course name \(i)",
                    org: "Organization",
                    shortDescription: "shortDescription",
                    imageURL: "",
                    hasAccess: true,
                    courseStart: nil,
                    courseEnd: nil,
                    enrollmentStart: nil,
                    enrollmentEnd: nil,
                    courseID: "course_id_\(i)",
                    numPages: 1,
                    coursesCount: 0,
                    isSelfPaced: false,
                    courseRawImage: nil,
                    coursewareAccess: nil,
                    progressEarned: 0,
                    progressPossible: 0,
                    auditAccessExpires: nil,
                    startDisplay: nil,
                    startType: nil
                )
            )
        }
        return models
    }
    
    func getEnrollmentsOffline() throws -> [CourseItem] { return [] }
    
    public func getPrimaryEnrollment(pageSize: Int) async throws -> PrimaryEnrollment {
        
        var courses: [CourseItem] = []
        for i in 0...10 {
            courses.append(
                CourseItem(
                    name: "Course name \(i)",
                    org: "Organization",
                    shortDescription: "shortDescription",
                    imageURL: "",
                    hasAccess: true,
                    courseStart: nil,
                    courseEnd: nil,
                    enrollmentStart: nil,
                    enrollmentEnd: nil,
                    courseID: "course_id_\(i)",
                    numPages: 1,
                    coursesCount: 0,
                    isSelfPaced: false,
                    courseRawImage: nil,
                    coursewareAccess: nil,
                    progressEarned: 4,
                    progressPossible: 10,
                    auditAccessExpires: nil,
                    startDisplay: nil,
                    startType: nil
                )
            )
        }
        
        let futureAssignment = Assignment(
            type: "Final Exam",
            title: "Subsection 3",
            description: "",
            date: Date(),
            complete: false, 
            firstComponentBlockId: nil
        )
        
        let primaryCourse = PrimaryCourse(
            name: "Primary Course",
            org: "Organization",
            courseID: "123",
            hasAccess: true,
            courseStart: Date(),
            courseEnd: Date(),
            courseBanner: "https://thumbs.dreamstime.com/b/logo-edx-samsung-tablet-edx-massive-open-online-course-mooc-provider-hosts-online-university-level-courses-wide-117763805.jpg",
            futureAssignments: [futureAssignment],
            pastAssignments: [futureAssignment],
            progressEarned: 2,
            progressPossible: 5, 
            lastVisitedBlockID: nil, 
            resumeTitle: nil,
            auditAccessExpires: nil,
            startDisplay: nil,
            startType: .unknown,
            isUpgradeable: false,
            sku: nil,
            lmsPrice: nil,
            isSelfPaced: false,
            coursewareAccess: nil
        )
        return PrimaryEnrollment(primaryCourse: primaryCourse, courses: courses, totalPages: 1, count: 1)
    }
    
    func getPrimaryEnrollmentOffline() async throws -> Core.PrimaryEnrollment {
        Core.PrimaryEnrollment(primaryCourse: nil, courses: [], totalPages: 1, count: 1)
    }
    
    func getAllCourses(filteredBy: String, page: Int) async throws -> Core.PrimaryEnrollment {
        var courses: [CourseItem] = []
        for i in 0...10 {
            courses.append(
                CourseItem(
                    name: "Course name \(i)",
                    org: "Organization",
                    shortDescription: "shortDescription",
                    imageURL: "",
                    hasAccess: true,
                    courseStart: nil,
                    courseEnd: nil,
                    enrollmentStart: nil,
                    enrollmentEnd: nil,
                    courseID: "course_id_\(i)",
                    numPages: 1,
                    coursesCount: 0,
                    isSelfPaced: false,
                    courseRawImage: nil,
                    coursewareAccess: nil,
                    progressEarned: 4,
                    progressPossible: 10,
                    auditAccessExpires: nil,
                    startDisplay: nil,
                    startType: nil
                )
            )
        }
        
        return PrimaryEnrollment(primaryCourse: nil, courses: courses, totalPages: 1, count: 1)
    }
}
#endif
// swiftlint:enable all
