//
//  UpgradeInfoCellView.swift
//  Core
//
//  Created by Vadim Kuznetsov on 11.06.24.
//

import SwiftUI
import Theme

struct UpgradeInfoCellView: View {
    var title: String
    let image: Image?
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            UpgradeInfoPointView(image: image)
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Theme.Fonts.bodyLarge)
        }
    }
}

struct UpgradeInfoPointView: View {
    let image: Image?
    
    var body: some View {
        (image ?? CoreAssets.upgradeCheckmarkImage.swiftUIImage)
            .resizable()
            .frame(width: 20, height: 20)
    }
}

public struct UpgradeOptionsView: View {
    var image: Image?
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            UpgradeInfoCellView(title: CoreLocalization.CourseUpgrade.View.Option.first, image: image)
            UpgradeInfoCellView(title: CoreLocalization.CourseUpgrade.View.Option.second, image: image)
            UpgradeInfoCellView(title: CoreLocalization.CourseUpgrade.View.Option.third, image: image)
        }
    }
}

#if DEBUG
#Preview {
    UpgradeOptionsView()
}
#endif
