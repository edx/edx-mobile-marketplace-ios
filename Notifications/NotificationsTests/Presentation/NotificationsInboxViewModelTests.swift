//
//  NotificationsInboxViewModelTests.swift
//  Notifications
//
//  Created by Shafqat Muneer on 5/14/25.
//

import SwiftyMocky
import XCTest
@testable import Core
@testable import Notifications
import Alamofire

final class NotificationsInboxViewModelTests: XCTestCase {
    private var mockInteractor: NotificationsInteractorProtocolMock!
    private var viewModel: NotificationsInboxViewModel!
    private var mockConnectivity: ConnectivityProtocolMock!
    
    private let notifications = Notifications(
        next: nil,
        count: 4,
        numPages: 1,
        currentPage: 1,
        start: 0,
        results: [
            SingleNotification(
                id: 1,
                appName: "discussion",
                notificationType: "comment_on_followed_post",
                contentContext: ContentContext(
                    topicId: "i4x-edX-demoX1-course-2T2017",
                    responseId: "6777c03a7febe504707971ab",
                    threadId: "5d49c25584452a0795000386",
                    commentId: "677b2ffa7febe50470799585",
                    postTitle: "How to learn it online?"
                ),
                content: "Test notification One",
                courseId: "course-v1:edX+Test+2T2009",
                lastRead: nil,
                lastSeen: Date(iso8601: "2025-01-06T01:20:58.919612Z"),
                created: Date(iso8601: "2025-01-06T01:20:58.919612Z")
            ), SingleNotification(
                id: 2,
                appName: "discussion",
                notificationType: "response_on_followed_post",
                contentContext: ContentContext(
                    topicId: "i4x-edX-demoX1-course-2T2017",
                    responseId: "6777c03a7febe504707971ab",
                    threadId: "5d49c25584452a0795000386",
                    commentId: "677b2ffa7febe50470799585",
                    postTitle: "How to learn it online?"
                ),
                content: "Test notification Two",
                courseId: "course-v1:edX+Test+2T2009",
                lastRead: nil,
                lastSeen: Date(iso8601: "2025-01-06T01:20:58.919612Z"),
                created: Date(iso8601: "2025-01-06T01:20:58.919612Z")
            ), SingleNotification(
                id: 3,
                appName: "discussion",
                notificationType: "new_response",
                contentContext: ContentContext(
                    topicId: "i4x-edX-demoX1-course-2T2017",
                    responseId: "6777c03a7febe504707971ab",
                    threadId: "5d49c25584452a0795000386",
                    commentId: "677b2ffa7febe50470799585",
                    postTitle: "How to learn it online?"
                ),
                content: "Test notification Three",
                courseId: "course-v1:edX+Test+2T2009",
                lastRead: nil,
                lastSeen: Date(iso8601: "2025-01-06T01:20:58.919612Z"),
                created: Date(iso8601: "2025-01-06T01:20:58.919612Z")
            ), SingleNotification(
                id: 4,
                appName: "discussion",
                notificationType: "new_comment",
                contentContext: ContentContext(
                    topicId: "i4x-edX-demoX1-course-2T2017",
                    responseId: "6777c03a7febe504707971ab",
                    threadId: "5d49c25584452a0795000386",
                    commentId: "677b2ffa7febe50470799585",
                    postTitle: "How to learn it online?"
                ),
                content: "Test notification Three",
                courseId: "course-v1:edX+Test+2T2009",
                lastRead: nil,
                lastSeen: Date(iso8601: "2025-01-06T01:20:58.919612Z"),
                created: Date(iso8601: "2025-01-06T01:20:58.919612Z")
            )
        ]
    )
    
    override func setUp() {
        super.setUp()
        mockInteractor = NotificationsInteractorProtocolMock()
        mockConnectivity = ConnectivityProtocolMock()
        
        Given(mockInteractor, .getAllNotifications(page: 1, willReturn: notifications))
        
        viewModel = NotificationsInboxViewModel(
            notificationsInteractor: mockInteractor,
            analytics: NotificationsAnalyticsMock(),
            router: NotificationsRouterMock(),
            connectivity: Connectivity(),
            deepLinkManager: NotificationsDeepLinkManagerMock()
        )
    }
    
    override func tearDown() {
        mockInteractor = nil
        viewModel = nil
        super.tearDown()
    }
    
    private func makeSUT(
        interactor: NotificationsInteractorProtocol = NotificationsInteractorProtocolMock(),
        analytics: NotificationsAnalytics = NotificationsAnalyticsMock(),
        router: NotificationsRouter = NotificationsRouterMock(),
        connectivity: ConnectivityProtocol = ConnectivityProtocolMock(),
        deepLinkManager: NotificationsDeepLinkManager = NotificationsDeepLinkManagerMock(),
        paginationManager: PaginationManager<SingleNotification, Int>? = nil
    ) -> NotificationsInboxViewModel {
        let sut = NotificationsInboxViewModel(
            notificationsInteractor: interactor,
            analytics: analytics,
            router: router,
            connectivity: connectivity,
            deepLinkManager: deepLinkManager
        )        
        return sut
    }
    
    func testMarkNotificationAsReadSuccess() async throws {
        let expectedResponse = NotificationsSeenRead(message: "Notification marked read.")
        
        Given(mockInteractor, .markNotificationAsRead(notificationId: .any, willReturn: expectedResponse))
        
        await viewModel.markNotificationAsRead(notificationId: "1")
        
        Verify(mockInteractor, .markNotificationAsRead(notificationId: .any))
    }
    
    func testMarkNotificationAsReadNoInternetError() async throws {
        let noInternetError = AFError.sessionInvalidated(error: URLError(.notConnectedToInternet))
        
        Given(mockInteractor, .markNotificationAsRead(notificationId: .any, willThrow: noInternetError))
        
        await viewModel.markNotificationAsRead(notificationId: "1")
        
        Verify(mockInteractor, .markNotificationAsRead(notificationId: .any))
        
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testMarkNotificationAsReadUnknownError() async throws {
        let noInternetError = AFError.sessionInvalidated(error: NSError(domain: "error", code: -1, userInfo: nil))
        
        Given(mockInteractor, .markNotificationAsRead(notificationId: .any, willThrow: noInternetError))
        
        await viewModel.markNotificationAsRead(notificationId: "1")
        
        Verify(mockInteractor, .markNotificationAsRead(notificationId: .any))
        
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testMarkAllNotificationsAsReadSuccess() async throws {
        let expectedResponse = NotificationsSeenRead(message: "Notifications marked read.")
        
        Given(mockInteractor, .markAllNotificationsAsRead(willReturn: expectedResponse))
        
        await viewModel.loadNotifications()
        await viewModel.markAllNotificationsAsRead()
        
        Verify(mockInteractor, .markAllNotificationsAsRead())
        
        XCTAssertNotNil(viewModel.flatNotifications[0].lastRead)
        XCTAssertEqual(notifications.results?.count, viewModel.flatNotifications.count)
    }
    
    func testMarkAllNotificationsAsReadNoInternetError() async throws {
        Given(mockInteractor, .markAllNotificationsAsRead(willThrow: URLError(.notConnectedToInternet)))
        
        await viewModel.loadNotifications()
        await viewModel.markAllNotificationsAsRead()
        
        Verify(mockInteractor, .markAllNotificationsAsRead())
        
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testMarkAllNotificationsAsReadUnknownError() async throws {
        Given(mockInteractor, .markAllNotificationsAsRead(willThrow: NSError(domain: "error", code: -1, userInfo: nil)))
        
        await viewModel.loadNotifications()
        await viewModel.markAllNotificationsAsRead()
        
        Verify(mockInteractor, .markAllNotificationsAsRead())
        
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testMarkNotificationsAsSeenSuccess() async throws {
        let expectedResponse = NotificationsSeenRead(message: "Notifications marked as seen.")
        
        Given(mockInteractor, .markNotificationsAsSeen(willReturn: expectedResponse))
        
        await viewModel.markNotificationsAsSeen()
        
        Verify(mockInteractor, .markNotificationsAsSeen())
    }
    
    func testMarkNotificationsAsSeenNoInternetError() async throws {
        Given(mockInteractor, .markNotificationsAsSeen(willThrow: URLError(.notConnectedToInternet)))
        
        await viewModel.markNotificationsAsSeen()
        
        Verify(mockInteractor, .markNotificationsAsSeen())
    }
    
    func testMarkNotificationsAsSeenUnknownError() async throws {
        Given(mockInteractor, .markNotificationsAsSeen(willThrow: NSError(domain: "error", code: -1, userInfo: nil)))
        
        await viewModel.markNotificationsAsSeen()
        
        Verify(mockInteractor, .markNotificationsAsSeen())
    }
    
    func testGetAllNotificationsSuccess() async throws {
        Given(mockInteractor, .getAllNotifications(page: 1, willReturn: notifications))
        
        viewModel = NotificationsInboxViewModel(
            notificationsInteractor: mockInteractor,
            analytics: NotificationsAnalyticsMock(),
            router: NotificationsRouterMock(),
            connectivity: Connectivity(),
            deepLinkManager: NotificationsDeepLinkManagerMock()
        )

        await viewModel.loadNotifications()
        
        XCTAssertEqual(notifications.results?.count, viewModel.flatNotifications.count)
    }
    
    func testGetAllNotificationsNoInternetError() async throws {
        Given(mockInteractor, .getAllNotifications(page: 1, willThrow: URLError(.notConnectedToInternet)))
        Given(mockConnectivity, .isInternetAvaliable(getter: false))
        
        viewModel = NotificationsInboxViewModel(
            notificationsInteractor: mockInteractor,
            analytics: NotificationsAnalyticsMock(),
            router: NotificationsRouterMock(),
            connectivity: mockConnectivity,
            deepLinkManager: NotificationsDeepLinkManagerMock()
        )

        await viewModel.loadNotifications()
        
        XCTAssertEqual(viewModel.screenState, .noInternet)
    }
    
    func testGetAllNotificationsUnknownError() async throws {
        Given(mockInteractor, .getAllNotifications(page: 1, willThrow: NSError(domain: "error", code: -1, userInfo: nil)))
        Given(mockConnectivity, .isInternetAvaliable(getter: true))
        
        viewModel = NotificationsInboxViewModel(
            notificationsInteractor: mockInteractor,
            analytics: NotificationsAnalyticsMock(),
            router: NotificationsRouterMock(),
            connectivity: mockConnectivity,
            deepLinkManager: NotificationsDeepLinkManagerMock()
        )

        await viewModel.loadNotifications()
        
        XCTAssertEqual(viewModel.screenState, .serverError)
    }
    
    func testIsDiscussionNotification() async throws {
        await viewModel.loadNotifications()
        
        XCTAssertEqual(viewModel.flatNotifications[0].appName, "discussion")
    }
    
    func testNotificationTypeAsCommentOnFollowedPost() async throws {
        await viewModel.loadNotifications()
        
        XCTAssertEqual(viewModel.flatNotifications[0].notificationType, "comment_on_followed_post")
    }
    
    func testNotificationTypeAsResponseOnFollowedPost() async throws {
        await viewModel.loadNotifications()
        
        XCTAssertEqual(viewModel.flatNotifications[1].notificationType, "response_on_followed_post")
    }
    
    func testNotificationTypeAsNewResponse() async throws {
        await viewModel.loadNotifications()
        
        XCTAssertEqual(viewModel.flatNotifications[2].notificationType, "new_response")
    }
    
    func testNotificationTypeAsNewComment() async throws {
        await viewModel.loadNotifications()
        
        XCTAssertEqual(viewModel.flatNotifications[3].notificationType, "new_comment")
    }
}
