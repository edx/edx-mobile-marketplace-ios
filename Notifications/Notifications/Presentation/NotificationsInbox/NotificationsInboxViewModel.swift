//
//  NotificationsInboxViewModel.swift
//  Notifications
//
//  Created by Shafqat Muneer on 12/23/24.
//

import Foundation
import Combine
import Core

public class NotificationsInboxViewModel: ObservableObject {
    @Published private(set) var menus: [NotificationMenu] = NotificationMenu.allCases
    @Published private(set) var screenState: ScreenState = .idle
    @Published private(set) var isLoadingMore = false
    @Published private(set) var groupedNotifications: [NotificationGroup: [SingleNotification]] = [:]
    @Published private(set) var showError: Bool = false

    private(set) var errorMessage: String? {
        didSet {
            showError = errorMessage != nil
        }
    }
    
    private let analytics: NotificationsAnalytics
    private let router: NotificationsRouter
    private let connectivity: ConnectivityProtocol
    private let deepLinkManager: NotificationsDeepLinkManager
    private let paginationManager: PaginationManager<SingleNotification, Int>
    private let calendar = Calendar.current
    private var interactor: NotificationsInteractorProtocol
    private var cancellables = Set<AnyCancellable>()
    private(set) var lazyVStackUniqueID: String = UUID().uuidString
    private(set) var flatNotifications: [SingleNotification] = [] {
        didSet { groupItems() }
    }
    
    enum ScreenState {
        case idle
        case loading
        case populated
        case noData
        case noInternet
        case serverError
    }
    
    public init(
        notificationsInteractor: NotificationsInteractorProtocol,
        analytics: NotificationsAnalytics,
        router: NotificationsRouter,
        connectivity: ConnectivityProtocol,
        deepLinkManager: NotificationsDeepLinkManager
    ) {
        self.interactor = notificationsInteractor
        self.analytics = analytics
        self.router = router
        self.connectivity = connectivity
        self.deepLinkManager = deepLinkManager
        self.paginationManager = PaginationManager { pageKey in
            let currentPage = pageKey ?? 1
            let data = try await notificationsInteractor.getAllNotifications(page: currentPage)
            
            let totalPages = data.numPages ?? 1
            let nextPage = currentPage + 1
            
            return PaginationResult(
                items: data.results ?? [],
                nextPageKey: nextPage <= totalPages ? nextPage : nil
            )
        }
        
        setupBindings()
    }
    
    private func setupBindings() {
        paginationManager.isLoadingMorePublisher
            .assign(to: &$isLoadingMore)
        
        paginationManager.itemsPublisher
            .sink { [weak self] items in
                guard let self else { return }
                
                if let items {
                    screenState = items.isEmpty ? .noData : .populated
                    flatNotifications = items
                } else {
                    flatNotifications = []
                }
            }
            .store(in: &cancellables)
        
        paginationManager.errorPublisher
            .sink { [weak self] error in
                self?.handleFetchError(error)
            }
            .store(in: &cancellables)
    }
    
    func backButtonPressed() {
        router.back()
    }
    
    func menuSelected(_ menu: NotificationMenu) {
        switch menu {
        case .markAllAsRead:
            trackMarkAllReadClicked()
            Task {
                await markAllNotificationsAsRead()
            }
        case .settings:
            trackPushNotificationsSettingClicked()
            router.showPushSettings()
        }
    }
    
    func regenerateLazyVStackUniqueID() {
        lazyVStackUniqueID = UUID().uuidString
    }
    
    @MainActor
    func loadNotifications() async {
        screenState = .loading
        paginationManager.reset()
        await refreshNotifications()
    }
    
    @MainActor
    func refreshNotifications() async {
        _ = await paginationManager.refresh().result
    }
    
    @MainActor
    func fetchMoreNotificationsIfNeeded(for item: SingleNotification) {
        guard let index = flatNotifications.firstIndex(of: item) else { return }
        
        if index == flatNotifications.count - 3 {
            paginationManager.loadMore()
        }
    }
    
    @MainActor
    public func markNotificationAsRead(notificationId: String) async {
        do {
            _ = try await interactor.markNotificationAsRead(notificationId: notificationId)
        } catch {
            handleAPIError(error)
        }
    }
    
    @MainActor
    func markAllNotificationsAsRead() async {
        do {
            _ = try await interactor.markAllNotificationsAsRead()
            
            flatNotifications = flatNotifications.map { item in
                var readItem = item
                readItem.lastRead = Date()
                return readItem
            }
        } catch {
            handleAPIError(error)
        }
    }
    
    @MainActor
    func markNotificationsAsSeen() async {
        _ = try? await interactor.markNotificationsAsSeen()
    }
    
    func hideError() {
        errorMessage = nil
    }
    
    private func handleFetchError(_ error: Error) {
        if screenState != .populated {
            screenState = connectivity.isInternetAvaliable ? .serverError : .noInternet
        } else {
            handleAPIError(error)
        }
    }
    
    private func handleAPIError(_ error: Error) {
        if error.isInternetError {
            errorMessage = CoreLocalization.Error.slowOrNoInternetConnection
        } else {
            errorMessage = CoreLocalization.Error.unknownError
        }
    }
    
    public func relativeTimeDisplay(date: Date) -> String {
        var dateString = date.timeAgoDisplay()
        if dateString.hasSuffix(" ago") {
            dateString.removeLast(4)
        }
        return dateString
    }

    public func showDiscussions(_ notification: SingleNotification) async {
        await deepLinkManager.showDiscussions(notification)
    }
    
    func trackScreenEvent() {
        analytics.notificationScreenEvent(.notificationInbox, biValue: .notificationInbox)
    }

    func trackInboxMenuClicked() {
        analytics.notificationInboxMenuClicked()
    }

    func trackMarkAllReadClicked() {
        analytics.notificationMarkAllReadClicked()
    }

    func trackPushNotificationsSettingClicked() {
        analytics.notificationPushNotificationsSettingClicked()
    }

    func trackInboxItemClicked(notification: SingleNotification) {
        analytics.notificationInboxItemClicked(
            NotificationInfo(
                notificationDomain: notification.appName ?? "",
                notificationType: notification.notificationType ?? "",
                notificationID: String(notification.id),
                courseID: notification.courseId,
                topicID: notification.contentContext?.topicId,
                threadID: notification.contentContext?.threadId,
                responseID: notification.contentContext?.responseId,
                commentID: notification.contentContext?.commentId
            )
        )
    }
    
    private func groupItems() {
        let now = Date()
        groupedNotifications = Dictionary(grouping: flatNotifications, by: { item in
            let hoursDifference = calendar.dateComponents([.hour], from: item.created, to: now).hour ?? 0
            let daysDifference = calendar.dateComponents([.day], from: item.created, to: now).day ?? 0
            
            if hoursDifference < 24 {
                return .recent
            } else if daysDifference >= 1 && daysDifference < 7 {
                return .thisWeek
            } else {
                return .older
            }
        })
    }
    
    // Update a specific item in the array
    @MainActor
    func updateNotification(_ updatedNotification: SingleNotification) {
        paginationManager.replaceFirstItemWithMatchingID(updatedNotification)
    }
}

enum NotificationMenu: CaseIterable {
    case markAllAsRead
    case settings
    
    var localizedValue: String {
        switch self {
        case .markAllAsRead:
            return NotificationsLocalization.Menu.markAllAsRead
        case .settings:
            return NotificationsLocalization.Menu.settings
        }
    }
}

public enum NotificationGroup: String, CaseIterable {
    case recent
    case thisWeek
    case older

    var localizedValue: String {
        switch self {
        case .recent:
            return NotificationsLocalization.Inbox.recent
        case .thisWeek:
            return NotificationsLocalization.Inbox.thisWeek
        case .older:
            return NotificationsLocalization.Inbox.older
        }
    }
}
