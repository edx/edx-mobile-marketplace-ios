//
//  PageControl.swift
//  WhatsNew
//
//  Created by  Stepanok Ivan on 18.10.2023.
//

import SwiftUI
import Core
import Theme

public struct PageControl: View {
    let numberOfPages: Int
    var currentPage: Int
    
    public init(numberOfPages: Int, currentPage: Int) {
        self.numberOfPages = numberOfPages
        self.currentPage = currentPage
    }

    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< numberOfPages, id: \.self) { page in
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: page == currentPage ? 24 : 8, height: 8)
                    .foregroundColor(page == currentPage ? Theme.Colors.accentXColor : Theme.Colors.textSecondaryLight)
            }
        }
    }

    public var body: some View {
        VStack {
            Spacer()
            dots
            Spacer()
        }
    }
}
