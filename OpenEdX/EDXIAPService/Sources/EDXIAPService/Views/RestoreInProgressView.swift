//
//  RestoreInProgressView.swift
//  Core
//
//  Created by Saeed Bashir on 6/4/24.
//

import SwiftUI

public struct RestoreInProgressView: View {
    private let style: EDXIAPStyle
    
    init(style: EDXIAPStyle) {
        self.style = style
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 20) {
                Text(Texts.Restore.inprogressText)
                    .foregroundColor(style.colors.whiteColor)
                    .font(Fonts.bodyLarge.swiftUI())
                    .accessibilityIdentifier("restore_inprogress_text")
                
                ProgressBar(size: 40, lineWidth: 8, accentColor: style.colors.accentColor)
                    .padding(20)
                    .accessibilityIdentifier("progressbar")
            }
        }
        .ignoresSafeArea()
    }
}
