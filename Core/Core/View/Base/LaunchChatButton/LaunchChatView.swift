//
//  LaunchChatView.swift
//  Core
//
//  Created by Anton Yarmolenka on 10/10/2024.
//

import SwiftUI
import Swinject

public struct LaunchChatView: View {
    @StateObject var viewModel: LaunchChatViewModel
    
    public init(router: BaseRouter, connectivity: ConnectivityProtocol) {
        self._viewModel = .init(wrappedValue: .init(router: router, connectivity: connectivity))
    }
    
    public var body: some View {
        if viewModel.showChatIcon {
            Button {
                viewModel.showLiveChat(animated: true)
            } label: {
                CoreAssets.chatIcon.swiftUIImage
                    .resizable()
                    .frame(width: 45, height: 45)
            }
            .padding(.bottom, 15)
            .padding(.trailing, 15)
        } else {
            EmptyView()
        }
    }
}

#if DEBUG
#Preview {
    LaunchChatView(router: BaseRouterMock(), connectivity: Connectivity())
}
#endif
