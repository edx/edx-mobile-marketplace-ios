//
//  NotificationsInboxViewModel.swift
//  Notifications
//
//  Created by Shafqat Muneer on 12/23/24.
//

import Foundation
import Core
import SwiftUI
import Discovery
import Discussion

public class NotificationsInboxViewModel: ObservableObject {
    @Published private(set) var menus: [NotificationMenu] = NotificationMenu.allCases
    @Published private(set) var fetchInProgress = false
    @Published private(set) var refresh = false
    @Published var isShowProgress = true
    @Published var showError: Bool = false
    @Published var groupedNotifications: [NotificationGroup: [Notification]] = [:]
    @Published var flatNotifications: [Notification] = [] {
        didSet { groupItems() }
    }
    
    var router: NotificationsRouter
    var errorMessage: String? {
        didSet {
            showError = errorMessage != nil
        }
    }
    
    private let calendar = Calendar.current
    private var notificationsInteractor: NotificationsInteractorProtocol
    private var discoveryInteractor: DiscoveryInteractorProtocol
    private var discussionInteractor: DiscussionInteractorProtocol
    private var analytics: NotificationsAnalytics
    private var nextPage = 1
    private var totalPages = 1
    
    public init(
        notificationsInteractor: NotificationsInteractorProtocol,
        discoveryInteractor: DiscoveryInteractorProtocol,
        discussionInteractor: DiscussionInteractorProtocol,
        analytics: NotificationsAnalytics,
        router: NotificationsRouter
    ) {
        self.notificationsInteractor = notificationsInteractor
        self.discoveryInteractor = discoveryInteractor
        self.discussionInteractor = discussionInteractor
        self.analytics = analytics
        self.router = router
    }
    
    func menuSelected(_ menu: NotificationMenu) {
        switch menu {
        case .markAllAsRead:
            Task {
                await markAllNotificationsAsRead()
            }
        case .settings:
            router.showPushSettings()
        }
    }
    
    @MainActor
    func markNotificationAsRead(notificationId: String) async {
        do {
            _ = try await notificationsInteractor.markNotificationAsRead(notificationId: notificationId)
        } catch {
            handleFetchError(error)
        }
    }
    
    @MainActor
    func markAllNotificationsAsRead() async {
        do {
            _ = try await notificationsInteractor.markAllNotificationsAsRead()
            
            flatNotifications = flatNotifications.map { item in
                var readItem = item
                readItem.lastRead = Date()
                return readItem
            }
        } catch {
            handleFetchError(error)
        }
    }
    
    @MainActor
    func markNotificationsAsSeen() async {
        do {
            _ = try await notificationsInteractor.markNotificationsAsSeen()
        } catch {
            handleFetchError(error)
        }
    }
    
    @MainActor
    func getNotifications(page: Int, refresh: Bool = false) async {
        self.refresh = refresh
        isShowProgress = true
        
        do {
            if refresh || page == 1 {
                resetNotifications()
            }
            
            let notificationsData = try await notificationsInteractor.getAllNotifications(page: page)
            updateNotifications(with: notificationsData)
            
            self.nextPage += 1
        } catch {
            handleFetchError(error)
        }
        
        isShowProgress = false
        self.refresh = false
    }

    private func resetNotifications() {
        flatNotifications = []
        nextPage = 1
    }

    private func updateNotifications(with data: Notifications) {
        self.totalPages = data.numPages ?? 1
        flatNotifications += data.results ?? []
        groupItems()
    }
    
    private func handleFetchError(_ error: Error) {
        // We will handle errors in separte PR and will remove this comment
        errorMessage = CoreLocalization.Error.unknownError
    }
    
    public func isFirstPage() -> Bool {
        return nextPage == 1
    }
    
    public func relativeTimeDisplay(date: Date) -> String {
        var dateString = date.timeAgoDisplay()
        if dateString.hasSuffix(" ago") {
            dateString.removeLast(4)
        }
        return dateString
    }
    
    @MainActor
    public func getNotificationsPagination(index: Int) async {
        if !fetchInProgress {
            if totalPages > 1 {
                if index == flatNotifications.count - 3 {
                    if totalPages != 1 {
                        if nextPage <= totalPages {
                            await getNotifications(page: self.nextPage)
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    public func showDiscussions(_ notification: Notification) async {
        router.showProgress()
        do {
            guard
                let courseId = notification.courseId, !courseId.isEmpty,
                let topicId = notification.contentContext?.topicId, !topicId.isEmpty
            else {
                router.dismissProgress()
                return
            }

            let courseDetails = try await discoveryInteractor.getCourseDetails(
                courseID: courseId
            )
            let discussionInfo = try await discussionInteractor.getCourseDiscussionInfo(
                courseID: courseDetails.courseID
            )
            let topics = try await discussionInteractor.getTopic(
                courseID: courseDetails.courseID,
                topicID: topicId
            )

            router.showThreads(
                topicID: topicId,
                courseDetails: courseDetails,
                topics: topics,
                isBlackedOut: discussionInfo.isBlackedOut()
            )

            let responseId = notification.contentContext?.parentId?.isEmpty == false &&
                             notification.contentContext?.commentId?.isEmpty == false
                             ? notification.contentContext?.parentId
                             : notification.contentContext?.commentId

            if let threadId = notification.contentContext?.threadId, !threadId.isEmpty {
                let userThread = try await discussionInteractor.getThread(threadID: threadId)
                router.showThread(
                    userThread: userThread,
                    isBlackedOut: discussionInfo.isBlackedOut(),
                    responseID: responseId
                )
            }

            if let parentId = notification.contentContext?.parentId, !parentId.isEmpty {
                let comment = try await discussionInteractor.getResponse(responseID: parentId)
                router.showComment(
                    courseID: courseDetails.courseID,
                    comment: comment,
                    parentComment: comment.post,
                    isBlackedOut: discussionInfo.isBlackedOut()
                )
            }
        } catch {
            debugLog(error.localizedDescription)
        }
        router.dismissProgress()
    }
    
    func trackNotificationInbox() {
        analytics.notificationInbox()
    }
    
    func trackNotificationTapped(notificationType: String) {
        analytics.notificationTapped(
            notificationType: notificationType
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
    func updateNotification(groupKey: NotificationGroup, item: Notification) {
        updateGroupedNotification(groupKey: groupKey, item: item)
        updateFlatNotification(item: item)
    }

    private func updateGroupedNotification(groupKey: NotificationGroup, item: Notification) {
        if let index = groupedNotifications[groupKey]?.firstIndex(where: { $0.id == item.id }) {
            groupedNotifications[groupKey]?[index] = item
        }
    }

    private func updateFlatNotification(item: Notification) {
        if let index = flatNotifications.firstIndex(where: { $0.id == item.id }) {
            flatNotifications[index] = item
        }
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
