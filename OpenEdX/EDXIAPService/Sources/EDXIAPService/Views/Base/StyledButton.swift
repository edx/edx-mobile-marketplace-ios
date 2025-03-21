//
//  StyledButton.swift
//  Core
//
//  Created by Vladimir Chekyrta on 14.09.2022.
//

import SwiftUI

public struct StyledButton: View {
    public enum ImagesStyle {
        case onSides
        case attachedToText
    }

    private let title: String
    private let action: () -> Void
    private let isTransparent: Bool
    private var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    private let buttonColor: Color
    private let textColor: Color
    private let isActive: Bool
    private let horizontalPadding: Bool
    private let borderColor: Color
    private let leftImage: Image?
    private let rightImage: Image?
    private let imagesStyle: ImagesStyle
    private let isTitleTracking: Bool
    private let isLimitedOnPad: Bool
    private let shape: RoundedCorners
    
    public init(_ title: String,
                style: EDXIAPStyle? = nil,
                action: @escaping () -> Void,
                isTransparent: Bool = false,
                color: Color? = nil,
                textColor: Color? = nil,
                borderColor: Color = .clear,
                leftImage: Image? = nil,
                rightImage: Image? = nil,
                imagesStyle: ImagesStyle = .attachedToText,
                isActive: Bool = true,
                isTitleTracking: Bool = true,
                isLimitedOnPad: Bool = true,
                shape: RoundedCorners = RoundedCorners(tl: 8, tr: 8, bl: 8, br: 8),
                horizontalPadding: Bool = false
    ) {
        self.title = title
        self.action = action
        self.isTransparent = isTransparent
        self.textColor = textColor ?? style?.colors.styledButtonText ?? Assets.Colors.styledButtonText.swiftUI()
        self.borderColor = borderColor
        self.buttonColor = color ?? style?.colors.accentButtonColor ?? Assets.Colors.accentButtonColor.swiftUI()
        self.isActive = isActive
        self.leftImage = leftImage
        self.rightImage = rightImage
        self.imagesStyle = imagesStyle
        self.isTitleTracking = isTitleTracking
        self.isLimitedOnPad = isLimitedOnPad
        self.shape = shape
        self.horizontalPadding = horizontalPadding
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                if imagesStyle == .attachedToText {
                    Spacer()
                }

                if let icon = leftImage {
                    icon
                        .renderingMode(.template)
                        .foregroundStyle(textColor)
                }
                Text(title)
                    .tracking(isTitleTracking ? 1.3 : 0)
                    .foregroundColor(textColor)
                    .font(Fonts.labelLarge.swiftUI())
                    .opacity(isActive ? 1.0 : 0.6)

                if imagesStyle == .onSides {
                    Spacer()
                }

                if let icon = rightImage {
                    icon
                        .renderingMode(.template)
                        .foregroundStyle(textColor)
                }
                
                if imagesStyle == .attachedToText {
                    Spacer()
                }
            }
            .padding(.horizontal, imagesStyle == .onSides ? 10 : horizontalPadding ? 20 : 0)
            
        }
        .disabled(!isActive)
        .frame(maxWidth: idiom == .pad && isLimitedOnPad ? 260: .infinity, minHeight: isTransparent ? 36 : 42)
        .background(
            shape
                .fill(isTransparent ? .clear : buttonColor)
                .opacity(isActive ? 1.0 : 0.3)
        )
        .overlay(
            shape
                .stroke(style: .init(lineWidth: 1, lineCap: .round, lineJoin: .round, miterLimit: 1))
                .foregroundColor(isTransparent ? Assets.Colors.white.swiftUI() : borderColor)
                .opacity(isActive ? 1.0 : 0.6)
        
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
    }
}

#if DEBUG
#Preview {
    VStack {
        StyledButton("Active Button", action: {}, isActive: true)
        StyledButton("Disabled button", action: {}, isActive: false)
        StyledButton(
            "Back Button",
            action: {},
            leftImage: Assets.Images.chevronRight.swiftUI(),
            isActive: true
        )
    }
    .padding(20)
}
#endif
