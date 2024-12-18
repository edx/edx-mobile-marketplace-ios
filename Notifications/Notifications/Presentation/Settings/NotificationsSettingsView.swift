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
    
    public init(viewModel: NotificationsSettingsViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(NotificationsLocalization.Settings.preferenceTitle)
                            .font(Theme.Fonts.titleMedium)
                            .foregroundStyle(Theme.Colors.textPrimary)
                        
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
                    
                    Divider()
                        .padding(20)
                }
                .frameLimit(width: proxy.size.width)
                .padding(20)
                
                if viewModel.showError {
                    VStack {
                        Spacer()
                        SnackBarView(message: viewModel.errorMessage)
                    }
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        doAfter(Theme.Timeout.snackbarMessageLongTimeout) {
                            viewModel.errorMessage = nil
                        }
                    }
                }
            }
            .hideNavigationBar(false)
            .navigationBarBackButtonHidden(false)
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
                analytics: NotificationsAnalyticsMock()
            )
        )
    }
}
#endif
