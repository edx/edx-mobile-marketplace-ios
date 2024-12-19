//
//  NotificationsSettingsView.swift
//  Notifications
//
//  Created by Saeed Bashir on 12/11/24.
//

import SwiftUI
import Theme
import Core

public struct NotificationsSettingsView: View {
    @ObservedObject
    private var viewModel: NotificationsSettingsViewModel
    @Environment(\.isHorizontal) private var isHorizontal
    
    public init(viewModel: NotificationsSettingsViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                VStack {
                    ThemeAssets.headerBackground.swiftUIImage
                        .resizable()
                        .edgesIgnoringSafeArea(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: 200)
                .accessibilityIdentifier("header_bg_image")
                    
                VStack(alignment: .center) {
                    ZStack {
                        HStack {
                            Text(NotificationsLocalization.Settings.title)
                                .titleSettings(color: Theme.Colors.loginNavigationText)
                                .accessibilityIdentifier("manage_account_text")
                        }
                        VStack {
                            BackNavigationButton(
                                color: Theme.Colors.loginNavigationText,
                                action: {
                                    viewModel.router.back()
                                }
                            )
                            .backViewStyle()
                            .padding(.leading, isHorizontal ? 48 : 0)
                            .accessibilityIdentifier("back_button")
                            
                        }.frame(minWidth: 0,
                                maxWidth: .infinity,
                                alignment: .topLeading)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(NotificationsLocalization.Settings.preferenceTitle)
                                .font(Theme.Fonts.titleMedium)
                                .foregroundStyle(Theme.Colors.textPrimary)
                                .accessibilityIdentifier("preference_title_text")
                            
                            Spacer()
                            Toggle(isOn: $viewModel.hasPermission, label: {})
                                .toggleStyle(SwitchToggleStyle(tint: Theme.Colors.toggleSwitchColor))
                                .frame(width: 50)
                                .accessibilityIdentifier("discussion_switch")
                                .onTapGesture {
                                    viewModel.toggleNotificationsPermissionAction()
                                }
                            
                        }
                        
                        Text(NotificationsLocalization.Settings.preferenceDescription)
                            .font(Theme.Fonts.bodyMedium)
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .accessibilityIdentifier("preference_description_text")
                        
                        Divider()
                            .padding(20)
                            .accessibilityIdentifier("preference_divider")
                        
                        Spacer()
                    }
                    .padding(20)
                    .roundedBackground(Theme.Colors.background)
                }
                .frameLimit(width: proxy.size.width)
                
                if viewModel.showError {
                    VStack {
                        Spacer()
                        SnackBarView(message: viewModel.errorMessage)
                            .accessibilityIdentifier("preference_snack_bar")
                    }
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        doAfter(Theme.Timeout.snackbarMessageLongTimeout) {
                            viewModel.errorMessage = nil
                        }
                    }
                }
            }
            .hideNavigationBar(true)
            .navigationBarBackButtonHidden(true)
            .navigationTitle(NotificationsLocalization.Settings.title)
        }
        .background(
            Theme.Colors.background
                .ignoresSafeArea()
        )
        .ignoresSafeArea(.all, edges: .horizontal)
        .animation(.default, value: viewModel.showError)
    }
}

#if DEBUG
struct NotificationsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsSettingsView(
            viewModel: NotificationsSettingsViewModel(
                interactor: NotificationsInteractor.mock,
                analytics: NotificationsAnalyticsMock(),
                router: NotificationsRouterMock()
            )
        )
    }
}
#endif
