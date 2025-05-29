//
//  AppearanceSettingsView.swift
//  Profile
//
//  Created by Muhammad Tayyab Akram on 5/23/25.
//

import SwiftUI
import Core
import Theme

public struct AppearanceSettingsView: View {
    @ObservedObject
    private var viewModel: AppearanceSettingsViewModel

    public init(viewModel: AppearanceSettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                VStack {
                    topBar
                    content(geometry: proxy)
                }
            }
            .hideNavigationBar(true)
            .navigationBarBackButtonHidden(true)
            .navigationTitle(ProfileLocalization.Settings.appearanceSettingsTitle)
        }
        .background(
            Theme.Colors.background
                .ignoresSafeArea()
        )
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

            Text(ProfileLocalization.Settings.appearanceSettingsTitle)
                .titleSettings(
                    top: 0,
                    bottom: 0,
                    color: Theme.Colors.textPrimary
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityIdentifier("appearance_text")
                .padding(.trailing, 32 + sideInset)
        }
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func content(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(AppearanceMenu.allCases, id: \.self) { menu in
                    Button(action: {
                        viewModel.menuSelected(menu)
                    }, label: {
                        HStack {
                            SettingsCell(
                                title: menu.title,
                                description: menu.description
                            )
                            Spacer()
                            CoreAssets.checkmark.swiftUIImage
                                .renderingMode(.template)
                                .foregroundColor(Theme.Colors.accentXColor)
                                .opacity(viewModel.selectedMenu == menu ? 1 : 0)
                        }.foregroundColor(Theme.Colors.textPrimary)
                    })
                    .accessibilityIdentifier("select_appearance_button")

                    Divider()
                }
            }
            .frameLimit(width: geometry.size.width)
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
    }
}

#if DEBUG
#Preview {
    AppearanceSettingsView(
        viewModel: AppearanceSettingsViewModel(
            themeManager: ThemeManagerMock(),
            router: ProfileRouterMock(),
            analytics: ProfileAnalyticsMock()
        )
    )
}
#endif
