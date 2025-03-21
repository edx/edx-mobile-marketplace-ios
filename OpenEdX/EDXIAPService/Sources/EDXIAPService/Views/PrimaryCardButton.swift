//
//  PrimaryCardButton.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import SwiftUI

public struct PrimaryCardButton: View {
    private let action: (() -> Void)?
    private let style: EDXIAPStyle
    init(style: EDXIAPStyle, action: (() -> Void)?) {
        self.action = action
        self.style = style
    }
    
    public var body: some View {
        Button(action: {
            action?()
        }, label: {
            ZStack(alignment: .top) {
                Rectangle().frame(height: 1)
                    .foregroundStyle(style.colors.cardViewStroke)
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Assets.Images.trophy.swiftUI()
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(style.colors.textPrimary)
                                .padding(12)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(Texts.Button.upgrade)
                                    .font(Fonts.titleSmall.swiftUI())
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(1)
                                    .foregroundStyle(style.colors.textPrimary)
                            }
                            .padding(.top, 2)
                        }
                    }
                    .padding(.bottom, 8)
                    Spacer()
                    Assets.Images.chevronRight.swiftUI()
                        .foregroundStyle(style.colors.textPrimary)
                        .padding(8)
                }
                .padding(.top, 8)
            }.background(style.colors.primaryCardCourseUpgradeBG)
        })
    }
}

#if DEBUG
#Preview {
    PrimaryCardButton(style: EDXIAPStyle.init(), action: nil)
}
#endif
