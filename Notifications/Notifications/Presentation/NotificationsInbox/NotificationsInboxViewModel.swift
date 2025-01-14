//
//  NotificationsInboxViewModel.swift
//  Notifications
//
//  Created by Shafqat Muneer on 12/23/24.
//

import Foundation
import Core
import SwiftUI

public class NotificationsInboxViewModel: ObservableObject {
    
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
    private var interactor: NotificationsInteractorProtocol
    private var analytics: NotificationsAnalytics
    private var nextPage = 1
    private var totalPages = 1
    
    public init(
        interactor: NotificationsInteractorProtocol,
        analytics: NotificationsAnalytics,
        router: NotificationsRouter
    ) {
        self.interactor = interactor
        self.analytics = analytics
        self.router = router
    }
    
    @MainActor
    func getNotifications(page: Int, refresh: Bool = false) async {
        self.refresh = refresh
        isShowProgress = true
        
        do {
            if refresh || page == 1 {
                resetNotifications()
            }
            
            let notificationsData = try await interactor.getAllNotifications(page: page)
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
