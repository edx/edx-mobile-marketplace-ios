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
    private var sut: NotificationsInboxViewModel!
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
            ),
            SingleNotification(
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
            ),
            SingleNotification(
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
            ),
            SingleNotification(
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
        
        sut = NotificationsInboxViewModel(
            notificationsInteractor: mockInteractor,
            analytics: NotificationsAnalyticsMock(),
            router: NotificationsRouterMock(),
            connectivity: mockConnectivity,
            deepLinkManager: NotificationsDeepLinkManagerMock()
        )
    }
    
    override func tearDown() {
        mockInteractor = nil
        sut = nil
        super.tearDown()
    }
    
    func testMarkNotificationAsReadSuccess() async throws {
        let expectedResponse = NotificationsSeenRead(message: "Notification marked read.")
        
        Given(mockInteractor, .markNotificationAsRead(notificationId: .value("1"), willReturn: expectedResponse))
        
        await sut.markNotificationAsRead(notificationId: "1")
        
        Verify(mockInteractor, 1, .markNotificationAsRead(notificationId: .value("1")))
        
        XCTAssertNil(sut.errorMessage)
    }
    
    func testMarkNotificationAsReadNoInternetError() async throws {
        let noInternetError = AFError.sessionInvalidated(error: URLError(.notConnectedToInternet))
        
        Given(mockInteractor, .markNotificationAsRead(notificationId: .value("1"), willThrow: noInternetError))
        
        await sut.markNotificationAsRead(notificationId: "1")
        
        Verify(mockInteractor, 1, .markNotificationAsRead(notificationId: .value("1")))
        
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.errorMessage, CoreLocalization.Error.slowOrNoInternetConnection)
    }
    
    func testMarkNotificationAsReadUnknownError() async throws {
        let unknown = AFError.sessionInvalidated(error: NSError(domain: "error", code: -1, userInfo: nil))
        
        Given(mockInteractor, .markNotificationAsRead(notificationId: .value("1"), willThrow: unknown))
        
        await sut.markNotificationAsRead(notificationId: "1")
        
        Verify(mockInteractor, 1, .markNotificationAsRead(notificationId: .value("1")))
        
        XCTAssertNotNil(sut.errorMessage)
    }
    
    func testMarkAllNotificationsAsReadSuccess() async throws {
        let expectedResponse = NotificationsSeenRead(message: "Notifications marked read.")
        
        Given(mockInteractor, .markAllNotificationsAsRead(willReturn: expectedResponse))
        
        await sut.loadNotifications()
        await sut.markAllNotificationsAsRead()
        
        Verify(mockInteractor, 1, .markAllNotificationsAsRead())
        
        XCTAssertNotNil(sut.flatNotifications[0].lastRead)
        XCTAssertNotNil(sut.flatNotifications[1].lastRead)
        XCTAssertNotNil(sut.flatNotifications[2].lastRead)
        XCTAssertNotNil(sut.flatNotifications[3].lastRead)
        XCTAssertEqual(notifications.results?.count, sut.flatNotifications.count)
        XCTAssertNil(sut.errorMessage)
    }
    
    func testMarkAllNotificationsAsReadNoInternetError() async throws {
        let noInternetError = AFError.sessionInvalidated(error: URLError(.notConnectedToInternet))
        
        Given(mockInteractor, .markAllNotificationsAsRead(willThrow: noInternetError))
        
        await sut.loadNotifications()
        await sut.markAllNotificationsAsRead()
        
        Verify(mockInteractor, 1, .markAllNotificationsAsRead())
        
        XCTAssertNil(sut.flatNotifications[0].lastRead)
        XCTAssertNil(sut.flatNotifications[1].lastRead)
        XCTAssertNil(sut.flatNotifications[2].lastRead)
        XCTAssertNil(sut.flatNotifications[3].lastRead)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.errorMessage, CoreLocalization.Error.slowOrNoInternetConnection)
    }
    
    func testMarkAllNotificationsAsReadUnknownError() async throws {
        let unknown = AFError.sessionInvalidated(error: NSError(domain: "error", code: -1, userInfo: nil))
        
        Given(mockInteractor, .markAllNotificationsAsRead(willThrow: unknown))
        
        await sut.loadNotifications()
        await sut.markAllNotificationsAsRead()
        
        Verify(mockInteractor, 1, .markAllNotificationsAsRead())
        
        XCTAssertNil(sut.flatNotifications[0].lastRead)
        XCTAssertNil(sut.flatNotifications[1].lastRead)
        XCTAssertNil(sut.flatNotifications[2].lastRead)
        XCTAssertNil(sut.flatNotifications[3].lastRead)
        XCTAssertNotNil(sut.errorMessage)
    }
    
    func testMarkNotificationsAsSeenSuccess() async throws {
        let expectedResponse = NotificationsSeenRead(message: "Notifications marked as seen.")
        
        Given(mockInteractor, .markNotificationsAsSeen(willReturn: expectedResponse))
        
        await sut.markNotificationsAsSeen()
        
        Verify(mockInteractor, 1, .markNotificationsAsSeen())
    }
    
    func testMarkNotificationsAsSeenError() async throws {
        let unknown = AFError.sessionInvalidated(error: NSError(domain: "error", code: -1, userInfo: nil))
        
        Given(mockInteractor, .markNotificationsAsSeen(willThrow: unknown))
        
        await sut.markNotificationsAsSeen()
        
        Verify(mockInteractor, 1, .markNotificationsAsSeen())
    }
    
    func testGetAllNotificationsSuccess() async throws {
        await sut.loadNotifications()
        
        Verify(mockInteractor, 1, .getAllNotifications(page: 1))
        
        XCTAssertEqual(notifications.results?.count, sut.flatNotifications.count)
        XCTAssertNil(sut.errorMessage)
    }
    
    func testGetAllNotificationsNoInternetError() async throws {
        let noInternetError = AFError.sessionInvalidated(error: URLError(.notConnectedToInternet))
        
        Given(mockInteractor, .getAllNotifications(page: 1, willThrow: noInternetError))
        Given(mockConnectivity, .isInternetAvaliable(getter: false))
        
        await sut.loadNotifications()
        
        Verify(mockInteractor, 1, .getAllNotifications(page: 1))
        
        XCTAssertEqual(sut.flatNotifications.count, .zero)
        XCTAssertEqual(sut.screenState, .noInternet)
    }
    
    func testGetAllNotificationsUnknownError() async throws {
        let unknown = AFError.sessionInvalidated(error: NSError(domain: "error", code: -1, userInfo: nil))
        
        Given(mockInteractor, .getAllNotifications(page: 1, willThrow: unknown))
        Given(mockConnectivity, .isInternetAvaliable(getter: true))
        
        await sut.loadNotifications()
        
        Verify(mockInteractor, 1, .getAllNotifications(page: 1))
        
        XCTAssertEqual(sut.flatNotifications.count, .zero)
        XCTAssertEqual(sut.screenState, .serverError)
    }
}
