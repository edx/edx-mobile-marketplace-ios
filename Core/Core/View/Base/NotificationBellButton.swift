//
//  NotificationBellButton.swift
//  Core
//
//  Created by Muhammad Tayyab Akram on 3/19/25.
//

import CoreGraphics
import SwiftUI
import UIKit
import Theme

public struct NotificationBellButton: View {
    public enum Indicator {
        case none
        case dot
    }

    @Binding private var indicator: Indicator
    private let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var icon: Image?

    public init(
        indicator: Binding<Indicator>,
        action: @escaping () -> Void
    ) {
        self._indicator = indicator
        self.action = action
    }

    public var body: some View {
        Button(
            action: action,
            label: {
                icon
            }
        )
        .onAppear {
            updateIcon()
        }
        .onChange(of: indicator) { _ in
            updateIcon()
        }
        .onChange(of: colorScheme) { _ in
            updateIcon()
        }
    }

    private var accentBellIcon: UIImage {
        return CoreAssets.notificationsIcon.image
            .withTintColor(ThemeAssets.accentColor.color, renderingMode: .alwaysTemplate)
    }

    private func makeDotIndicatorIcon() -> UIImage {
        let bellIcon = accentBellIcon
        let iconSize = bellIcon.size

        let dotColor = ThemeAssets.accentButtonColor.color

        let rendererFormat = UIGraphicsImageRendererFormat.preferred()
        rendererFormat.opaque = false
        rendererFormat.preferredRange = .extended

        let imageRenderer = UIGraphicsImageRenderer(
            size: iconSize,
            format: rendererFormat
        )

        return imageRenderer.image { rendererContext in
            let cgContext = rendererContext.cgContext
            let dotFrame = CGRect(
                x: iconSize.width - 9, y: 2,
                width: 8, height: 8
            )

            // Draw the bell icon.
            bellIcon.draw(at: .zero)

            // Clear the dot area.
            cgContext.setBlendMode(.clear)
            cgContext.addEllipse(in: dotFrame.insetBy(dx: -2, dy: -2))
            cgContext.drawPath(using: .fill)

            // Draw the dot circle.
            cgContext.setBlendMode(.normal)
            cgContext.setFillColor(dotColor.cgColor)
            cgContext.addEllipse(in: dotFrame)
            cgContext.drawPath(using: .fill)
        }
    }

    private func updateIcon() {
        switch indicator {
        case .none:
            icon = Image(uiImage: accentBellIcon)
        case .dot:
            icon = Image(uiImage: makeDotIndicatorIcon())
        }
    }
}

#if DEBUG
#Preview("No Indicator") {
    NotificationBellButton(
        indicator: .constant(.none),
        action: {}
    )
}

#Preview("Dot Indicator") {
    NotificationBellButton(
        indicator: .constant(.dot),
        action: {}
    )
}
#endif
