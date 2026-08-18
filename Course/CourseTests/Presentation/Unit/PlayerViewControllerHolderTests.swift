//
//  PlayerViewControllerHolderTests.swift
//  CourseTests
//
//  Created by Sumanta Roy on 18.08.26.
//

import SwiftyMocky
import XCTest
@testable import Core
@testable import Course

private final class NowPlayingManagerSpy: NowPlayingManagerProtocol {
    private(set) var setMetadataCalls: [(title: String, artworkURL: URL?, duration: TimeInterval)] = []
    private(set) var updatePlaybackStateCalls: [(elapsedTime: TimeInterval, duration: TimeInterval, rate: Float)] = []
    private(set) var setActivePlayerCallCount = 0
    private(set) var clearCallCount = 0

    func setMetadata(title: String, artworkURL: URL?, duration: TimeInterval) {
        setMetadataCalls.append((title, artworkURL, duration))
    }

    func updatePlaybackState(elapsedTime: TimeInterval, duration: TimeInterval, rate: Float) {
        updatePlaybackStateCalls.append((elapsedTime, duration, rate))
    }

    func setActivePlayer(_ controller: PlayerControllerProtocol?) {
        setActivePlayerCallCount += 1
    }

    func clear() {
        clearCallCount += 1
    }
}

final class PlayerViewControllerHolderTests: XCTestCase {

    private func makeHolder(
        tracker: PlayerTrackerProtocolMock,
        nowPlayingManager: NowPlayingManagerSpy,
        title: String = "Lesson 1",
        artworkURL: URL? = URL(string: "https://example.com/art.png")
    ) -> PlayerViewControllerHolder {
        let interactor = CourseInteractorProtocolMock()
        let router = CourseRouterMock()
        let service = PlayerService(courseID: "course", blockID: "block", interactor: interactor, router: router)

        return PlayerViewControllerHolder(
            url: nil,
            blockID: "block",
            courseID: "course",
            selectedCourseTab: 0,
            title: title,
            artworkURL: artworkURL,
            pipManager: PipManagerProtocolMock(),
            playerTracker: tracker,
            playerDelegate: nil,
            playerService: service,
            appStorage: CoreStorageMock(),
            nowPlayingManager: nowPlayingManager
        )
    }

    func testReadyPublisherSetsMetadataAndActivePlayer() {
        let tracker = PlayerTrackerProtocolMock(url: nil)
        let nowPlayingManager = NowPlayingManagerSpy()
        let artworkURL = URL(string: "https://example.com/art.png")
        let holder = makeHolder(tracker: tracker, nowPlayingManager: nowPlayingManager, artworkURL: artworkURL)

        tracker.sendReady(true)

        XCTAssertEqual(nowPlayingManager.setMetadataCalls.count, 1)
        XCTAssertEqual(nowPlayingManager.setMetadataCalls.first?.title, "Lesson 1")
        XCTAssertEqual(nowPlayingManager.setMetadataCalls.first?.artworkURL, artworkURL)
        XCTAssertEqual(nowPlayingManager.setMetadataCalls.first?.duration, holder.duration)
        XCTAssertEqual(nowPlayingManager.setActivePlayerCallCount, 1)
    }

    func testReadyPublisherFalseDoesNotSetMetadata() {
        let tracker = PlayerTrackerProtocolMock(url: nil)
        let nowPlayingManager = NowPlayingManagerSpy()
        _ = makeHolder(tracker: tracker, nowPlayingManager: nowPlayingManager)

        tracker.sendReady(false)

        XCTAssertTrue(nowPlayingManager.setMetadataCalls.isEmpty)
        XCTAssertEqual(nowPlayingManager.setActivePlayerCallCount, 0)
    }

    func testResolvedDurationIsNotRePushedOnSubsequentTicks() {
        let tracker = PlayerTrackerProtocolMock(url: nil)
        let nowPlayingManager = NowPlayingManagerSpy()
        _ = makeHolder(tracker: tracker, nowPlayingManager: nowPlayingManager)

        tracker.sendProgress(1)
        let callCountAfterFirstTick = nowPlayingManager.updatePlaybackStateCalls.count
        tracker.sendProgress(2)

        XCTAssertEqual(nowPlayingManager.updatePlaybackStateCalls.count, callCountAfterFirstTick)
    }

    func testStopClearsNowPlayingInfo() {
        let tracker = PlayerTrackerProtocolMock(url: nil)
        let nowPlayingManager = NowPlayingManagerSpy()
        let holder = makeHolder(tracker: tracker, nowPlayingManager: nowPlayingManager)

        holder.stop()

        XCTAssertEqual(nowPlayingManager.clearCallCount, 1)
    }

    func testPlayerControllerDisablesAVKitOwnNowPlayingInfoSync() {
        let tracker = PlayerTrackerProtocolMock(url: nil)
        let nowPlayingManager = NowPlayingManagerSpy()
        let holder = makeHolder(tracker: tracker, nowPlayingManager: nowPlayingManager)

        let avPlayerViewController = holder.playerController as? CustomAVPlayerViewController

        XCTAssertEqual(avPlayerViewController?.updatesNowPlayingInfoCenter, false)
    }

    func testUpdateMetadataBeforeReadyDoesNotPushToNowPlayingManager() {
        let tracker = PlayerTrackerProtocolMock(url: nil)
        let nowPlayingManager = NowPlayingManagerSpy()
        let holder = makeHolder(tracker: tracker, nowPlayingManager: nowPlayingManager, title: "", artworkURL: nil)

        let artworkURL = URL(string: "https://example.com/late-art.png")
        holder.updateMetadata(title: "Late Title", artworkURL: artworkURL)

        XCTAssertTrue(nowPlayingManager.setMetadataCalls.isEmpty)
    }

    func testUpdateMetadataAfterReadyPushesImmediately() {
        let tracker = PlayerTrackerProtocolMock(url: nil)
        let nowPlayingManager = NowPlayingManagerSpy()
        let holder = makeHolder(tracker: tracker, nowPlayingManager: nowPlayingManager, title: "", artworkURL: nil)
        tracker.sendReady(true)

        let artworkURL = URL(string: "https://example.com/late-art.png")
        holder.updateMetadata(title: "Late Title", artworkURL: artworkURL)

        XCTAssertEqual(nowPlayingManager.setMetadataCalls.last?.title, "Late Title")
        XCTAssertEqual(nowPlayingManager.setMetadataCalls.last?.artworkURL, artworkURL)
    }

    func testReadyPublisherUsesMetadataUpdatedBeforeReady() {
        let tracker = PlayerTrackerProtocolMock(url: nil)
        let nowPlayingManager = NowPlayingManagerSpy()
        let holder = makeHolder(tracker: tracker, nowPlayingManager: nowPlayingManager, title: "", artworkURL: nil)

        let artworkURL = URL(string: "https://example.com/late-art.png")
        holder.updateMetadata(title: "Late Title", artworkURL: artworkURL)
        tracker.sendReady(true)

        XCTAssertEqual(nowPlayingManager.setMetadataCalls.count, 1)
        XCTAssertEqual(nowPlayingManager.setMetadataCalls.first?.title, "Late Title")
        XCTAssertEqual(nowPlayingManager.setMetadataCalls.first?.artworkURL, artworkURL)
    }
}
