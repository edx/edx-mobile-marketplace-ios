//
//  NotificationsInboxView.swift
//  Notifications
//
//  Created by Shafqat Muneer on 12/23/24.
//

import SwiftUI
import Theme
import Core

public struct NotificationsInboxView: View {
    @ObservedObject
    private var viewModel: NotificationsInboxViewModel
    @Environment(\.isHorizontal) private var isHorizontal
    
    public init(viewModel: NotificationsInboxViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GeometryReader { _ in
            VStack(alignment: .center) {
                ZStack {
                    HStack {
                        Spacer()
                        Button {
                            // Open three dots menu
                        } label: {
                            NotificationsAssets.threeDotsMenu.swiftUIImage
                                .padding(.vertical, 10)
                                .padding(.horizontal, isHorizontal ? 48 : 25)
                                .foregroundColor(Theme.Colors.textPrimary)
                                .accessibilityIdentifier("three_dots_menu")
                        }
                    }
                    
                    Text(NotificationsLocalization.notifications)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .titleSettings(color: Theme.Colors.textPrimary)
                        .accessibilityIdentifier("notifications_text")
                    
                    HStack {
                        BackNavigationButton(
                            color: Theme.Colors.textPrimary,
                            action: {
                                viewModel.router.back()
                            }
                        )
                        .backViewStyle()
                        .frame(width: 30, height: 30)
                        .offset(y: 10)
                        
                        .padding(.leading, isHorizontal ? 48 : 10)
                        .accessibilityIdentifier("back_button")
                        
                        Spacer()
                    }
                }
                
                if viewModel.isShowProgress && viewModel.isFirstPage() {
                    HStack(alignment: .center) {
                        ProgressBar(size: 40, lineWidth: 8)
                            .accessibilityIdentifier("progressbar")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.flatNotifications.count > 0 {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(
                                NotificationGroup.allCases,
                                id: \.self
                            ) { group in
                                if let items = viewModel.groupedNotifications[group], !items.isEmpty {
                                    Section(
                                        header:
                                            Text(group.rawValue)
                                            .font(Theme.Fonts.labelLarge)
                                            .foregroundColor(Theme.Colors.textSecondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.bottom, 5)
                                            .padding(.horizontal, 20)
                                    ) {
                                        ForEach(
                                            items.indices,
                                            id: \.self
                                        ) { index in
                                            let item = items[index]
                                            SingleNotificationView(
                                                viewModel: viewModel,
                                                notification: item
                                            )
                                            .accessibilityIdentifier("sigle_notification_view_\(index)")
                                            .frame(maxWidth: .infinity)
                                            .onAppear {
                                                let globalIndex = viewModel.flatNotifications.firstIndex(of: item) ?? -1
                                                Task {
                                                    await viewModel.getNotificationsPagination(index: globalIndex)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            if viewModel.isShowProgress {
                                HStack(alignment: .center) {
                                    ProgressBar(size: 40, lineWidth: 8)
                                        .accessibilityIdentifier("progressbar")
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal, isHorizontal ? 48 : 0)
                } else {
                    // Handle empty or error screens
                }
            }
            .onFirstAppear {
                Task {
                    await viewModel.getNotifications(page: 1)
                }
            }
            .hideNavigationBar(true)
            .navigationBarBackButtonHidden(true)
            .navigationTitle(NotificationsLocalization.notifications)
        }
        .background(
            Theme.Colors.background
                .ignoresSafeArea()
        )
        .ignoresSafeArea(.all, edges: .horizontal)
    }
}

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

#if DEBUG
#Preview {
    NotificationsInboxView(
        viewModel: NotificationsInboxViewModel(
            interactor: NotificationsInteractor.mock,
            analytics: NotificationsAnalyticsMock(),
            router: NotificationsRouterMock()
        )
    )
}
#endif
