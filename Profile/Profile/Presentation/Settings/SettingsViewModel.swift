//
//  SettingsViewModel.swift
//  Profile
//
//  Created by  Stepanok Ivan on 16.03.2023.
//

import Foundation
import Core
import SwiftUI
import Combine

public class SettingsViewModel: ObservableObject {
    
    @Published private(set) var isShowProgress = false
    @Published var showError: Bool = false
    @Published var datadogTrackingEnabled: Bool {
        willSet {
            if newValue != datadogTrackingEnabled {
                storage.datadogTrackingEnabled = newValue
                trackingConsentManager.setTrackingConsent(granted: newValue)
            }
        }
    }

    @Published var wifiOnly: Bool {
        willSet {
            if newValue != wifiOnly {
                userSettings.wifiOnly = newValue
                interactor.saveSettings(userSettings)
            }
        }
    }
    
    @Published var selectedQuality: StreamingQuality {
        willSet {
            if newValue != selectedQuality {
                userSettings.streamingQuality = newValue
                interactor.saveSettings(userSettings)
            }
        }
    }

    let quality = Array(
        [
            StreamingQuality.auto,
            StreamingQuality.low,
            StreamingQuality.medium,
            StreamingQuality.high
        ]
        .enumerated()
    )
    
    enum VersionState {
        case actual
        case updateNeeded
        case updateRequired
    }
    
    @Published var versionState: VersionState = .actual
    @Published var currentVersion: String = ""
    @Published var latestVersion: String = ""

    var errorMessage: String? {
        didSet {
            withAnimation {
                showError = errorMessage != nil
            }
        }
    }
    
    @Published private(set) var userSettings: UserSettings
    
    private var cancellables = Set<AnyCancellable>()

    private let interactor: ProfileInteractorProtocol
    private let downloadManager: DownloadManagerProtocol
    let router: ProfileRouter
    let analytics: ProfileAnalytics
    let coreAnalytics: CoreAnalytics
    let config: ConfigProtocol
    let serverConfig: ServerConfigProtocol
    let upgradeHandler: CourseUpgradeHandlerProtocol
    let upgradeHelper: CourseUpgradeHelperProtocol?
    private let trackingConsentManager: TrackingConsentManaging
    private var storage: CoreStorage
    
    public init(
        interactor: ProfileInteractorProtocol,
        downloadManager: DownloadManagerProtocol,
        router: ProfileRouter,
        analytics: ProfileAnalytics,
        coreAnalytics: CoreAnalytics,
        config: ConfigProtocol,
        serverConfig: ServerConfigProtocol,
        upgradeHandler: CourseUpgradeHandlerProtocol,
        upgradeHelper: CourseUpgradeHelperProtocol? = nil,
        trackingConsentManager: TrackingConsentManaging,
        storage: CoreStorage
    ) {
        self.interactor = interactor
        self.downloadManager = downloadManager
        self.router = router
        self.analytics = analytics
        self.coreAnalytics = coreAnalytics
        self.config = config
        self.serverConfig = serverConfig
        self.upgradeHandler = upgradeHandler
        self.upgradeHelper = upgradeHelper
        self.trackingConsentManager = trackingConsentManager
        self.storage = storage

        let userSettings = interactor.getSettings()
        self.userSettings = userSettings
        self.datadogTrackingEnabled = storage.datadogTrackingEnabled ?? true
        self.wifiOnly = userSettings.wifiOnly
        self.selectedQuality = userSettings.streamingQuality
        
        generateVersionState()
    }
    
    func generateVersionState() {
        guard let info = Bundle.main.infoDictionary else { return }
        guard let currentVersion = info["CFBundleShortVersionString"] as? String else { return }
        self.currentVersion = currentVersion
        NotificationCenter.default.publisher(for: .onActualVersionReceived)
            .sink { [weak self] notification in
                guard let latestVersion = notification.object as? String else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.latestVersion = latestVersion
                    
                    if latestVersion != currentVersion {
                        self?.versionState = .updateNeeded
                    }
                }
            }.store(in: &cancellables)
    }
    
    func contactSupport() -> URL? {
        return EmailTemplates.contactSupport(
            email: config.feedbackEmail,
            emailSubject: CoreLocalization.feedbackEmailSubject
        )
    }

    func update(downloadQuality: DownloadQuality) {
        self.userSettings.downloadQuality = downloadQuality
        interactor.saveSettings(userSettings)
    }
    
    func openAppStore() {
        guard let appStoreURL = URL(string: config.appStoreLink) else { return }
        UIApplication.shared.open(appStoreURL)
    }
    
    @MainActor
    func logOut() async {
        try? await interactor.logOut()
        try? await downloadManager.cancelAllDownloading()
        router.showStartupScreen()
        analytics.userLogout(force: false)
        NotificationCenter.default.post(
            name: .userLoggedOut,
            object: nil,
            userInfo: [Notification.UserInfoKey.isForced: false]
        )
    }
    
    func trackProfileVideoSettingsClicked() {
        analytics.profileVideoSettingsClicked()
    }
    
    func trackProfilePushSettingsClicked() {
        analytics.profileTrackEvent(
            .profilePushSettingsClicked,
            biValue: .profilePushSettingsClicked
        )
    }

    func trackAppearanceSettingsClicked() {
        analytics.profileTrackEvent(
            .profileAppearanceSettingClicked,
            biValue: .profileAppearanceSettingClicked
        )
    }

    func trackEmailSupportClicked() {
        analytics.emailSupportClicked()
    }
    
    func trackCookiePolicyClicked() {
        analytics.cookiePolicyClicked()
    }
    
    func trackTOSClicked() {
        analytics.tosClicked()
    }
    
    func trackFAQClicked() {
        analytics.faqClicked()
    }
    
    func trackDataSellClicked() {
        analytics.dataSellClicked()
    }
    
    func trackPrivacyPolicyClicked() {
        analytics.privacyPolicyClicked()
    }
    
    func trackProfileEditClicked() {
        analytics.profileEditClicked()
    }
    
    func trackLogoutClickedClicked() {
        analytics.profileTrackEvent(.userLogoutClicked, biValue: .userLogoutClicked)
    }
    
    func trackHelpUsImprove() {
        analytics.profileTrackEvent(.profilehelpUsImprove, biValue: .profilehelpUsImprove)
    }
    
    @MainActor
    func restorePurchases() async {
        coreAnalytics.trackRestorePurchaseClicked()
        router.showRestoreProgressView()
        
        let inProgressIAPs = CourseUpgradeHelper.getAllInProgressIAP(
            loggedInUserID: storage.user?.id ?? .zero
        )
        guard !inProgressIAPs.isEmpty else {
            hideRestoreProgressView(showAlert: true, delay: 3)
            return
        }
        
        var showAlert = false
        
        for inprogressIAP in inProgressIAPs {
            do {
                let product = try await upgradeHandler.fetchProduct(sku: inprogressIAP.sku)
                showAlert = await fulfillPurchase(inprogressIAP: inprogressIAP, product: product)
            } catch {
                showAlert = true
            }
        }
        
        // Only hide once when all purchases have been processed
        hideRestoreProgressView(showAlert: showAlert)
    }
    
    private func fulfillPurchase(inprogressIAP: InProgressIAP, product: StoreProductInfo) async -> Bool {
        coreAnalytics.trackCourseUnfulfilledPurchaseInitiated(
            courseID: inprogressIAP.courseID,
            pacing: inprogressIAP.pacing,
            screen: .dashboard,
            flowType: .restore
        )
        
        return await withCheckedContinuation { continuation in
            // Run the async upgradeCourse in a detached Task so we can wait for the completion callback
            Task { [weak self] in
                let lock = NSLock()
                var resumed = false
                
                func resumeOnce(_ value: Bool) {
                    lock.lock()
                    defer { lock.unlock() }
                    guard !resumed else { return }
                    resumed = true
                    continuation.resume(returning: value)
                }
                
                // Start a timeout guard so we don't hang if neither .complete nor .error comes.
                let timeoutTask = Task {
                    try? await Task.sleep(nanoseconds: 15 * 1_000_000_000)
                    resumeOnce(false)
                }
                
                guard let strongSelf = self else {
                    continuation.resume(returning: false)
                    return
                }
                
                await strongSelf.upgradeHandler.upgradeCourse(
                    sku: inprogressIAP.sku,
                    mode: .restore,
                    productInfo: product,
                    pacing: inprogressIAP.pacing,
                    courseID: inprogressIAP.courseID,
                    lmsPrice: inprogressIAP.lmsPrice,
                    componentID: nil,
                    screen: .dashboard,
                    completion: { [weak self] state in
                        guard self != nil else {
                            timeoutTask.cancel()
                            resumeOnce(false)
                            return
                        }
                        switch state {
                        case .complete, .unverified, .error:
                            timeoutTask.cancel()
                            resumeOnce(false)
                        default:
                            debugLog("Upgrade state changed: \(state)")
                            // don't resume here; wait for .complete/.unverified/.error
                        }
                    }
                )
            }
        }
    }
    
    private func hideRestoreProgressView(showAlert: Bool = false, delay: TimeInterval = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            Task {
                self?.router.hideRestoreProgressView()
                if showAlert {
                    self?.upgradeHelper?.showRestorePurchasesAlert()
                }
            }
        }
    }
}

public extension StreamingQuality {
    
    func title() -> String {
        switch self {
        case .auto:
            return ProfileLocalization.Settings.qualityAutoTitle
        case .low:
            return ProfileLocalization.Settings.quality360Title
        case .medium:
            return ProfileLocalization.Settings.quality540Title
        case .high:
            return ProfileLocalization.Settings.quality720Title
        }
    }
    
    func description() -> String? {
        switch self {
        case .auto:
            return ProfileLocalization.Settings.qualityAutoDescription
        case .low:
            return ProfileLocalization.Settings.quality360Description
        case .medium:
            return nil
        case .high:
            return ProfileLocalization.Settings.quality720Description
        }
    }
    
    func settingsDescription() -> String {
        switch self {
        case .auto:
            return ProfileLocalization.Settings.qualityAutoTitle + " ("
            + ProfileLocalization.Settings.qualityAutoDescription + ")"
        case .low:
            return ProfileLocalization.Settings.quality360Title + " ("
            + ProfileLocalization.Settings.quality360Description + ")"
        case .medium:
            return ProfileLocalization.Settings.quality540Title
        case .high:
            return ProfileLocalization.Settings.quality720Title + " ("
            + ProfileLocalization.Settings.quality720Description + ")"
        }
    }
}
