//
//  ScreenAssembly.swift
//  OpenEdX
//
//  Created by Vladimir Chekyrta on 14.09.2022.
//

import Foundation
import Swinject
import Core
import Authorization
import Discovery
import Dashboard
import Profile
import Course
import Discussion
import Combine
import Notifications
import EDXFeatureManagement

// swiftlint:disable function_body_length type_body_length
class ScreenAssembly: Assembly {
    func assemble(container: Container) {
        
        // MARK: Auth
        container.register(AuthRepositoryProtocol.self) { r in
            AuthRepository(
                api: r.resolve(API.self)!,
                appStorage: r.resolve(CoreStorage.self)!,
                config: r.resolve(ConfigProtocol.self)!
            )
        }
        container.register(AuthInteractorProtocol.self) { r in
            AuthInteractor(
                repository: r.resolve(AuthRepositoryProtocol.self)!,
                featureManager: r.resolve(UserSessionManaging.self)!,
                captchaService: r.resolve(CaptchaService.self)!
            )
        }
        
        // MARK: MainScreenView
        container.register(MainScreenViewModel.self) { r, sourceScreen, postLoginData in
            MainScreenViewModel(
                analytics: r.resolve(MainScreenAnalytics.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                notificationsInteractor: r.resolve(NotificationsInteractorProtocol.self)!,
                profileInteractor: r.resolve(ProfileInteractorProtocol.self)!,
                sourceScreen: sourceScreen,
                postLoginData: postLoginData
            )
        }
        // MARK: Startup screen
        container.register(StartupViewModel.self) { r in
            StartupViewModel(
                router: r.resolve(AuthorizationRouter.self)!,
                analytics: r.resolve(CoreAnalytics.self)!
            )
        }
        
        // MARK: SignIn
        container.register(SignInViewModel.self) { r, sourceScreen in
            SignInViewModel(
                interactor: r.resolve(AuthInteractorProtocol.self)!,
                router: r.resolve(AuthorizationRouter.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                analytics: r.resolve(AuthorizationAnalytics.self)!,
                validator: r.resolve(Validator.self)!,
                storage: r.resolve(CoreStorage.self)!,
                sourceScreen: sourceScreen
            )
        }
        container.register(SignUpViewModel.self) { r, sourceScreen in
            SignUpViewModel(
                interactor: r.resolve(AuthInteractorProtocol.self)!,
                router: r.resolve(AuthorizationRouter.self)!,
                analytics: r.resolve(AuthorizationAnalytics.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                cssInjector: r.resolve(CSSInjector.self)!,
                validator: r.resolve(Validator.self)!,
                storage: r.resolve(CoreStorage.self)!,
                sourceScreen: sourceScreen
            )
        }
        container.register(ResetPasswordViewModel.self) { r in
            ResetPasswordViewModel(
                interactor: r.resolve(AuthInteractorProtocol.self)!,
                router: r.resolve(AuthorizationRouter.self)!,
                analytics: r.resolve(AuthorizationAnalytics.self)!,
                validator: r.resolve(Validator.self)!
            )
        }
        
        // MARK: Discovery
        container.register(DiscoveryPersistenceProtocol.self) { r in
            DiscoveryPersistence(context: r.resolve(DatabaseManager.self)!.context)
        }
        
        container.register(DiscoveryRepositoryProtocol.self) { r in
            DiscoveryRepository(
                api: r.resolve(API.self)!,
                appStorage: r.resolve(CoreStorage.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                persistence: r.resolve(DiscoveryPersistenceProtocol.self)!
            )
        }
        container.register(DiscoveryInteractorProtocol.self) { r in
            DiscoveryInteractor(
                repository: r.resolve(DiscoveryRepositoryProtocol.self)!
            )
        }
        container.register(DiscoveryViewModel.self) { r in
            DiscoveryViewModel(
                router: r.resolve(DiscoveryRouter.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                interactor: r.resolve(DiscoveryInteractorProtocol.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                analytics: r.resolve(DiscoveryAnalytics.self)!,
                storage: r.resolve(CoreStorage.self)!
            )
        }
        
        container.register(DiscoveryWebviewViewModel.self) { r, sourceScreen in
            DiscoveryWebviewViewModel(
                router: r.resolve(DiscoveryRouter.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                interactor: r.resolve(DiscoveryInteractorProtocol.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                analytics: r.resolve(DiscoveryAnalytics.self)!,
                storage: r.resolve(CoreStorage.self)!,
                sourceScreen: sourceScreen,
                datadogManager: r.resolve(DataDogFeatureManager.self)!
            )
        }
        
        container.register(ProgramWebviewViewModel.self) { r in
            ProgramWebviewViewModel(
                router: r.resolve(DiscoveryRouter.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                interactor: r.resolve(DiscoveryInteractorProtocol.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                analytics: r.resolve(DiscoveryAnalytics.self)!,
                authInteractor: r.resolve(AuthInteractorProtocol.self)!,
                datadogManager: r.resolve(DataDogFeatureManager.self)!
            )
        }
        
        container.register(SearchViewModel.self) { r in
            SearchViewModel(
                interactor: r.resolve(DiscoveryInteractorProtocol.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                router: r.resolve(DiscoveryRouter.self)!,
                analytics: r.resolve(DiscoveryAnalytics.self)!,
                debounce: .searchDebounce
            )
        }
        
        // MARK: Dashboard
        container.register(DashboardPersistenceProtocol.self) { r in
            DashboardPersistence(context: r.resolve(DatabaseManager.self)!.context)
        }
        
        container.register(DashboardRepositoryProtocol.self) { r in
            DashboardRepository(
                api: r.resolve(API.self)!,
                storage: r.resolve(CoreStorage.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                persistence: r.resolve(DashboardPersistenceProtocol.self)!,
                serverConfig: r.resolve(ServerConfigProtocol.self)!
            )
        }
        container.register(DashboardInteractorProtocol.self) { r in
            DashboardInteractor(
                repository: r.resolve(DashboardRepositoryProtocol.self)!
            )
        }
        container.register(ListDashboardViewModel.self) { r in
            ListDashboardViewModel(
                interactor: r.resolve(DashboardInteractorProtocol.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                analytics: r.resolve(DashboardAnalytics.self)!,
                upgradehandler: r.resolve(CourseUpgradeHandlerProtocol.self)!,
                coreAnalytics: r.resolve(CoreAnalytics.self)!,
                serverConfig: r.resolve(ServerConfigProtocol.self)!,
                storage: r.resolve(CoreStorage.self)!
            )
        }
        
        container.register(PrimaryCourseDashboardViewModel.self) { r in
            PrimaryCourseDashboardViewModel(
                interactor: r.resolve(DashboardInteractorProtocol.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                analytics: r.resolve(DashboardAnalytics.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                serverConfig: r.resolve(ServerConfigProtocol.self)!,
                coreAnalytics: r.resolve(CoreAnalytics.self)!,
                upgradehandler: r.resolve(CourseUpgradeHandlerProtocol.self)!,
                storage: r.resolve(CoreStorage.self)!
            )
        }
        
        container.register(AllCoursesViewModel.self) { r in
            AllCoursesViewModel(
                interactor: r.resolve(DashboardInteractorProtocol.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                analytics: r.resolve(DashboardAnalytics.self)!
            )
        }
        
        // MARK: Profile
        
        container.register(ProfileRepositoryProtocol.self) { r in
            ProfileRepository(
                api: r.resolve(API.self)!,
                storage: r.resolve(AppStorage.self)!,
                coreDataHandler: r.resolve(CoreDataHandlerProtocol.self)!,
                downloadManager: r.resolve(DownloadManagerProtocol.self)!,
                config: r.resolve(ConfigProtocol.self)!
            )
        }
        container.register(ProfileInteractorProtocol.self) { r in
            ProfileInteractor(
                repository: r.resolve(ProfileRepositoryProtocol.self)!,
                featureManager: r.resolve(UserSessionManaging.self)!
            )
        }
        container.register(ProfileViewModel.self) { r in
            ProfileViewModel(
                interactor: r.resolve(ProfileInteractorProtocol.self)!,
                router: r.resolve(ProfileRouter.self)!,
                analytics: r.resolve(ProfileAnalytics.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!
            )
        }
        container.register(EditProfileViewModel.self) { r, userModel in
            EditProfileViewModel(
                userModel: userModel,
                interactor: r.resolve(ProfileInteractorProtocol.self)!,
                router: r.resolve(ProfileRouter.self)!,
                analytics: r.resolve(ProfileAnalytics.self)!

            )
        }
        
        container.register(SettingsViewModel.self) { r in
            SettingsViewModel(
                interactor: r.resolve(ProfileInteractorProtocol.self)!,
                downloadManager: r.resolve(DownloadManagerProtocol.self)!,
                router: r.resolve(ProfileRouter.self)!,
                analytics: r.resolve(ProfileAnalytics.self)!,
                coreAnalytics: r.resolve(CoreAnalytics.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                serverConfig: r.resolve(ServerConfigProtocol.self)!,
                upgradeHandler: r.resolve(CourseUpgradeHandlerProtocol.self)!,
                upgradeHelper: r.resolve(CourseUpgradeHelperProtocol.self)!,
                trackingConsentManager: r.resolve(TrackingConsentManaging.self)!,
                storage: r.resolve(CoreStorage.self)!
            )
        }
        
        container.register(NotificationsPersistenceProtocol.self) { r in
            NotificationsPersistence(context: r.resolve(DatabaseManager.self)!.context)
        }
        
        container.register(NotificationsRepositoryProtocol.self) { r in
            NotificationsRepository(
                api: r.resolve(API.self)!,
                appStorage: r.resolve(AppStorage.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                persistence: r.resolve(NotificationsPersistenceProtocol.self)!
            )
        }
        
        container.register(NotificationsInteractorProtocol.self) { r in
            NotificationsInteractor(
                repository: r.resolve(NotificationsRepositoryProtocol.self)!,
                storage: r.resolve(AppStorage.self)!
            )
        }
        
        container.register(NotificationsPrimerViewModel.self) { r in
            NotificationsPrimerViewModel(
                interactor: r.resolve(NotificationsInteractorProtocol.self)!,
                router: r.resolve(NotificationsRouter.self)!,
                analytics: r.resolve(NotificationsAnalytics.self)!
            )
        }
        
        container.register(NotificationsSettingsViewModel.self) { r in
            NotificationsSettingsViewModel(
                interactor: r.resolve(NotificationsInteractorProtocol.self)!,
                analytics: r.resolve(NotificationsAnalytics.self)!,
                router: r.resolve(NotificationsRouter.self)!,
                storage: r.resolve(CoreStorage.self)!
            )
        }

        container.register(AppearanceSettingsViewModel.self) { r in
            AppearanceSettingsViewModel(
                themeManager: r.resolve(ThemeManagerProtocol.self)!,
                router: r.resolve(ProfileRouter.self)!,
                analytics: r.resolve(ProfileAnalytics.self)!
            )
        }

        container.register(DatesAndCalendarViewModel.self) { r in
            DatesAndCalendarViewModel(
                router: r.resolve(ProfileRouter.self)!
            )
        }
        
        container.register(ManageAccountViewModel.self) { r in
            ManageAccountViewModel(
                router: r.resolve(ProfileRouter.self)!,
                analytics: r.resolve(ProfileAnalytics.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                interactor: r.resolve(ProfileInteractorProtocol.self)!
            )
        }
        
        container.register(DeleteAccountViewModel.self) { r in
            DeleteAccountViewModel(
                interactor: r.resolve(ProfileInteractorProtocol.self)!,
                router: r.resolve(ProfileRouter.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                analytics: r.resolve(ProfileAnalytics.self)!
            )
        }
        
        // MARK: Course
        container.register(CoursePersistenceProtocol.self) { r in
            CoursePersistence(context: r.resolve(DatabaseManager.self)!.context)
        }
        
        container.register(CourseRepositoryProtocol.self) { r in
            CourseRepository(
                api: r.resolve(API.self)!,
                coreStorage: r.resolve(CoreStorage.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                persistence: r.resolve(CoursePersistenceProtocol.self)!,
                serverConfig: r.resolve(ServerConfigProtocol.self)!
            )
        }
        container.register(EnrollmentRepositoryProtocol.self) { r in
            EnrollmentRepository(
                api: r.resolve(API.self)!
            )
        }
        container.register(CourseInteractorProtocol.self) { r in
            CourseInteractor(
                repository: r.resolve(CourseRepositoryProtocol.self)!,
                storage: r.resolve(CourseStorage.self)!
            )
        }
        container.register(EnrollmentInteractorProtocol.self) { r in
            EnrollmentInteractor(
                repository: r.resolve(EnrollmentRepositoryProtocol.self)!
            )
        }
        container.register(CourseDetailsViewModel.self) { r in
            CourseDetailsViewModel(
                interactor: r.resolve(DiscoveryInteractorProtocol.self)!,
                router: r.resolve(DiscoveryRouter.self)!,
                analytics: r.resolve(DiscoveryAnalytics.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                cssInjector: r.resolve(CSSInjector.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                storage: r.resolve(CoreStorage.self)!
            )
        }
        
        // MARK: CourseScreensView
        container.register(
            CourseContainerViewModel.self
        ) { r, isActive, courseStart, courseEnd, enrollmentStart, enrollmentEnd, selection, lastVisitedBlockID, showTrackSelection in
            CourseContainerViewModel(
                interactor: r.resolve(CourseInteractorProtocol.self)!,
                authInteractor: r.resolve(AuthInteractorProtocol.self)!,
                enrollmentInteractor: r.resolve(EnrollmentInteractorProtocol.self)!,
                router: r.resolve(CourseRouter.self)!,
                analytics: r.resolve(CourseAnalytics.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                manager: r.resolve(DownloadManagerProtocol.self)!,
                storage: r.resolve(CourseStorage.self)!,
                isActive: isActive,
                courseStart: courseStart,
                courseEnd: courseEnd,
                enrollmentStart: enrollmentStart,
                enrollmentEnd: enrollmentEnd,
                lastVisitedBlockID: lastVisitedBlockID,
                coreAnalytics: r.resolve(CoreAnalytics.self)!,
                selection: selection,
                showTrackSelection: showTrackSelection,
                serverConfig: r.resolve(ServerConfigProtocol.self)!
            )
        }
        
        container.register(CourseVerticalViewModel.self) { r, chapters, chapterIndex, sequentialIndex, courseStructurePublisher in
            CourseVerticalViewModel(
                chapters: chapters,
                chapterIndex: chapterIndex,
                sequentialIndex: sequentialIndex,
                manager: r.resolve(DownloadManagerProtocol.self)!,
                router: r.resolve(CourseRouter.self)!,
                analytics: r.resolve(CourseAnalytics.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                courseStructurePublisher: courseStructurePublisher
            )
        }
        
        container.register(
            CourseUnitViewModel.self
        ) { r, blockId, courseId, courseName, chapters, chapterIndex, sequentialIndex, verticalIndex, courseStructurePublisher in
            CourseUnitViewModel(
                lessonID: blockId,
                courseID: courseId,
                courseName: courseName,
                chapters: chapters,
                chapterIndex: chapterIndex,
                sequentialIndex: sequentialIndex,
                verticalIndex: verticalIndex,
                interactor: r.resolve(CourseInteractorProtocol.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                router: r.resolve(CourseRouter.self)!,
                analytics: r.resolve(CourseAnalytics.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                storage: r.resolve(CourseStorage.self)!,
                manager: r.resolve(DownloadManagerProtocol.self)!,
                serverConfig: r.resolve(ServerConfigProtocol.self)!,
                courseStructurePublisher: courseStructurePublisher,
                upgradeInfoViewModelFactory: { productName, sku, courseID, screen, pacing, lmsPrice in
                    r.resolve(
                        UpgradeInfoViewModel.self,
                        arguments: productName, "", sku, courseID, screen, pacing, lmsPrice
                    )!
                }
            )
        }
        
        container.register(WebUnitViewModel.self) { r in
            WebUnitViewModel(authInteractor: r.resolve(AuthInteractorProtocol.self)!,
                             config: r.resolve(ConfigProtocol.self)!)
        }
        
        container.register(
            YouTubeVideoPlayerViewModel.self
        ) { (r, url: URL?, blockID: String, courseID: String, languages: [SubtitleUrl], playerStateSubject: CurrentValueSubject<VideoPlayerState?, Never>) in
            let router: Router = r.resolve(Router.self)!
            return YouTubeVideoPlayerViewModel(
                languages: languages,
                playerStateSubject: playerStateSubject,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                playerHolder: r.resolve(
                    YoutubePlayerViewControllerHolder.self,
                    arguments: url,
                    blockID,
                    courseID,
                    router.currentCourseTabSelection
                )!,
                appStorage: r.resolve(CoreStorage.self)!,
                analytics: r.resolve(CourseAnalytics.self)!
            )
        }
        
        container.register(EncodedVideoPlayerViewModel.self) { (r, url: URL?, blockID: String, courseID: String, languages: [SubtitleUrl], playerStateSubject: CurrentValueSubject<VideoPlayerState?, Never>) in
            let router: Router = r.resolve(Router.self)!

            let holder = r.resolve(
                PlayerViewControllerHolder.self,
                arguments: url,
                blockID,
                courseID,
                router.currentCourseTabSelection
            )!
            return EncodedVideoPlayerViewModel(
                languages: languages,
                playerStateSubject: playerStateSubject,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                playerHolder: holder,
                appStorage: r.resolve(CoreStorage.self)!,
                analytics: r.resolve(CourseAnalytics.self)!
            )
        }
        
        container.register(PlayerDelegateProtocol.self) { _, manager in
            PlayerDelegate(pipManager: manager)
        }
        
        container.register(YoutubePlayerTracker.self) { (_, url) in
            YoutubePlayerTracker(url: url)
        }
        
        container.register(PlayerTracker.self) { (_, url) in
            PlayerTracker(url: url)
        }
        
        container.register(
            YoutubePlayerViewControllerHolder.self
        ) { r, url, blockID, courseID, selectedCourseTab in
            YoutubePlayerViewControllerHolder(
                url: url,
                blockID: blockID,
                courseID: courseID,
                selectedCourseTab: selectedCourseTab,
                pipManager: r.resolve(PipManagerProtocol.self)!,
                playerTracker: r.resolve(YoutubePlayerTracker.self, argument: url)!,
                playerDelegate: nil,
                playerService: r.resolve(PlayerServiceProtocol.self, arguments: courseID, blockID)!,
                appStorage: nil
            )
        }

        container.register(
            PlayerViewControllerHolder.self
        ) { (r, url: URL?, blockID: String, courseID: String, selectedCourseTab: Int) in
            let pipManager = r.resolve(PipManagerProtocol.self)!
            if let holder = pipManager.holder(
                for: url,
                blockID: blockID,
                courseID: courseID,
                selectedCourseTab: selectedCourseTab
            ) as? PlayerViewControllerHolder {
                return holder
            }

            let tracker = r.resolve(PlayerTracker.self, argument: url)!
            let delegate = r.resolve(PlayerDelegateProtocol.self, argument: pipManager)!
            let holder = PlayerViewControllerHolder(
                url: url,
                blockID: blockID,
                courseID: courseID,
                selectedCourseTab: selectedCourseTab,
                pipManager: pipManager,
                playerTracker: tracker,
                playerDelegate: delegate,
                playerService: r.resolve(PlayerServiceProtocol.self, arguments: courseID, blockID)!,
                appStorage: r.resolve(CoreStorage.self)!
            )
            delegate.playerHolder = holder
            return holder
        }
        
        container.register(PlayerServiceProtocol.self) { r, courseID, blockID in
            let interactor = r.resolve(CourseInteractorProtocol.self)!
            let router = r.resolve(CourseRouter.self)!
            return PlayerService(courseID: courseID, blockID: blockID, interactor: interactor, router: router)
        }
        
        container.register(HandoutsViewModel.self) { r, courseID in
            HandoutsViewModel(
                interactor: r.resolve(CourseInteractorProtocol.self)!,
                router: r.resolve(CourseRouter.self)!,
                cssInjector: r.resolve(CSSInjector.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                courseID: courseID,
                analytics: r.resolve(CourseAnalytics.self)!
            )
        }
        
        container.register(CourseDatesViewModel.self) { r, courseID, courseName in
            CourseDatesViewModel(
                interactor: r.resolve(CourseInteractorProtocol.self)!,
                router: r.resolve(CourseRouter.self)!,
                cssInjector: r.resolve(CSSInjector.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                courseID: courseID,
                courseName: courseName,
                analytics: r.resolve(CourseAnalytics.self)!
            )
        }
        
        // MARK: Discussion
        container.register(DiscussionRepositoryProtocol.self) { r in
            DiscussionRepository(
                api: r.resolve(API.self)!,
                appStorage: r.resolve(CoreStorage.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                router: r.resolve(DiscussionRouter.self)!
            )
        }
        
        container.register(DiscussionInteractorProtocol.self) { r in
            DiscussionInteractor(
                repository: r.resolve(DiscussionRepositoryProtocol.self)!,
                captchaService: r.resolve(CaptchaService.self)!
            )
        }
        
        container.register(DiscussionTopicsViewModel.self) { r, title in
            DiscussionTopicsViewModel(
                title: title,
                interactor: r.resolve(DiscussionInteractorProtocol.self)!,
                router: r.resolve(DiscussionRouter.self)!,
                analytics: r.resolve(DiscussionAnalytics.self)!,
                config: r.resolve(ConfigProtocol.self)!
            )
        }
        
        container.register(DiscussionSearchTopicsViewModel.self) { r, courseID in
            DiscussionSearchTopicsViewModel(
                courseID: courseID,
                interactor: r.resolve(DiscussionInteractorProtocol.self)!,
                router: r.resolve(DiscussionRouter.self)!,
                debounce: .searchDebounce
            )
        }
        
        container.register(PostsViewModel.self) { r in
            PostsViewModel(
                interactor: r.resolve(DiscussionInteractorProtocol.self)!,
                router: r.resolve(DiscussionRouter.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                analytics: r.resolve(DiscussionAnalytics.self)!
            )
        }
        
        container.register(ThreadViewModel.self) { r, subject, responseID in
            ThreadViewModel(
                interactor: r.resolve(DiscussionInteractorProtocol.self)!,
                router: r.resolve(DiscussionRouter.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                coreStorage: r.resolve(CoreStorage.self)!,
                postStateSubject: subject,
                responseID: responseID,
                analytics: r.resolve(DiscussionAnalytics.self)!
            )
        }
        
        container.register(ResponsesViewModel.self) { r, subject, courseID in
            ResponsesViewModel(
                courseID: courseID,
                interactor: r.resolve(DiscussionInteractorProtocol.self)!,
                router: r.resolve(DiscussionRouter.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                coreStorage: r.resolve(CoreStorage.self)!,
                threadStateSubject: subject,
                analytics: r.resolve(DiscussionAnalytics.self)!
            )
        }
        
        container.register(CreateNewThreadViewModel.self) { r in
            CreateNewThreadViewModel(
                interactor: r.resolve(DiscussionInteractorProtocol.self)!,
                router: r.resolve(DiscussionRouter.self)!,
                config: r.resolve(ConfigProtocol.self)!,
                analytics: r.resolve(DiscussionAnalytics.self)!,
                storage: r.resolve(CoreStorage.self)!
            )
        }
        
        container.register(BackNavigationProtocol.self) { r in
            r.resolve(Router.self)!
        }
        
        container.register(StoreKitHandlerProtocol.self) { _ in
            StorekitHandler()
        }.inObjectScope(.container)
        
        container.register(CourseUpgradeRepositoryProtocol.self) { r in
            CourseUpgradeRepository(
                api: r.resolve(API.self)!,
                config: r.resolve(ConfigProtocol.self)!
            )
        }
        
        container.register(CourseUpgradeInteractorProtocol.self) { r in
            CourseUpgradeInteractor(
                repository: r.resolve(CourseUpgradeRepositoryProtocol.self)!
            )
        }
        
        container.register(CourseUpgradeHandlerProtocol.self) { r in
            CourseUpgradeHandler(
                config: r.resolve(ConfigProtocol.self)!,
                interactor: r.resolve(CourseUpgradeInteractorProtocol.self)!,
                enrollmentInteractor: r.resolve(EnrollmentInteractorProtocol.self)!,
                storeKitHandler: r.resolve(StoreKitHandlerProtocol.self)!,
                helper: r.resolve(CourseUpgradeHelperProtocol.self)!
            )
        }.inObjectScope(.container)
        
        container.register(CourseUpgradeHelperProtocol.self) { r in
            CourseUpgradeHelper(
                config: r.resolve(ConfigProtocol.self)!,
                analytics: r.resolve(CoreAnalytics.self)!,
                router: r.resolve(CourseRouter.self)!,
                storage: r.resolve(CoreStorage.self)!
            )
        }.inObjectScope(.container)

        container.register(
            TrackSelectionViewModel.self
        ) { r, courseID, productName, sku, pacing, lmsPrice, accessExpires in
            TrackSelectionViewModel(
                courseID: courseID,
                productName: productName,
                sku: sku,
                pacing: pacing,
                lmsPrice: lmsPrice,
                accessExpires: accessExpires,
                handler: r.resolve(CourseUpgradeHandlerProtocol.self)!,
                analytics: r.resolve(CoreAnalytics.self)!,
                certificatePreviewExperimentManager: r.resolve(CertificatePreviewManaging.self)!,
                router: r.resolve(CourseRouter.self)!
            )
        }

        // MARK: Upgrade info
        container.register(
            UpgradeInfoViewModel.self
        ) { r, productName, message, sku, courseID, screen, pacing, lmsPrice in
            UpgradeInfoViewModel(
                productName: productName,
                message: message,
                sku: sku,
                courseID: courseID,
                screen: screen,
                handler: r.resolve(CourseUpgradeHandlerProtocol.self)!,
                pacing: pacing,
                analytics: r.resolve(CoreAnalytics.self)!,
                certificatePreviewExperimentManager: r.resolve(CertificatePreviewManaging.self)!,
                router: r.resolve(CourseRouter.self)!,
                lmsPrice: lmsPrice
            )
        }
        
        // MARK: Notifications
        container.register(NotificationsInboxViewModel.self) { r in
            NotificationsInboxViewModel(
                notificationsInteractor: r.resolve(NotificationsInteractorProtocol.self)!,
                analytics: r.resolve(NotificationsAnalytics.self)!,
                router: r.resolve(NotificationsRouter.self)!,
                connectivity: r.resolve(ConnectivityProtocol.self)!,
                deepLinkManager: r.resolve(NotificationsDeepLinkManager.self)!
            )
        }
        
        container.register(NotificationsDeepLinkManager.self) { r in
            r.resolve(DeepLinkManager.self)!
        }
    }
}
// swiftlint:enable function_body_length type_body_length
