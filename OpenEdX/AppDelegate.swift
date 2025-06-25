//
//  AppDelegate.swift
//  OpenEdX
//
//  Created by Vladimir Chekyrta on 13.09.2022.
//

import UIKit
import Core
import OEXFoundation
import Swinject
import Profile
import GoogleSignIn
import FacebookCore
import MSAL
import UserNotifications
import OEXFirebaseAnalytics
import FirebaseCore
import FirebaseMessaging
import Theme
import BackgroundTasks
import EDXMobileAnalytics
import EDXIAPService
import Course

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let bgAppTaskId = "openEdx.offlineProgressSync"
    
    static var shared: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }

    var window: UIWindow?
        
    private let pluginManager = PluginManager()
    private var assembler: Assembler?
    
    private var lastForceLogoutTime: TimeInterval = 0
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        initDI()
        initPlugins()
        
        if let config = Container.shared.resolve(ConfigProtocol.self) {
            Theme.Shapes.isRoundedCorners = config.theme.isRoundedCorners
            Theme.Shapes.buttonCornersRadius = config.theme.buttonCornersRadius
            
            if config.facebook.enabled {
                ApplicationDelegate.shared.application(
                    application,
                    didFinishLaunchingWithOptions: launchOptions
                )
            }
            configureDeepLinkServices(launchOptions: launchOptions)
            
            // IAP enabled is server configureable and fetched in enrollments API
            // IAP config isn't available on app launch so that's why checking for
            // e-commerce URL, e-commerce URL is being used for IAP
            
            // NEEDS WORK: check if we need to complete unfinished transactions via plugin
//            if let storekitHandler = Container.shared.resolve(StoreKitHandlerProtocol.self),
//               config.ecommerceURL?.isEmpty == false {
//                storekitHandler.completeTransactions()
//            }
            
            let pushManager = Container.shared.resolve(PushNotificationsManager.self)
            
            if config.firebase.enabled {
                FirebaseApp.configure()
                if config.firebase.cloudMessagingEnabled {
                    Messaging.messaging().delegate = pushManager
                    UNUserNotificationCenter.current().delegate = pushManager
                }
            }
            
            if pushManager?.hasProviders == true {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        Theme.Fonts.registerFonts()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RouteController()
        window?.makeKeyAndVisible()
        window?.tintColor = Theme.UIColors.accentColor
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUserAuthorize),
            name: .userAuthorized,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUserLogout),
            name: .userLoggedOut,
            object: nil
        )
        
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        guard let config = Container.shared.resolve(ConfigProtocol.self) else { return false }

        if let deepLinkManager = Container.shared.resolve(DeepLinkManager.self),
            deepLinkManager.anyServiceEnabled {
            if deepLinkManager.handledURLWith(app: app, open: url, options: options) {
                return true
            }
        }

        if config.facebook.enabled {
            if ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            ) {
                return true
            }
        }

        if config.google.enabled {
            if GIDSignIn.sharedInstance.handle(url) {
                return true
            }
        }

        if config.microsoft.enabled {
            if MSALPublicClientApplication.handleMSALResponse(
                url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
            ) {
                return true
            }
        }

        return false
    }
    
    private func initPlugins() {
        guard let config = Container.shared.resolve(ConfigProtocol.self) else { return }
        if config.firebase.enabled && config.firebase.isAnalyticsSourceFirebase {
            pluginManager.addPlugin(analyticsService: FirebaseAnalyticsService())
        }
        
        // - FCM
        if config.firebase.cloudMessagingEnabled,
            let storage = Container.shared.resolve(CoreStorage.self),
            let api = Container.shared.resolve(API.self),
            let deepLinkManager = Container.shared.resolve(DeepLinkManager.self) {
            pluginManager.addPlugin(
                pushNotificationsProvider: FCMProvider(storage: storage, api: api),
                pushNotificationsListener: FCMListener(deepLinkManager: deepLinkManager)
            )
        }
        // Initialize your plugins here
        // - Segment analytic
        if config.segment.enabled {
            pluginManager.addPlugin(analyticsService: Container.shared.resolve(SegmentAnalyticsService.self)!)
        }
        // - Braze
        if config.braze.pushNotificationsEnabled,
            let deepLinkManager = Container.shared.resolve(DeepLinkManager.self) {
            pluginManager.addPlugin(
                pushNotificationsProvider:
                    BrazeProvider(
                        segmentAnalyticsService: Container.shared.resolve(SegmentAnalyticsService.self)!
                    ),
                pushNotificationsListener:
                    BrazeListener(
                        deepLinkManager: deepLinkManager,
                        segmentAnalyticsService: Container.shared.resolve(SegmentAnalyticsService.self)
                    )
            )
        }
        // - FCM
        if config.firebase.cloudMessagingEnabled,
            let storage = Container.shared.resolve(CoreStorage.self),
            let api = Container.shared.resolve(API.self),
            let deepLinkManager = Container.shared.resolve(DeepLinkManager.self) {
            pluginManager.addPlugin(
                pushNotificationsProvider: FCMProvider(storage: storage, api: api),
                pushNotificationsListener: FCMListener(deepLinkManager: deepLinkManager)
            )
        }
        // - IAP
        let analyticsService = Container.shared.resolve(AnalyticsManager.self) ?? AnalyticsManager(services: [])
        let analytics = EDXAnalytics(service: analyticsService)
        if let ecommerceURL = config.ecommerceURL, !ecommerceURL.isEmpty {
            let edxIAPConfig = EDXServiceConfig(
                ecommerceURL: ecommerceURL,
                paymentProcessor: "ios-iap",
                feedbackEmail: config.feedbackEmail
            )
            let validator = EDXReceiptValidator(
                config: edxIAPConfig
            )
            let iapService = EDXIAPService(
                provider: .init(
                    request: { product in
                        let interactor = Container.shared.resolve(CourseInteractorProtocol.self)
                        // NEEDS WORK. Remove interactor and use API call to
                        // retrieve Data object, serialize and create product
                        if let courseStructure = try await interactor?.getCourseBlocks(courseID: product.id) {
                            return EDXProductInfo(
                                productName: courseStructure.displayName,
                                sku: courseStructure.sku ?? "",
                                courseID: courseStructure.id,
                                isSelfPaced: courseStructure.isSelfPaced,
                                lmsPrice: courseStructure.lmsPrice ?? .zero
                            )
                        }
                        throw EDXProviderError.cantObtainInfo
                    },
                    product: { object in
                        if let primaryCourse = object as? PrimaryCourse {
                            return EDXProduct(id: primaryCourse.courseID, name: primaryCourse.name, screen: .dashboard)
                        }
                        return nil
                    }
                ),
                analyticsFacade: analytics,
                validator: validator,
                config: edxIAPConfig
            )
            pluginManager.setIAPService(iapService)
        }
        // - FullStory
        /**
         This check is `edX/2U` specific.
         We only want to record FullStory events for the `PROD` environment for the following reasons:
         1. `Dev` & `Stage` environments has `orgID` of Test Organization named `2U - Mobile Apps`, and we do not want
         to record events or other data for this test organization.
         2. Initially, we set up conditional loading for the FullStory SDK, but it caused issues with enabling
         SwiftUI-based views in FullStory sessions.
         We reached out to FullStory's technical support team, who informed us that conditional integration of
         the FullStory SDK is not possible. As a
         workaround, we used the test organization `2U - Mobile Apps` and its `orgID` for the `Dev` and `Stage`
         environments to avoid disrupting the SDK functionality. We have also communicated our usage strategy to
         FullStory's support team and requested a more effective solution in future SDK updates.
         */
        #if PROD
        if config.fullStory.enabled {
            pluginManager.addPlugin(analyticsService: Container.shared.resolve(FullStoryAnalyticsService.self)!)
        }
        #endif
    }

    private func initDI() {
        let navigation = UINavigationController()
        navigation.modalPresentationStyle = .fullScreen
        
        assembler = Assembler(
            [
                AppAssembly(navigation: navigation, pluginManager: pluginManager),
                NetworkAssembly(),
                ScreenAssembly()
            ],
            container: Container.shared
        )
    }
    
    @objc private func didUserAuthorize() {
        Container.shared.resolve(PushNotificationsManager.self)?.synchronizeToken()
    }
    
    @objc func didUserLogout(_ notification: Notification) {
        guard Date().timeIntervalSince1970 - lastForceLogoutTime > 5 else {
            return
        }
        if let userInfo = notification.userInfo,
           userInfo[Notification.UserInfoKey.isForced] as? Bool == true {
            let analyticsManager = Container.shared.resolve(AnalyticsManager.self)
            analyticsManager?.userLogout(force: true)
            
            lastForceLogoutTime = Date().timeIntervalSince1970
            Container.shared.resolve(CoreStorage.self)?.clear()
            
            Task {
                await Container.shared.resolve(CorePersistenceProtocol.self)?.deleteAllProgress()
                await Container.shared.resolve(DownloadManagerProtocol.self)?.deleteAll()
                await Container.shared.resolve(CoreDataHandlerProtocol.self)?.clear()
            }
            window?.rootViewController = RouteController()
        }
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        Container.shared.resolve(PushNotificationsManager.self)?.refreshToken()
    }
    
    // Push Notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard let pushManager = Container.shared.resolve(PushNotificationsManager.self) else { return }
        pushManager.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        guard let pushManager = Container.shared.resolve(PushNotificationsManager.self) else { return }
        pushManager.didFailToRegisterForRemoteNotificationsWithError(error: error)
    }
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let pushManager = Container.shared.resolve(PushNotificationsManager.self) else {
            completionHandler(.newData)
            return
        }
        pushManager.didReceiveRemoteNotification(userInfo: userInfo)
        completionHandler(.newData)
    }
    
    // Deep link
    func configureDeepLinkServices(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let deepLinkManager = Container.shared.resolve(DeepLinkManager.self) else { return }
        deepLinkManager.configureDeepLinkService(launchOptions: launchOptions)
    }
    
    // Background progress update
    
    func registerBackgroundTask() {
        let isRegistered = BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.bgAppTaskId,
            using: nil
        ) { task in
            debugLog("Background task is executing: \(task.identifier)")
            guard let task = task as? BGAppRefreshTask else { return }
            self.handleAppRefreshTask(task: task)
        }
        debugLog("Is the background task registered? \(isRegistered)")
    }
    
    func handleAppRefreshTask(task: BGAppRefreshTask) {
        //In real case scenario we should check internet here
        reScheduleAppRefresh()
        
        task.expirationHandler = {
            //This Block call by System
            //Canel your all tak's & queues
            task.setTaskCompleted(success: true)
        }
        
        let offlineSyncManager = Container.shared.resolve(OfflineSyncManagerProtocol.self)!
        Task {
            await offlineSyncManager.syncOfflineProgress()
            task.setTaskCompleted(success: true)
        }
    }
    
    func reScheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.bgAppTaskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // App Refresh after 60 minute.
        //Note :: EarliestBeginDate should not be set to too far into the future.
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            debugLog("Could not schedule app refresh: \(error)")
        }
    }
}
