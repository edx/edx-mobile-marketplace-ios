//
//  SubtitlesView.swift
//  Course
//
//  Created by  Stepanok Ivan on 04.04.2023.
//

import Combine
import SwiftUI
import Core
import Theme

public struct Subtitle: Sendable {
    var id: Int
    var fromTo: DateInterval
    var text: String
}

public struct SubtitlesView: View {
    
    @Environment(\.isHorizontal) private var isHorizontal
    
    @ObservedObject
    private var viewModel: VideoPlayerViewModel
    private var scrollTo: ((Date) -> Void) = { _ in }
    
    @Binding var currentTime: Double
    @State var id = 0
    @State var pause: Bool = false
    @State var languages: [SubtitleUrl]
    
    @State private var isAnimating = false
    @State private var syncBlock: (() -> Void)?
    
    @State private var autoScrollPublisher = PassthroughSubject<Void, Never>()
    
    private enum Constants {
        static let autoScrollInterval: TimeInterval = 3.0
        static let animationDuration: TimeInterval = 0.3
        static let animationSkipInterval: TimeInterval = animationDuration + 0.05
    }
    
    public init(languages: [SubtitleUrl],
                currentTime: Binding<Double>,
                viewModel: VideoPlayerViewModel,
                scrollTo: @escaping (Date) -> Void) {
        self.languages = languages
        self.viewModel = viewModel
        self._currentTime = currentTime
        self.scrollTo = scrollTo
    }
    
    public var body: some View {
        ScrollViewReader { scroll in
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(viewModel.subtitles.isEmpty ? "" : CourseLocalization.Subtitles.title)
                        .font(Theme.Fonts.titleMedium)
                    Spacer()
                    if !viewModel.languages.isEmpty && viewModel.languages.count > 1 {
                        Button(action: {
                            viewModel.presentPicker()
                        }, label: {
                            Group {
                                CoreAssets.sub.swiftUIImage.renderingMode(.template)
                                Text(viewModel.generateLanguageName(code: viewModel.selectedLanguage ?? ""))
                            }.foregroundColor(Theme.Colors.accentColor)
                                .font(Theme.Fonts.labelLarge)
                        })
                    }
                }
                ZStack {
                    ScrollView {
                        if viewModel.subtitles.count > 0 {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                ForEach(viewModel.subtitles, id: \.id) { subtitle in
                                    HStack {
                                        Button(action: {
                                            scrollTo(subtitle.fromTo.start)
                                            pause = false
                                        }, label: {
                                        Text(subtitle.text)
                                            .padding(.vertical, 16)
                                            .font(subtitle.fromTo.contains(Date(milliseconds: currentTime))
                                                  ? Theme.Fonts.titleMedium
                                                  : Theme.Fonts.bodyMedium)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(subtitle.fromTo.contains(Date(milliseconds: currentTime))
                                                             ? Theme.Colors.accentButtonColor
                                                             : Theme.Colors.textPrimary)
                                        })
                                    }.id(subtitle.id)
                                }
                            }
                        }
                    }
                    .simultaneousGesture(
                        DragGesture().onChanged({ _ in
                            pause = true
                            autoScrollPublisher.send()
                        })
                    )
                    .onChange(of: currentTime) { _ in
                        refreshID()
                    }
                    .onChange(of: viewModel.isPlaying) { isPlaying in
                        if isPlaying {
                            scrollTo(id, in: scroll)
                        }
                    }
                    .onChange(of: id) { newID in
                        scrollTo(newID, in: scroll)
                    }
                    .onReceive(
                        autoScrollPublisher.debounce(
                            for: .seconds(Constants.autoScrollInterval),
                            scheduler: DispatchQueue.main
                        ),
                        perform: { _ in
                            if pause {
                                refreshID()
                                pause = false
                            }
                        }
                    )
                }
            }.padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, isHorizontal ? 100 : 16)
        }
    }
    
    private func refreshID() {
        if let subtitle = viewModel.findSubtitle(at: Date(milliseconds: currentTime)) {
            id = subtitle.id
        }
    }
    
    private func scrollTo(_ viewID: Int, in scrollView: ScrollViewProxy) {
        if !pause {
            let scrollBlock = {
                if viewModel.isPlaying {
                    isAnimating = true
                    
                    withAnimation(.linear(duration: Constants.animationDuration)) {
                        scrollView.scrollTo(viewID, anchor: .top)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.animationSkipInterval) {
                        isAnimating = false
                        
                        if let nextBlock = syncBlock {
                            syncBlock = nil
                            nextBlock()
                        }
                    }
                } else {
                    scrollView.scrollTo(viewID, anchor: .top)
                }
            }
            
            if isAnimating {
                syncBlock = scrollBlock
            } else {
                scrollBlock()
            }
        }
    }
}

#if DEBUG
import Combine
struct SubtittlesView_Previews: PreviewProvider {
    static var previews: some View {
        
        SubtitlesView(
            languages: [SubtitleUrl(language: "fr", url: "url"),
                        SubtitleUrl(language: "uk", url: "url2")],
            currentTime: .constant(0),
            viewModel: VideoPlayerViewModel(
                languages: [],
                playerStateSubject: CurrentValueSubject<VideoPlayerState?, Never>(nil),
                connectivity: Connectivity(),
                playerHolder: PlayerViewControllerHolder.mock,
                appStorage: CoreStorageMock(),
                analytics: CourseAnalyticsMock()
            ), scrollTo: {_ in }
        )
    }
}
#endif
