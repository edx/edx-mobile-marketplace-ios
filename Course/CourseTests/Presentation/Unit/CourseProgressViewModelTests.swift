//
//  CourseProgressViewModelTests.swift
//  CourseTests
//
//  Created by Abid Bhatti on 29/07/26.
//

import SwiftyMocky
import XCTest
@testable import Core
@testable import Course
import Alamofire
import SwiftUI
import Combine

@MainActor
final class CourseProgressViewModelTests: XCTestCase {

    // MARK: - Shared test data

    static let mockCourseProgress = CourseProgressDetails(
        verifiedMode: nil,
        accessExpiration: nil,
        certificateData: CourseProgressCertificateData(
            certStatus: "downloadable",
            certWebViewUrl: "https://example.com/cert",
            downloadUrl: "https://example.com/download",
            certificateAvailableDate: nil
        ),
        completionSummary: CourseProgressCompletionSummary(
            completeCount: 8,
            incompleteCount: 2,
            lockedCount: 0
        ),
        courseGrade: CourseProgressGrade(
            letterGrade: "A",
            percent: 0.85,
            isPassing: true
        ),
        creditCourseRequirements: nil,
        end: nil,
        enrollmentMode: "honor",
        gradingPolicy: CourseProgressGradingPolicy(
            assignmentPolicies: [
                CourseProgressAssignmentPolicy(
                    numDroppable: 1, numTotal: 5, shortLabel: "HW", type: "Homework", weight: 0.5),
                CourseProgressAssignmentPolicy(
                    numDroppable: 0, numTotal: 2, shortLabel: "Exam", type: "Exam", weight: 0.5)
            ],
            gradeRange: ["Pass": 0.6, "Fail": 0.0],
            assignmentColors: ["#FF5733", "#33C1FF"]
        ),
        hasScheduledContent: false,
        sectionScores: [
            CourseProgressSectionScore(
                displayName: "Section 1",
                subsections: [
                    CourseProgressSubsection(
                        assignmentType: "Homework",
                        blockKey: "hw1",
                        displayName: "Homework 1",
                        hasGradedAssignment: true,
                        override: nil,
                        learnerHasAccess: true,
                        numPointsEarned: 8.0,
                        numPointsPossible: 10.0,
                        percentGraded: 0.8,
                        problemScores: [CourseProgressProblemScore(earned: 8.0, possible: 10.0)],
                        showCorrectness: "always",
                        showGrades: true,
                        url: "https://example.com/hw1"
                    )
                ]
            )
        ],
        verificationData: nil
    )

    static let mockEmptyProgress = CourseProgressDetails(
        verifiedMode: nil,
        accessExpiration: nil,
        certificateData: CourseProgressCertificateData(
            certStatus: nil, certWebViewUrl: nil, downloadUrl: nil, certificateAvailableDate: nil),
        completionSummary: CourseProgressCompletionSummary(
            completeCount: 0, incompleteCount: 0, lockedCount: 0),
        courseGrade: CourseProgressGrade(letterGrade: nil, percent: 0.0, isPassing: false),
        creditCourseRequirements: nil,
        end: nil,
        enrollmentMode: "honor",
        gradingPolicy: CourseProgressGradingPolicy(
            assignmentPolicies: [], gradeRange: [:], assignmentColors: []),
        hasScheduledContent: false,
        sectionScores: [],
        verificationData: nil
    )

    // MARK: - getCourseProgress

    func testGetCourseProgressSuccess() async throws {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))
        Given(interactor, .getCourseProgress(courseID: .any,
                                             willReturn: CourseProgressViewModelTests.mockCourseProgress))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        await viewModel.getCourseProgress(courseID: "test-course-id")

        Verify(interactor, .getCourseProgress(courseID: .any))
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertNotNil(viewModel.courseProgress)
        XCTAssertEqual(viewModel.courseProgress?.courseGrade.percent, 0.85)
        XCTAssertTrue(viewModel.progressFetchAttempted)
    }

    func testGetCourseProgressOfflineSuccess() async throws {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: false))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))
        Given(interactor, .getCourseProgressOffline(courseID: .any,
                                                    willReturn: CourseProgressViewModelTests.mockCourseProgress))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        await viewModel.getCourseProgress(courseID: "test-course-id")

        Verify(interactor, .getCourseProgressOffline(courseID: .any))
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertNotNil(viewModel.courseProgress)
    }

    func testGetCourseProgressUnknownError() async throws {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))
        Given(interactor, .getCourseProgress(courseID: .any,
                                             willThrow: NSError(domain: "error", code: -1, userInfo: nil)))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        await viewModel.getCourseProgress(courseID: "test-course-id")

        Verify(interactor, .getCourseProgress(courseID: .any))
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, CoreLocalization.Error.unknownError)
    }

    func testGetCourseProgressNoInternetError() async throws {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        let noInternetError = AFError.sessionInvalidated(error: URLError(.notConnectedToInternet))
        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))
        Given(interactor, .getCourseProgress(courseID: .any, willThrow: noInternetError))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        await viewModel.getCourseProgress(courseID: "test-course-id")

        Verify(interactor, .getCourseProgress(courseID: .any))
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, CoreLocalization.Error.slowOrNoInternetConnection)
    }

    func testGetCourseProgressNoCacheError() async throws {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))
        Given(interactor, .getCourseProgress(courseID: .any, willThrow: NoCachedDataError()))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        await viewModel.getCourseProgress(courseID: "test-course-id")

        Verify(interactor, .getCourseProgress(courseID: .any))
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, CoreLocalization.Error.slowOrNoInternetConnection)
    }

    func testGetCourseProgressWithProgressFalse() async throws {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))
        Given(interactor, .getCourseProgress(courseID: .any,
                                             willReturn: CourseProgressViewModelTests.mockCourseProgress))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        await viewModel.getCourseProgress(courseID: "test-course-id", withProgress: false)

        // isLoading should never be set to true when withProgress is false
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.courseProgress)
    }

    // MARK: - Analytics

    func testTrackProgressTabClicked() {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        viewModel.trackProgressTabClicked(courseId: "course-1", courseName: "My Course")

        Verify(analytics, .courseOutlineProgressTabClicked(courseId: .value("course-1"),
                                                           courseName: .value("My Course")))
    }

    // MARK: - Computed properties

    func testIsProgressEmpty() {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        // nil progress
        XCTAssertTrue(viewModel.isProgressEmpty)

        // empty progress
        viewModel.courseProgress = CourseProgressViewModelTests.mockEmptyProgress
        XCTAssertTrue(viewModel.isProgressEmpty)

        // non-empty progress
        viewModel.courseProgress = CourseProgressViewModelTests.mockCourseProgress
        XCTAssertFalse(viewModel.isProgressEmpty)
    }

    func testHasGradedAssignments() {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        XCTAssertFalse(viewModel.hasGradedAssignments)

        viewModel.courseProgress = CourseProgressViewModelTests.mockEmptyProgress
        XCTAssertFalse(viewModel.hasGradedAssignments)

        viewModel.courseProgress = CourseProgressViewModelTests.mockCourseProgress
        XCTAssertTrue(viewModel.hasGradedAssignments)
    }

    func testOverallProgressPercentage() {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        XCTAssertEqual(viewModel.overallProgressPercentage, 0.0)

        viewModel.courseProgress = CourseProgressViewModelTests.mockCourseProgress
        // 8 complete / (8 + 2) total = 0.8
        XCTAssertEqual(viewModel.overallProgressPercentage, 0.8, accuracy: 0.01)
    }

    func testGradePercentage() {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        XCTAssertEqual(viewModel.gradePercentage, 0.0)

        viewModel.courseProgress = CourseProgressViewModelTests.mockCourseProgress
        XCTAssertEqual(viewModel.gradePercentage, 0.85)
    }

    func testIsPassing() {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        XCTAssertFalse(viewModel.isPassing)

        viewModel.courseProgress = CourseProgressViewModelTests.mockCourseProgress
        XCTAssertTrue(viewModel.isPassing)
    }

    func testHasCertificate() {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        XCTAssertFalse(viewModel.hasCertificate)

        // "downloadable" status → has certificate
        viewModel.courseProgress = CourseProgressViewModelTests.mockCourseProgress
        XCTAssertTrue(viewModel.hasCertificate)

        // "passing" status → also has certificate (fork-specific: checks "passing" OR "downloadable")
        var passingProgress = CourseProgressViewModelTests.mockCourseProgress
        passingProgress = CourseProgressDetails(
            verifiedMode: nil, accessExpiration: nil,
            certificateData: CourseProgressCertificateData(
                certStatus: "passing", certWebViewUrl: nil,
                downloadUrl: nil, certificateAvailableDate: nil),
            completionSummary: CourseProgressViewModelTests.mockCourseProgress.completionSummary,
            courseGrade: CourseProgressViewModelTests.mockCourseProgress.courseGrade,
            creditCourseRequirements: nil, end: nil, enrollmentMode: "honor",
            gradingPolicy: CourseProgressViewModelTests.mockCourseProgress.gradingPolicy,
            hasScheduledContent: false,
            sectionScores: CourseProgressViewModelTests.mockCourseProgress.sectionScores,
            verificationData: nil
        )
        viewModel.courseProgress = passingProgress
        XCTAssertTrue(viewModel.hasCertificate)

        // nil status → no certificate
        viewModel.courseProgress = CourseProgressViewModelTests.mockEmptyProgress
        XCTAssertFalse(viewModel.hasCertificate)
    }

    func testCertificateUrl() {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        XCTAssertNil(viewModel.certificateUrl)

        viewModel.courseProgress = CourseProgressViewModelTests.mockCourseProgress
        XCTAssertEqual(viewModel.certificateUrl, "https://example.com/download")
    }

    func testRequiredGradePercentage() {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        XCTAssertEqual(viewModel.requiredGradePercentage, 0.0)

        viewModel.courseProgress = CourseProgressViewModelTests.mockCourseProgress
        XCTAssertEqual(viewModel.requiredGradePercentage, 0.6)
    }

    func testAssignmentPolicies() {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let analytics = CourseAnalyticsMock()
        let connectivity = ConnectivityProtocolMock()

        Given(connectivity, .isInternetAvaliable(getter: true))
        Given(connectivity, .internetReachableSubject(getter: .init(.reachable)))

        let viewModel = CourseProgressViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            connectivity: connectivity
        )

        XCTAssertTrue(viewModel.assignmentPolicies.isEmpty)

        viewModel.courseProgress = CourseProgressViewModelTests.mockCourseProgress
        XCTAssertEqual(viewModel.assignmentPolicies.count, 2)
        XCTAssertEqual(viewModel.assignmentPolicies[0].type, "Homework")
        XCTAssertEqual(viewModel.assignmentPolicies[1].type, "Exam")
    }
}
