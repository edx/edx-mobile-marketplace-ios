//
//  VideoPlayerOverlay.swift
//  Course
//
//  Created by Muhammad Tayyab  Akram on 7/11/25.
//

import Combine
import SwiftUI
import Core
import Theme

struct VideoPlayerOverlay: View {
    @ObservedObject var viewModel: VideoPlayerOverlayViewModel

    var body: some View {
        ZStack {
            if viewModel.showSpeedOverlay {
                VStack {
                    HStack(spacing: 3) {
                        Text("2x")
                            .foregroundColor(.white)
                        Image(systemName: "forward.fill")
                            .foregroundColor(.white)
                    }
                    .font(Theme.Fonts.bodyMedium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.7))
                    .clipShape(Capsule())

                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
#Preview {
    VideoPlayerOverlay(
        viewModel: VideoPlayerOverlayViewModel()
    )
}
#endif
