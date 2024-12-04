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

    @Published var selection: MainTab = .dashboard
    @Published var showRegisterBanner: Bool = false

    private var shouldShowRegisterBanner: Bool = false
    private var authMethod: AuthMethod?
    private var cancellations: [AnyCancellable] = []

    init(analytics: MainScreenAnalytics,
         config: ConfigProtocol,
         profileInteractor: ProfileInteractorProtocol,
         sourceScreen: LogistrationSourceScreen = .default
    ) {
        self.analytics = analytics
        self.config = config
        self.profileInteractor = profileInteractor
        self.sourceScreen = sourceScreen
        addObservers()
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
    
    private func addObservers() {
        NotificationCenter.default
            .publisher(for: .userAuthorized)
            .sink { [weak self] object in
                guard let self,
                      let dict = object.object as? [String: Any],
                      let authMethod = dict["authMethod"] as? AuthMethod
                else { return }
                self.shouldShowRegisterBanner = dict["showSocialRegisterBanner"] as? Bool ?? false
                self.authMethod = authMethod
            }
            .store(in: &cancellations)
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
        if shouldShowRegisterBanner && !registerBannerText.isEmpty {
            showRegisterBanner = true
        }
    }
    public func registerBannerWasShowed() {
        shouldShowRegisterBanner = false
        showRegisterBanner = false
    }
    public var registerBannerText: String {
        guard !config.platformName.isEmpty,
              case .socailAuth(let socialMethod) = authMethod,
              !socialMethod.rawValue.isEmpty
        else { return "" }
        return CoreLocalization.Mainscreen.socialRegisterBanner(config.platformName, socialMethod.rawValue.capitalized)
    }

    @MainActor
    func prefetchDataForOffline() async {
        if profileInteractor.getMyProfileOffline() == nil {
            _ = try? await profileInteractor.getMyProfile()
        }
    }
    
}
