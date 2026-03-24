//
//  SettingsViewModelTests.swift
//  ProfileTests
//
//  Created by  Stepanok Ivan on 10.04.2024.
//

import SwiftyMocky
import XCTest
@testable import Core
@testable import Profile
import Alamofire
import SwiftUI

final class SettingsViewModelTests: XCTestCase {

    func testLogOutSuccess() async throws {
        let interactor = ProfileInteractorProtocolMock()
        let router = ProfileRouterMock()
        let analytics = ProfileAnalyticsMock()
        let coreAnalytics = CoreAnalyticsMock()
        
        Given(
            interactor,
            .getSettings(
                willReturn: UserSettings(
                    wifiOnly: true,
                    streamingQuality: .auto,
                    downloadQuality: .auto,
                    playbackSpeed: 1.0
                )
            )
        )
        
        let viewModel = SettingsViewModel(
            interactor: interactor,
            downloadManager: DownloadManagerMock(),
            router: router,
            analytics: analytics,
            coreAnalytics: coreAnalytics,
            config:  ConfigMock(),
            serverConfig: ServerConfigProtocolMock(),
            upgradeHandler: CourseUpgradeHandlerProtocolMock(),
            upgradeHelper: CourseUpgradeHelperProtocolMock(),
            trackingConsentManager: TrackingConsentManagingMock(),
            storage: CoreStorageMock()
        )
        
        await viewModel.logOut()
        
        Verify(router, .showStartupScreen())
        XCTAssertFalse(viewModel.showError)
    }
    
    func testTrackProfileVideoSettingsClicked() {
        let interactor = ProfileInteractorProtocolMock()
        let router = ProfileRouterMock()
        let analytics = ProfileAnalyticsMock()
        let coreAnalytics = CoreAnalyticsMock()
        
        Given(
            interactor,
            .getSettings(
                willReturn: UserSettings(
                    wifiOnly: true,
                    streamingQuality: .auto,
                    downloadQuality: .auto,
                    playbackSpeed: 1.0
                )
            )
        )
        
        let viewModel = SettingsViewModel(
            interactor: interactor,
            downloadManager: DownloadManagerMock(),
            router: router,
            analytics: analytics,
            coreAnalytics: coreAnalytics,
            config:  ConfigMock(),
            serverConfig: ServerConfigProtocolMock(),
            upgradeHandler: CourseUpgradeHandlerProtocolMock(),
            upgradeHelper: CourseUpgradeHelperProtocolMock(),
            trackingConsentManager: TrackingConsentManagingMock(),
            storage: CoreStorageMock()
        )
        
        viewModel.trackProfileVideoSettingsClicked()
        
        Verify(analytics, 1, .profileVideoSettingsClicked())
    }
    
    func testTrackEmailSupportClicked() {
        let interactor = ProfileInteractorProtocolMock()
        let router = ProfileRouterMock()
        let analytics = ProfileAnalyticsMock()
        let coreAnalytics = CoreAnalyticsMock()
        
        Given(
            interactor,
            .getSettings(
                willReturn: UserSettings(
                    wifiOnly: true,
                    streamingQuality: .auto,
                    downloadQuality: .auto,
                    playbackSpeed: 1.0
                )
            )
        )
        
        let viewModel = SettingsViewModel(
            interactor: interactor,
            downloadManager: DownloadManagerMock(),
            router: router,
            analytics: analytics,
            coreAnalytics: coreAnalytics,
            config:  ConfigMock(),
            serverConfig: ServerConfigProtocolMock(),
            upgradeHandler: CourseUpgradeHandlerProtocolMock(),
            upgradeHelper: CourseUpgradeHelperProtocolMock(),
            trackingConsentManager: TrackingConsentManagingMock(),
            storage: CoreStorageMock()
        )
        
        viewModel.trackEmailSupportClicked()
        
        Verify(analytics, 1, .emailSupportClicked())
    }
    
    func testTrackCookiePolicyClicked() {
        let interactor = ProfileInteractorProtocolMock()
        let router = ProfileRouterMock()
        let analytics = ProfileAnalyticsMock()
        let coreAnalytics = CoreAnalyticsMock()
        
        Given(
            interactor,
            .getSettings(
                willReturn: UserSettings(
                    wifiOnly: true,
                    streamingQuality: .auto,
                    downloadQuality: .auto,
                    playbackSpeed: 1.0
                )
            )
        )
        
        let viewModel = SettingsViewModel(
            interactor: interactor,
            downloadManager: DownloadManagerMock(),
            router: router,
            analytics: analytics,
            coreAnalytics: coreAnalytics,
            config:  ConfigMock(),
            serverConfig: ServerConfigProtocolMock(),
            upgradeHandler: CourseUpgradeHandlerProtocolMock(),
            upgradeHelper: CourseUpgradeHelperProtocolMock(),
            trackingConsentManager: TrackingConsentManagingMock(),
            storage: CoreStorageMock()
        )
        
        viewModel.trackCookiePolicyClicked()
        
        Verify(analytics, 1, .cookiePolicyClicked())
    }
    
    func testTrackPrivacyPolicyClicked() {
        let interactor = ProfileInteractorProtocolMock()
        let router = ProfileRouterMock()
        let analytics = ProfileAnalyticsMock()
        let coreAnalytics = CoreAnalyticsMock()
        
        Given(
            interactor,
            .getSettings(
                willReturn: UserSettings(
                    wifiOnly: true,
                    streamingQuality: .auto,
                    downloadQuality: .auto,
                    playbackSpeed: 1.0
                )
            )
        )
        
        let viewModel = SettingsViewModel(
            interactor: interactor,
            downloadManager: DownloadManagerMock(),
            router: router,
            analytics: analytics,
            coreAnalytics: coreAnalytics,
            config:  ConfigMock(),
            serverConfig: ServerConfigProtocolMock(),
            upgradeHandler: CourseUpgradeHandlerProtocolMock(),
            upgradeHelper: CourseUpgradeHelperProtocolMock(),
            trackingConsentManager: TrackingConsentManagingMock(),
            storage: CoreStorageMock()
        )
        
        viewModel.trackPrivacyPolicyClicked()
        
        Verify(analytics, 1, .privacyPolicyClicked())
    }
    
    func testTrackProfileEditClicked() {
        let interactor = ProfileInteractorProtocolMock()
        let router = ProfileRouterMock()
        let analytics = ProfileAnalyticsMock()
        let coreAnalytics = CoreAnalyticsMock()
        
        Given(
            interactor,
            .getSettings(
                willReturn: UserSettings(
                    wifiOnly: true,
                    streamingQuality: .auto,
                    downloadQuality: .auto,
                    playbackSpeed: 1.0
                )
            )
        )
        
        let viewModel = SettingsViewModel(
            interactor: interactor,
            downloadManager: DownloadManagerMock(),
            router: router,
            analytics: analytics,
            coreAnalytics: coreAnalytics,
            config:  ConfigMock(),
            serverConfig: ServerConfigProtocolMock(),
            upgradeHandler: CourseUpgradeHandlerProtocolMock(),
            upgradeHelper: CourseUpgradeHelperProtocolMock(),
            trackingConsentManager: TrackingConsentManagingMock(),
            storage: CoreStorageMock()
        )
        
        viewModel.trackProfileEditClicked()
        
        Verify(analytics, 1, .profileEditClicked())
    }
}
