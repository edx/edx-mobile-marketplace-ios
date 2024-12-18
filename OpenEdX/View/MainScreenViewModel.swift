//
//  MainScreenViewModel.swift
//  OpenEdX
//
//  Created by  Stepanok Ivan on 30.10.2023.
//

import Foundation
import Core
import Profile
import Combine
import Authorization
import UserNotifications

final class MainScreenViewModel: ObservableObject {

    private let analytics: MainScreenAnalytics
    let config: ConfigProtocol
    let profileInteractor: ProfileInteractorProtocol
    var sourceScreen: LogistrationSourceScreen
    private var postLoginData: PostLoginData?
    
    @Published var selection: MainTab = .dashboard
    @Published var showRegisterBanner: Bool = false

    init(analytics: MainScreenAnalytics,
         config: ConfigProtocol,
         profileInteractor: ProfileInteractorProtocol,
         sourceScreen: LogistrationSourceScreen = .default,
         postLoginData: PostLoginData? = nil
    ) {
        self.analytics = analytics
        self.config = config
        self.profileInteractor = profileInteractor
        self.sourceScreen = sourceScreen
        self.postLoginData = postLoginData
        trackSettingPermissionStatus()
    }
    
    private func trackSettingPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { [weak self] (settings) in
            if settings.authorizationStatus == .notDetermined {
                self?.analytics.notificationPermissionStatus(status: "not_determined")
            } else if settings.authorizationStatus == .denied {
                self?.analytics.notificationPermissionStatus(status: "denied")
            } else if settings.authorizationStatus == .authorized {
                self?.analytics.notificationPermissionStatus(status: "authorized")
            }
        })
    }
    
    public func select(tab: MainTab) {
        selection = tab
    }

    func trackMainDiscoveryTabClicked() {
        analytics.mainDiscoveryTabClicked()
    }
    
    func trackMainDashboardLearnTabClicked() {
        analytics.mainLearnTabClicked()
    }
    
    func trackMainProgramsTabClicked() {
        analytics.mainProgramsTabClicked()
    }
    
    func trackMainProfileTabClicked() {
        analytics.mainProfileTabClicked()
    }
    
    func trackMainDashboardMyCoursesClicked() {
        analytics.mainCoursesClicked()
    }

    public func checkIfNeedToShowRegisterBanner() {
        if postLoginData?.showSocialRegisterBanner == true && !registerBannerText.isEmpty {
            showRegisterBanner = true
        }
    }
    public func registerBannerWasShowed() {
        postLoginData?.showSocialRegisterBanner = false
        showRegisterBanner = false
    }
    public var registerBannerText: String {
        guard let socialAuthMethodName = postLoginData?.authMethod,
              !socialAuthMethodName.isEmpty
        else { return "" }
        return CoreLocalization.Mainscreen.socialRegisterBanner(config.platformName, socialAuthMethodName.capitalized)
    }

    @MainActor
    func prefetchDataForOffline() async {
        if profileInteractor.getMyProfileOffline() == nil {
            _ = try? await profileInteractor.getMyProfile()
        }
    }
    
}
