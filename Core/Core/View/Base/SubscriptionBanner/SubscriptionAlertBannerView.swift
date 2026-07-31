//
//  SubscriptionAlertBannerView.swift
//  Core
//
//  Created by Sumanta Roy on 27/07/26.

import SwiftUI
import Theme

public struct SubscriptionAlertBannerView: View {

    // Edit these to tune padding/animation per device runs.
    private enum Constants {
        static let portraitTopPadding: CGFloat = 20
        static let portraitHorizontalPadding: CGFloat = 20
        static let landscapeTopPadding: CGFloat = 20
        static let landscapeHorizontalPadding: CGFloat = 50

        static let contentPadding: CGFloat = 24
        static let cornerRadius: CGFloat = 6
        static let borderWidth: CGFloat = 0.5
        static let shadowRadius: CGFloat = 2
        static let shadowYOffset: CGFloat = 1

        static let backgroundColor = Theme.Colors.subscriptionBannerBG
        static let borderColor = Color(red: 0.75, green: 0.86, blue: 0.92)

        static let entryAnimationResponse: Double = 0.5
        static let entryAnimationDampingFraction: Double = 0.6
        static let entryAnimationInitialScale: CGFloat = 0.85
    }

    @StateObject private var viewModel: SubscriptionAlertBannerViewModel
    private let onLinkTap: (URL) -> Void

    @Environment(\.isHorizontal) private var isHorizontal

    public init(
        viewModel: SubscriptionAlertBannerViewModel,
        onLinkTap: @escaping (URL) -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: { viewModel }())
        self.onLinkTap = onLinkTap
    }

    private var useWideLayout: Bool {
        UIDevice.current.userInterfaceIdiom == .pad || isHorizontal
    }

    private var plainMessage: String {
        CoreLocalization.SubscriptionBanner.message("").replacingOccurrences(
            of: #"\[([^\]]+)\]\([^)]*\)"#,
            with: "$1",
            options: .regularExpression
        )
    }

    private var messageText: Text {
        guard let link = viewModel.link else {
            return Text(plainMessage)
        }
        let markdown = CoreLocalization.SubscriptionBanner.message(link.absoluteString)
        guard var attributed = try? AttributedString(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) else {
            return Text(plainMessage)
        }
        attributed.foregroundColor = Theme.Colors.subscriptionBannerText
        for run in attributed.runs where run.link != nil {
            attributed[run.range].foregroundColor = Theme.Colors.infoColor
            attributed[run.range].underlineStyle = .single
        }
        return Text(attributed)
    }

    public var body: some View {
        Group {
            if viewModel.isVisible {
                banner
                    .transition(
                        .scale(scale: Constants.entryAnimationInitialScale).combined(with: .opacity)
                    )
            }
        }
        .padding(.top, useWideLayout ? Constants.landscapeTopPadding : Constants.portraitTopPadding)
        .padding(
            .horizontal,
            useWideLayout ? Constants.landscapeHorizontalPadding : Constants.portraitHorizontalPadding
        )
        .animation(
            .spring(
                response: Constants.entryAnimationResponse,
                dampingFraction: Constants.entryAnimationDampingFraction
            ),
            value: viewModel.isVisible
        )
        .onAppear {
            viewModel.evaluateVisibility()
        }
    }

    @ViewBuilder
    private var banner: some View {
        if useWideLayout {
            HStack(alignment: .top, spacing: 24) {
                textBlock
                dismissButton
            }
            .padding(Constants.contentPadding)
            .background(bannerBackground)
        } else {
            VStack(alignment: .trailing, spacing: 16) {
                textBlock
                dismissButton
            }
            .padding(Constants.contentPadding)
            .background(bannerBackground)
        }
    }

    private var textBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(CoreLocalization.SubscriptionBanner.title)
                .font(Theme.Fonts.titleMedium)
                .foregroundColor(Theme.Colors.subscriptionBannerText)
                .accessibilityIdentifier("subscription_banner_title")
            messageText
                .font(Theme.Fonts.bodyMedium)
                .accessibilityIdentifier("subscription_banner_message")
                .environment(\.openURL, OpenURLAction { url in
                    onLinkTap(url)
                    return .handled
                })
        }
    }

    private var dismissButton: some View {
        Button(action: {
            viewModel.dismiss()
        }) {
            Text(CoreLocalization.SubscriptionBanner.dismiss)
                .font(Theme.Fonts.labelLarge)
                .foregroundColor(Theme.Colors.subscriptionBannerText)
        }
        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        .accessibilityIdentifier("subscription_banner_dismiss_button")
    }

    private var bannerBackground: some View {
        RoundedRectangle(cornerRadius: Constants.cornerRadius)
            .fill(Constants.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .inset(by: Constants.borderWidth / 2)
                    .stroke(Constants.borderColor, lineWidth: Constants.borderWidth)
            )
            .shadow(color: Color.black.opacity(0.15), radius: Constants.shadowRadius, y: Constants.shadowYOffset)
    }
}

#if DEBUG
struct SubscriptionAlertBannerView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionAlertBannerView(
            viewModel: SubscriptionAlertBannerViewModel(
                screen: .discovery,
                storage: SubscriptionBannerStorageMock(),
                sessionTracker: AppSessionTrackerMock(),
                serverConfig: ServerConfigProtocolMock()
            ),
            onLinkTap: { _ in }
        )
        .loadFonts()
    }
}
#endif
