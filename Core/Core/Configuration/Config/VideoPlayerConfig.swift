//
//  VideoPlayerConfig.swift
//  Core
//
//  Created by Muhammad Tayyab Akram on 31/07/25.
//

import Foundation

private enum VideoPlayerKey {
    static let videoTranscriptEnabled = "VIDEO_TRANSCRIPT_ENABLED"
    static let blacklistURLs = "BLACKLIST_URLS"
}

public final class VideoPlayerConfig: NSObject {
    public var videoTranscriptEnabled: Bool = false
    public var blacklistURLs: [String] = []

    init(dictionary: [String: AnyObject]) {
        super.init()
        videoTranscriptEnabled = dictionary[VideoPlayerKey.videoTranscriptEnabled] as? Bool ?? false
        blacklistURLs = dictionary[VideoPlayerKey.blacklistURLs] as? [String] ?? []
    }
}

private let videoPlayerKey = "VIDEO_PLAYER"

extension Config {
    public var videoPlayer: VideoPlayerConfig {
        VideoPlayerConfig(dictionary: self[videoPlayerKey] as? [String: AnyObject] ?? [:])
    }
}
