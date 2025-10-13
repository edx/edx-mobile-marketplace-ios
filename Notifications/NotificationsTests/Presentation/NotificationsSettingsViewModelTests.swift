//
//  NotificationsSettingsViewModelTests.swift
//  NotificationsTests
//
//  Created by Muhammad Tayyab  Akram on 8/12/25.
//

import SwiftyMocky
import XCTest

@testable import Notifications
@testable import Core

final class NotificationsSettingsViewModelTests: XCTestCase {
    private var userNotificationCenter: UserNotificationCenterMock!
    private var interactor: NotificationsInteractorProtocolMock!
    private var analytics: NotificationsAnalyticsMock!
    private var router: NotificationsRouterMock!
    private var storage: CoreStorageMock!
    private var sut: NotificationsSettingsViewModel!

    override func setUp() {
        super.setUp()

        userNotificationCenter = UserNotificationCenterMock()
        interactor = NotificationsInteractorProtocolMock()
        analytics = NotificationsAnalyticsMock()
        router = NotificationsRouterMock()
        storage = CoreStorageMock()
    }

    override func tearDown() {
        userNotificationCenter = nil
        interactor = nil
        analytics = nil
        router = nil
        storage = nil
        sut = nil

        super.tearDown()
    }

    func makeSUT() -> NotificationsSettingsViewModel {
        return NotificationsSettingsViewModel(
            userNotificationCenter: userNotificationCenter,
            interactor: interactor,
            analytics: analytics,
            router: router,
            storage: storage
        )
    }

    func test_init_readsDiscussionSettingFromStorage() {
        // Given
        storage.discussionNotificationsSettingStatus = true

        // When
        sut = makeSUT()

        // Then
        XCTAssertTrue(sut.discussionNotificationsEnabled, "ViewModel should read initial discussion setting from storage")
    }

    func test_getNotificationsPreferences_success_updatesDiscussionFlag() async throws {
        // Given
        let preferences = NotificationsPreferences(
            discussionsEnabled: true,
            coreEnabled: true
        )
        Given(interactor, .getNotificationsPreferences(willReturn: preferences))

        sut = makeSUT()
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // When
        await sut.getNotificationsPreferences()

        // Then
        Verify(interactor, 1, .getNotificationsPreferences())
        XCTAssertEqual(storage.discussionNotificationsSettingStatus, true)
        XCTAssertTrue(sut.discussionNotificationsEnabled)
        XCTAssertFalse(sut.showError)
        XCTAssertNil(sut.errorMessage)
    }

    func test_getNotificationsPreferences_error_ignoresUpdatingDiscussionFlag() async throws {
        // Given
        storage.discussionNotificationsSettingStatus = true
        let error = NSError(domain: "test", code: -1)
        Given(interactor, .getNotificationsPreferences(willThrow: error))

        sut = makeSUT()

        // When
        await sut.getNotificationsPreferences()

        // Then
        Verify(interactor, 1, .getNotificationsPreferences())
        XCTAssertEqual(storage.discussionNotificationsSettingStatus, true)
        XCTAssertTrue(sut.discussionNotificationsEnabled)
        XCTAssertFalse(sut.showError)
        XCTAssertNil(sut.errorMessage)
    }

    func test_toggleDiscussionNotifications_withAuthorizationStatusNotDetermined_showsSystemPermissionAlert() async throws {
        // Given
        userNotificationCenter.authorizationStatus = .notDetermined

        sut = makeSUT()
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // When
        await sut.toggleDiscussionNotifications()

        // Then
        XCTAssertTrue(router.performNotificationRegistrationCalled)
        Verify(analytics, 1, .notificationSystemPermissionDialogViewed(source: .any))
    }

    func test_toggleDiscussionNotifications_withAuthorizationStatusDenied_showsPermissionNeededAlert() async throws {
        // Given
        userNotificationCenter.authorizationStatus = .denied

        sut = makeSUT()
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // When
        await sut.toggleDiscussionNotifications()

        // Then
        XCTAssertTrue(router.presentNativeAlertCalled)
        Verify(analytics, 1, .notificationAppPermissionRationaleDialogViewed(source: .any))
    }

    func test_toggleDiscussionNotifications_callsUpdateAndPersistsChange() async throws {
        // Given
        let response = NotificationsPreferencesUpdate(
            status: "success",
            updatedValue: true,
            notificationType: "core",
            channel: "push",
            app: "discussion"
        )
        Given(interactor, .updateNotificationsPreferences(value: true, willReturn: response))

        sut = makeSUT()
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // When
        await sut.toggleDiscussionNotifications()

        // Then
        Verify(interactor, 1, .updateNotificationsPreferences(value: true))
        XCTAssertTrue(sut.discussionNotificationsEnabled)
        XCTAssertEqual(storage.discussionNotificationsSettingStatus, true)
    }

    func test_toggleDiscussionNotifications_whenUpdateThrows_resetsToPreviousStateAndShowsError() async throws {
        // Given
        storage.discussionNotificationsSettingStatus = true
        let error = NSError(domain: "test", code: -1)
        Given(interactor, .updateNotificationsPreferences(value: false, willThrow: error))

        sut = makeSUT()
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // When
        await sut.toggleDiscussionNotifications()

        // Then
        Verify(interactor, 1, .updateNotificationsPreferences(value: false))
        XCTAssertTrue(sut.discussionNotificationsEnabled, "On failure the toggle should revert to the previous value")
        XCTAssertTrue(sut.showError)
        XCTAssertNotNil(sut.errorMessage)
    }
}
