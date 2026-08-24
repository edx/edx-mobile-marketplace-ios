//
//  EncodedVideoView.swift
//  Course
//
//  Created by Stepanok Ivan on 30.05.2023.
//

import SwiftUI
import Core
import Combine
import Swinject

struct EncodedVideoView: View {
    
    let name: String
    let url: URL?
    let courseID: String
    let blockID: String
    let playerStateSubject: CurrentValueSubject<VideoPlayerState?, Never>
    let languages: [SubtitleUrl]
    let isOnScreen: Bool
    
    @StateObject private var viewModel: EncodedVideoPlayerViewModel

    init(
        name: String,
        url: URL?,
        courseID: String,
        blockID: String,
        playerStateSubject: CurrentValueSubject<VideoPlayerState?, Never>,
        languages: [SubtitleUrl],
        isOnScreen: Bool
    ) {
        self.name = name
        self.url = url
        self.courseID = courseID
        self.blockID = blockID
        self.playerStateSubject = playerStateSubject
        self.languages = languages
        self.isOnScreen = isOnScreen
        self._viewModel = StateObject(wrappedValue: {
            Container.shared.resolve(
                EncodedVideoPlayerViewModel.self,
                arguments: url,
                blockID,
                courseID,
                languages,
                playerStateSubject
            )!
        }())
    }

    var body: some View {
        EncodedVideoPlayer(viewModel: viewModel, isOnScreen: isOnScreen)
    }
}
