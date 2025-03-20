//
//  UpgradeInfoCellView.swift
//  Core
//
//  Created by Vadim Kuznetsov on 11.06.24.
//

import SwiftUI

struct UpgradeInfoCellView: View {
    var title: String
    let style: EDXIAPStyle
    
    var body: some View {
        HStack(spacing: 10) {
            UpgradeInfoPointView()
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Fonts.bodyLarge.swiftUI())
        }
    }
}

struct UpgradeInfoPointView: View {
    var body: some View {
        Assets.Images.upgradeCheckmarkImage.swiftUI()
            .resizable()
        .frame(width: 30, height: 30)
    }
}

public struct UpgradeOptionsView: View {
    private let style: EDXIAPStyle
    
    init(style: EDXIAPStyle) {
        self.style = style
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            UpgradeInfoCellView(title: Texts.UpgradeInfo.optionFirst, style: style)
            UpgradeInfoCellView(title: Texts.UpgradeInfo.optionSecond, style: style)
            UpgradeInfoCellView(title: Texts.UpgradeInfo.optionThird, style: style)
        }
    }
}
