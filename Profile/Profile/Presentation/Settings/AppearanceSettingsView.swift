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
    @Environment(\.isHorizontal) private var isHorizontal

    public init(viewModel: AppearanceSettingsViewModel) {
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

                VStack(alignment: .center) {
                    ZStack {
                        HStack {
                            Text(ProfileLocalization.Settings.appearanceSettingsTitle)
                                .titleSettings(color: Theme.Colors.loginNavigationText)
                                .accessibilityIdentifier("appearance_text")
                        }
                        VStack {
                            BackNavigationButton(
                                color: Theme.Colors.loginNavigationText,
                                action: {
                                    viewModel.backButtonPressed()
                                }
                            )
                            .backViewStyle()
                            .padding(.leading, isHorizontal ? 48 : 0)
                            .accessibilityIdentifier("back_button")

                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                    }

                    content(geometry: proxy)
                        .roundedBackground(Theme.Colors.background)
                }
            }
        }
        .hideNavigationBar(true)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(ProfileLocalization.Settings.appearanceSettingsTitle)
        .ignoresSafeArea(.all, edges: .horizontal)
        .background(
            Theme.Colors.background
                .ignoresSafeArea()
        )
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
