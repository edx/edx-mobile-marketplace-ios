//
//  NotificationsPrimerView.swift
//  Notifications
//
//  Created by Muhammad Tayyab Akram on 2/13/25.
//

import SwiftUI
import Core
import Theme

public struct NotificationsPrimerView: View {
    @ObservedObject
    private var viewModel: NotificationsPrimerViewModel
    
    public init(viewModel: NotificationsPrimerViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                if viewModel.isUpdating {
                    ProgressBar(size: 40, lineWidth: 8)
                        .accessibilityIdentifier("progressbar")
                } else {
                    alert
                        .frameLimit(width: geometry.size.width)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.all, 24)
            .onFirstAppear {
                viewModel.markAsShown()
            }
        }
        .background(
            Color.black.opacity(0.4)
                .ignoresSafeArea()
        )
    }
    
    @ViewBuilder
    private var alert: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "bell.fill")
                        .frame(width: 24, height: 24)
                        .foregroundColor(Theme.Colors.primerHeaderButtonText)
                    
                    Text(NotificationsLocalization.Primer.getNotifications)
                        .font(Theme.Fonts.bodyMedium)
                        .foregroundColor(Theme.Colors.primerHeaderButtonText)
                }
                
                Text(NotificationsLocalization.Primer.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(Theme.Fonts.titleLarge)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.all, 20)
            .background(Theme.Colors.primerHeaderBG)
            
            // Content
            VStack(alignment: .leading, spacing: 16) {
                Text(NotificationsLocalization.Primer.message)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(Theme.Fonts.bodyLarge)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Group {
                    if #available(iOS 16.0, *) {
                        ViewThatFits(in: .horizontal) {
                            horizontalButtons
                            verticalButtons
                        }
                    } else {
                        verticalButtons
                    }
                }
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity)
            .padding(.all, 24)
        }
        .background(Theme.Colors.primerContentBG)
        .cornerRadius(8)
        .shadow(color: Theme.Colors.shadowColor, radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private var yesButton: some View {
        StyledButton(
            NotificationsLocalization.Primer.yesNotifyMe,
            action: {
                viewModel.notifyMe()
            },
            color: Theme.Colors.accentButtonColor,
            textColor: Theme.Colors.styledButtonText,
            horizontalPadding: true
        )
        .fixedSize()
    }
    
    @ViewBuilder
    private var noButton: some View {
        StyledButton(
            NotificationsLocalization.Primer.noThanks,
            action: {
                viewModel.noThanks()
            },
            color: .clear,
            textColor: Theme.Colors.resumeButtonText,
            horizontalPadding: true
        )
        .fixedSize()
    }
    
    @ViewBuilder
    private var horizontalButtons: some View {
        HStack {
            noButton
            yesButton
        }
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private var verticalButtons: some View {
        VStack {
            yesButton
            noButton
        }
    }
}

#if DEBUG
#Preview {
    NotificationsPrimerView(
        viewModel: NotificationsPrimerViewModel(
            interactor: NotificationsInteractor.mock,
            router: NotificationsRouterMock(),
            analytics: NotificationsAnalyticsMock()
        )
    )
}
#endif
