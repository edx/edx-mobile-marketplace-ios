//
//  SingleNotificationView.swift
//  Notifications
//
//  Created by Shafqat Muneer on 1/14/25.
//

import SwiftUI
import Theme
import Core

struct SingleNotificationView: View {
    @ObservedObject
    private var viewModel: NotificationsInboxViewModel
    private var notification: SingleNotification
    private var groupKey: NotificationGroup
    
    public init(viewModel: NotificationsInboxViewModel, groupKey: NotificationGroup, notification: SingleNotification) {
        self.viewModel = viewModel
        self.notification = notification
        self.groupKey = groupKey
    }
    
    var body: some View {
        Button(
            action: {
                viewModel.trackInboxItemClicked(notification: notification)

                Task {
                    await viewModel.showDiscussions(notification)
                    await viewModel.markNotificationAsRead(notificationId: String(notification.id))
                    var updatedNotification = notification
                    updatedNotification.lastRead = Date()
                    viewModel.updateNotification(
                        groupKey: groupKey,
                        item: updatedNotification
                    )
                }
            }
        ) {
            HStack {
                VStack {
                    NotificationsAssets.discussions.swiftUIImage
                        .foregroundColor(Theme.Colors.accentColor)
                        .accessibilityIdentifier("discussions_icon")
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 2)
                
                VStack(alignment: .leading) {
                    HStack {
                        AttributedText(notification.contentWithQuotes)
                            .font(Theme.Fonts.bodyMedium)
                            .foregroundColor(Theme.Colors.accentColor)
                        Spacer()
                        if notification.lastRead == nil {
                            Circle()
                                .fill(Theme.Colors.accentButtonColor)
                                .frame(width: 8, height: 8)
                        }
                    }
                    Spacer()
                    Text(viewModel.relativeTimeDisplay(date: notification.created))
                        .font(Theme.Fonts.bodySmall)
                        .foregroundColor(Theme.Colors.textSecondaryLight)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#if DEBUG
#Preview {
    SingleNotificationView(
        viewModel: NotificationsInboxViewModel(
            notificationsInteractor: NotificationsInteractor.mock,
            analytics: NotificationsAnalyticsMock(),
            router: NotificationsRouterMock(),
            connectivity: Connectivity(),
            deepLinkManager: NotificationsDeepLinkManagerMock()
        ),
        groupKey: NotificationGroup.recent,
        notification: SingleNotification(
            id: 123,
            appName: "discussion",
            notificationType: "comment_on_followed_post",
            contentContext: ContentContext(
                topicId: "i4x-edX-demoX1-course-2T2017",
                parentId: "6777c03a7febe504707971ab",
                threadId: "5d49c25584452a0795000386",
                commentId: "677b2ffa7febe50470799585",
                postTitle: "How to learn it online?"
            ),
            content: "Test notification",
            courseId: "course-v1:edX+Test+2T2009",
            lastRead: Date(iso8601: "2025-01-06T01:20:58.919612Z"),
            lastSeen: Date(iso8601: "2025-01-06T01:20:58.919612Z"),
            created: Date(iso8601: "2025-01-06T01:20:58.919612Z")
        )
    )
}
#endif
