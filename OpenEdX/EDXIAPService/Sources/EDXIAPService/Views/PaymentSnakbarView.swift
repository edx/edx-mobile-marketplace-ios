//
//  PaymentSnakbarView.swift
//  Core
//
//  Created by Vadim Kuznetsov on 11.06.24.
//

import SwiftUI

public struct PaymentSnakbarView: View {
    private let style: EDXIAPStyle
    
    init(style: EDXIAPStyle) {
        self.style = style
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Texts.SnackBar.title)
                .font(Fonts.titleMedium.swiftUI())
                .foregroundColor(style.colors.textPrimary)
            
            Text(Texts.SnackBar.successMessage)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Fonts.labelLarge.swiftUI())
                .foregroundColor(style.colors.textPrimary)
        }
        .padding(20)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(style.colors.datesSectionStroke, lineWidth: 2)
        )
        .background(style.colors.datesSectionBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
        .padding(16)
    }
}

#if DEBUG
#Preview {
    PaymentSnakbarView(style: EDXIAPStyle.init())
}
#endif
