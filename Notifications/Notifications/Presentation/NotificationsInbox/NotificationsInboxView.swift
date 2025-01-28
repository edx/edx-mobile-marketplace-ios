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
        GeometryReader { proxy in
            VStack(alignment: .center) {
                ZStack {
                    HStack {
                        Spacer()
                        Menu {
                            ForEach(viewModel.menus, id: \.self) { menu in
                                Button(menu.localizedValue) {
                                    viewModel.menuSelected(menu)
                                }
                            }
                        } label: {
                            NotificationsAssets.threeDotsMenu.swiftUIImage
                                .padding(.top, 3)
                                .padding(.bottom, 17)
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
                        .offset(y: 5)
                        .padding(.leading, isHorizontal ? 48 : 10)
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
                                        .padding(.bottom, 5)
                                        .padding(.horizontal, 24)
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
                            if viewModel.isShowProgress {
                                HStack(alignment: .center) {
                                    ProgressBar(size: 40, lineWidth: 8)
                                        .accessibilityIdentifier("progressbar")
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .frameLimit(width: proxy.size.width)
                    }
                    .padding(.horizontal, isHorizontal ? 48 : 0)
                } else {
                    // Handle empty or error screens
                    Text("No Notifications Available")
                }
            }
            .onFirstAppear {
                Task {
                    await viewModel.getNotifications(page: 1)
                    await viewModel.markNotificationsAsSeen()
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
