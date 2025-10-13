//
//  NotificationsPrimerViewModelTests.swift
//  NotificationsTests
//
//  Created by Muhammad Tayyab  Akram on 8/13/25.
//

import SwiftyMocky
import XCTest

@testable import Core
@testable import Notifications

final class NotificationsPrimerViewModelTests: XCTestCase {
    private var userNotificationCenter: UserNotificationCenterMock!
    private var interactor: NotificationsInteractorProtocolMock!
    private var analytics: NotificationsAnalyticsMock!
    private var router: NotificationsRouterMock!
    private var storage: CoreStorageMock!
    private var sut: NotificationsPrimerViewModel!

    override func setUp() {
        super.setUp()

        userNotificationCenter = UserNotificationCenterMock()
        interactor = NotificationsInteractorProtocolMock()
        analytics = NotificationsAnalyticsMock()
        router = NotificationsRouterMock()
        storage = CoreStorageMock()
        sut = NotificationsPrimerViewModel(
            userNotificationCenter: userNotificationCenter,
            interactor: interactor,
            router: router,
            analytics: analytics
        )
    }

    override func tearDown() {
        interactor = nil
        analytics = nil
        router = nil
        storage = nil
        sut = nil

        super.tearDown()
    }

    func test_initialState_isUpdatingFalse() {
        XCTAssertFalse(sut.isUpdating)
    }

    func test_markAsShown_invokesInteractor() {
        // Given
        Given(interactor, .primerFrequency(willReturn: 1))

        // When
        sut.markAsShown()

        // Then
        Verify(analytics, 1, .notificationDiscussionPrimerViewed(dialogFrequency: .any))
        Verify(interactor, 1, .markPrimerAsShown())
    }

    func test_noThanks_dismissesPrimer() {
        // When
        sut.noThanks()

        // Then
        Verify(analytics, 1, .notificationDiscussionPrimerAction(action: .any))
        XCTAssertTrue(router.dismissCalled)
    }

    func test_notifyMe_withAuthorizationStatusNotDetermined_requestsNotificationPermissions() async throws {
        // Given
        userNotificationCenter.authorizationStatus = .notDetermined

        // When
        sut.notifyMe()
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Then
        XCTAssertTrue(sut.isUpdating)
        XCTAssertTrue(router.performNotificationRegistrationCalled)
        Verify(analytics, 1, .notificationSystemPermissionDialogViewed(source: .any))
    }

    func test_notifyMe_withAuthorizationStatusDenied_showsPermissionNeededAlert() async throws {
        // Given
        userNotificationCenter.authorizationStatus = .denied

        // When
        sut.notifyMe()
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Then
        XCTAssertTrue(sut.isUpdating)
        XCTAssertTrue(router.presentNativeAlertCalled)
        Verify(analytics, 1, .notificationAppPermissionRationaleDialogViewed(source: .any))
    }
}
