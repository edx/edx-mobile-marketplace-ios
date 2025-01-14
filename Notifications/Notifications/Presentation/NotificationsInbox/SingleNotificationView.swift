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
    private var viewModel: NotificationsInboxViewModel
    private var notification: Notification
    
    public init(viewModel: NotificationsInboxViewModel, notification: Notification) {
        self.viewModel = viewModel
        self.notification = notification
    }
    
    var body: some View {
        HStack {
            VStack {
                NotificationsAssets.discussions.swiftUIImage
                    .foregroundColor(Theme.Colors.textPrimary)
                    .accessibilityIdentifier("discussions_icon")
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 5)
            
            VStack(alignment: .leading) {
                HStack {
                    AttributedText(notification.contentWithQuotes)
                    Spacer()
                    if notification.lastRead == nil {
                        Circle()
                            .fill(Theme.Colors.accentButtonColor)
                            .frame(width: 8, height: 8)
                            .shadow(radius: 5)
                    }
                }
                Spacer()
                Text(viewModel.relativeTimeDisplay(date: notification.created))
                    .font(Theme.Fonts.labelMedium)
                    .foregroundColor(Theme.Colors.textSecondaryLight)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

#Preview {
    SingleNotificationView(
        viewModel: NotificationsInboxViewModel(
            interactor: NotificationsInteractor.mock,
            analytics: NotificationsAnalyticsMock(),
            router: NotificationsRouterMock()
        ),
        notification: Notification(
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
            lastRead: Date(iso8601: "2025-01-06T01:20:58.919612Z"),
            lastSeen: Date(iso8601: "2025-01-06T01:20:58.919612Z"),
            created: Date(iso8601: "2025-01-06T01:20:58.919612Z")
        )
    )
}
