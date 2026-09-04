//
//  NowPlayingManager.swift
//  Course
//
//  Created by Sumanta Roy on 18.08.26.
//

import Foundation
import MediaPlayer
import Kingfisher

public protocol NowPlayingManagerProtocol: AnyObject {
    var activeController: PlayerControllerProtocol? { get }
    func setMetadata(title: String, artworkURL: URL?, duration: TimeInterval)
    func updatePlaybackState(elapsedTime: TimeInterval, duration: TimeInterval, rate: Float)
    func setActivePlayer(_ controller: PlayerControllerProtocol?)
    func clear()
}

public final class NowPlayingManager: NowPlayingManagerProtocol {
    public private(set) var activeController: PlayerControllerProtocol?
    private let nowPlayingInfoCenter: MPNowPlayingInfoCenter
    private let commandCenter: MPRemoteCommandCenter
    private var artworkDownloadTask: DownloadTask?

    public init(
        nowPlayingInfoCenter: MPNowPlayingInfoCenter = .default(),
        commandCenter: MPRemoteCommandCenter = .shared()
    ) {
        self.nowPlayingInfoCenter = nowPlayingInfoCenter
        self.commandCenter = commandCenter
        configureRemoteCommands()
    }

    private func configureRemoteCommands() {
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.handlePlayCommand() ?? .noActionableNowPlayingItem
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.handlePauseCommand() ?? .noActionableNowPlayingItem
        }
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            return self?.handleSeekCommand(positionTime: positionEvent.positionTime) ?? .noActionableNowPlayingItem
        }
    }

    @discardableResult
    func handlePlayCommand() -> MPRemoteCommandHandlerStatus {
        guard let activeController else { return .noActionableNowPlayingItem }
        activeController.play()
        return .success
    }

    @discardableResult
    func handlePauseCommand() -> MPRemoteCommandHandlerStatus {
        guard let activeController else { return .noActionableNowPlayingItem }
        activeController.pause()
        return .success
    }

    @discardableResult
    func handleSeekCommand(positionTime: TimeInterval) -> MPRemoteCommandHandlerStatus {
        guard let activeController else { return .noActionableNowPlayingItem }
        activeController.seek(to: positionTime)
        return .success
    }

    public func setActivePlayer(_ controller: PlayerControllerProtocol?) {
        activeController = controller
        let isEnabled = controller != nil
        commandCenter.playCommand.isEnabled = isEnabled
        commandCenter.pauseCommand.isEnabled = isEnabled
        commandCenter.changePlaybackPositionCommand.isEnabled = isEnabled
    }

    public func setMetadata(title: String, artworkURL: URL?, duration: TimeInterval) {
        var info = nowPlayingInfoCenter.nowPlayingInfo ?? [:]
        info[MPMediaItemPropertyTitle] = title
        if duration.isFinite {
            info[MPMediaItemPropertyPlaybackDuration] = duration
        }
        info[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.video.rawValue
        nowPlayingInfoCenter.nowPlayingInfo = info

        guard let artworkURL else { return }
        loadArtwork(from: artworkURL)
    }

    public func updatePlaybackState(elapsedTime: TimeInterval, duration: TimeInterval, rate: Float) {
        var info = nowPlayingInfoCenter.nowPlayingInfo ?? [:]
        if elapsedTime.isFinite {
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        }
        if duration.isFinite {
            info[MPMediaItemPropertyPlaybackDuration] = duration
        }
        info[MPNowPlayingInfoPropertyPlaybackRate] = rate
        nowPlayingInfoCenter.nowPlayingInfo = info
    }

    public func clear() {
        artworkDownloadTask?.cancel()
        artworkDownloadTask = nil
        nowPlayingInfoCenter.nowPlayingInfo = nil
        setActivePlayer(nil)
    }

    private func loadArtwork(from url: URL) {
        artworkDownloadTask?.cancel()
        artworkDownloadTask = KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            guard let self, case .success(let value) = result else { return }
            let artwork = MPMediaItemArtwork(boundsSize: value.image.size) { _ in value.image }
            var info = self.nowPlayingInfoCenter.nowPlayingInfo ?? [:]
            info[MPMediaItemPropertyArtwork] = artwork
            self.nowPlayingInfoCenter.nowPlayingInfo = info
        }
    }
}

#if DEBUG
public final class NowPlayingManagerProtocolMock: NowPlayingManagerProtocol {
    public private(set) var activeController: PlayerControllerProtocol?
    public init() {}
    public func setMetadata(title: String, artworkURL: URL?, duration: TimeInterval) {}
    public func updatePlaybackState(elapsedTime: TimeInterval, duration: TimeInterval, rate: Float) {}
    public func setActivePlayer(_ controller: PlayerControllerProtocol?) {
        activeController = controller
    }
    public func clear() {
        activeController = nil
    }
}
#endif
