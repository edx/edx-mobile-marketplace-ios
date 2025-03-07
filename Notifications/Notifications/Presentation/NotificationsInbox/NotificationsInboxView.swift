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
    
    public init(viewModel: NotificationsInboxViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                VStack {
                    topBar
                    content(geometry: proxy)
                }
                
                if viewModel.showError {
                    VStack {
                        Spacer()
                        SnackBarView(message: viewModel.errorMessage)
                            .accessibilityIdentifier("inbox_snack_bar")
                    }
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        doAfter(Theme.Timeout.snackbarMessageLongTimeout) {
                            viewModel.hideError()
                        }
                    }
                }
            }
            .onFirstAppear {
                viewModel.trackNotificationInbox()
                Task {
                    await viewModel.loadNotifications()
                    await viewModel.markNotificationsAsSeen()
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .navigationTitle(NotificationsLocalization.notifications)
        }
        .background(
            Theme.Colors.background
                .ignoresSafeArea()
        )
        .animation(.default, value: viewModel.showError)
    }
    
    @ViewBuilder
    private var topBar: some View {
        HStack {
            let sideInset: CGFloat = 24
            
            BackNavigationButton(
                color: Theme.Colors.textPrimary,
                insets: EdgeInsets(
                    top: 0,
                    leading: sideInset,
                    bottom: 0,
                    trailing: 8
                ),
                action: {
                    viewModel.backButtonPressed()
                }
            )
            .frame(width: 32 + sideInset, height: 40)
            
            Text(NotificationsLocalization.notifications)
                .titleSettings(
                    top: 0,
                    bottom: 0,
                    color: Theme.Colors.textPrimary
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityIdentifier("notifications_text")

            Menu {
                ForEach(viewModel.menus, id: \.self) { menu in
                    Button(menu.localizedValue) {
                        viewModel.menuSelected(menu)
                    }
                }
            } label: {
                NotificationsAssets.threeDotsMenu.swiftUIImage
                    .frame(width: 24, height: 40)
                    .padding(.leading, 8)
                    .padding(.trailing, sideInset)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .accessibilityIdentifier("three_dots_menu")
            }
        }
        .padding(.bottom, 4)
    }
    
    @ViewBuilder
    private func content(geometry: GeometryProxy) -> some View {
        switch viewModel.screenState {
        case .idle:
            EmptyView()
        case .loading:
            HStack(alignment: .center) {
                ProgressBar(size: 40, lineWidth: 8)
                    .accessibilityIdentifier("progressbar")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .populated:
            list(geometry: geometry)
        case .noData:
            ScreenStateView(
                title: NotificationsLocalization.Inbox.Empty.title,
                description: NotificationsLocalization.Inbox.Empty.description,
                image: NotificationsAssets.noNotifications.swiftUIImage
            )
        case .noInternet:
            ScreenStateView(.noInternet,
                button: .reload {
                    Task {
                        await viewModel.loadNotifications()
                    }
                }
            )
        case .serverError:
            ScreenStateView(.serverError,
                button: .reload {
                    Task {
                        await viewModel.loadNotifications()
                    }
                }
            )
        }
    }
    
    @ViewBuilder
    private func list(geometry: GeometryProxy) -> some View {
        RefreshableScrollViewCompat(action: {
            await viewModel.refreshNotifications()
        }) {
            LazyVStack(spacing: 16) {
                ForEach(
                    NotificationGroup.allCases.filter { key in
                        // Include only non-empty arrays
                        !(viewModel.groupedNotifications[key]?.isEmpty ?? true)
                    },
                    id: \.self
                ) { group in
                    Section(
                        header:
                            Text(group.localizedValue)
                                .font(Theme.Fonts.bodyMedium)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                    ) {
                        ForEach(
                            viewModel.groupedNotifications[group]!.indices,
                            id: \.self
                        ) { index in
                            let item = viewModel.groupedNotifications[group]![index]
                            SingleNotificationView(
                                viewModel: viewModel,
                                groupKey: group,
                                notification: item
                            )
                            .accessibilityIdentifier("single_notification_view_\(index)")
                            .frame(maxWidth: .infinity)
                            .onAppear {
                                viewModel.fetchMoreNotificationsIfNeeded(for: item)
                            }
                        }
                    }
                }
                
                if viewModel.isLoadingMore {
                    HStack(alignment: .center) {
                        ProgressBar(size: 40, lineWidth: 8)
                            .accessibilityIdentifier("progressbar")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frameLimit(width: geometry.size.width)
        }
    }
}

#if DEBUG
#Preview {
    NotificationsInboxView(
        viewModel: NotificationsInboxViewModel(
            notificationsInteractor: NotificationsInteractor.mock,
            analytics: NotificationsAnalyticsMock(),
            router: NotificationsRouterMock(),
            connectivity: Connectivity(),
            deepLinkManager: NotificationsDeepLinkManagerMock()
        )
    )
}
#endif
