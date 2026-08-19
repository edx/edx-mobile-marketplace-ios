//
//  NowPlayingManagerTests.swift
//  CourseTests
//
//  Created by Sumanta Roy on 18.08.26.
//

import MediaPlayer
import XCTest
@testable import Course

private final class PlayerControllerProtocolSpy: PlayerControllerProtocol {
    private(set) var playCallCount = 0
    private(set) var pauseCallCount = 0
    private(set) var seekToDate: Date?
    private(set) var seekToTime: TimeInterval?

    func play() {
        playCallCount += 1
    }

    func pause() {
        pauseCallCount += 1
    }

    func seekTo(to date: Date) {
        seekToDate = date
    }

    func seek(to time: TimeInterval) {
        seekToTime = time
    }

    func stop() {}
}

final class NowPlayingManagerTests: XCTestCase {

    func testSetMetadataPopulatesTitleAndDuration() {
        let manager = NowPlayingManager()

        manager.setMetadata(title: "Lesson 1", artworkURL: nil, duration: 120)

        let info = MPNowPlayingInfoCenter.default().nowPlayingInfo
        XCTAssertEqual(info?[MPMediaItemPropertyTitle] as? String, "Lesson 1")
        XCTAssertEqual(info?[MPMediaItemPropertyPlaybackDuration] as? TimeInterval, 120)

        manager.clear()
    }

    func testUpdatePlaybackStatePopulatesElapsedTimeDurationAndRate() {
        let manager = NowPlayingManager()

        manager.setMetadata(title: "Lesson 1", artworkURL: nil, duration: 120)
        manager.updatePlaybackState(elapsedTime: 42, duration: 125, rate: 1.0)

        let info = MPNowPlayingInfoCenter.default().nowPlayingInfo
        XCTAssertEqual(info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval, 42)
        XCTAssertEqual(info?[MPMediaItemPropertyPlaybackDuration] as? TimeInterval, 125)
        XCTAssertEqual(info?[MPNowPlayingInfoPropertyPlaybackRate] as? Float, 1.0)

        manager.clear()
    }

    func testSetMetadataWithNaNDurationOmitsDurationKey() {
        let manager = NowPlayingManager()

        manager.setMetadata(title: "Lesson 1", artworkURL: nil, duration: .nan)

        let info = MPNowPlayingInfoCenter.default().nowPlayingInfo
        XCTAssertEqual(info?[MPMediaItemPropertyTitle] as? String, "Lesson 1")
        XCTAssertNil(info?[MPMediaItemPropertyPlaybackDuration])

        manager.clear()
    }

    func testUpdatePlaybackStateSelfHealsDurationSetAsNaNBySetMetadata() {
        let manager = NowPlayingManager()

        manager.setMetadata(title: "Lesson 1", artworkURL: nil, duration: .nan)
        manager.updatePlaybackState(elapsedTime: 5, duration: 125, rate: 1.0)

        let info = MPNowPlayingInfoCenter.default().nowPlayingInfo
        XCTAssertEqual(info?[MPMediaItemPropertyPlaybackDuration] as? TimeInterval, 125)

        manager.clear()
    }

    func testClearRemovesNowPlayingInfoAndActivePlayer() {
        let manager = NowPlayingManager()
        let controller = PlayerControllerProtocolSpy()

        manager.setMetadata(title: "Lesson 1", artworkURL: nil, duration: 120)
        manager.setActivePlayer(controller)

        manager.clear()

        XCTAssertNil(MPNowPlayingInfoCenter.default().nowPlayingInfo)
        XCTAssertEqual(manager.handlePlayCommand(), .noActionableNowPlayingItem)
    }

    func testHandlePlayCommandForwardsToActiveController() {
        let manager = NowPlayingManager()
        let controller = PlayerControllerProtocolSpy()
        manager.setActivePlayer(controller)

        let status = manager.handlePlayCommand()

        XCTAssertEqual(status, .success)
        XCTAssertEqual(controller.playCallCount, 1)

        manager.clear()
    }

    func testHandlePauseCommandForwardsToActiveController() {
        let manager = NowPlayingManager()
        let controller = PlayerControllerProtocolSpy()
        manager.setActivePlayer(controller)

        let status = manager.handlePauseCommand()

        XCTAssertEqual(status, .success)
        XCTAssertEqual(controller.pauseCallCount, 1)

        manager.clear()
    }

    func testHandleSeekCommandForwardsElapsedSecondsToActiveController() {
        let manager = NowPlayingManager()
        let controller = PlayerControllerProtocolSpy()
        manager.setActivePlayer(controller)

        let status = manager.handleSeekCommand(positionTime: 30)

        XCTAssertEqual(status, .success)
        XCTAssertEqual(controller.seekToTime, 30)

        manager.clear()
    }

    func testCommandsReturnNoActionableItemWithoutActivePlayer() {
        let manager = NowPlayingManager()
        manager.clear()

        XCTAssertEqual(manager.handlePlayCommand(), .noActionableNowPlayingItem)
        XCTAssertEqual(manager.handlePauseCommand(), .noActionableNowPlayingItem)
        XCTAssertEqual(manager.handleSeekCommand(positionTime: 10), .noActionableNowPlayingItem)
    }

    func testSetActivePlayerNilStopsRoutingCommands() {
        let manager = NowPlayingManager()
        let controller = PlayerControllerProtocolSpy()
        manager.setActivePlayer(controller)
        manager.setActivePlayer(nil)

        XCTAssertEqual(manager.handlePlayCommand(), .noActionableNowPlayingItem)
        XCTAssertEqual(controller.playCallCount, 0)
    }

    func testActiveControllerReflectsSetActivePlayerAndClear() {
        let manager = NowPlayingManager()
        let controllerA = PlayerControllerProtocolSpy()
        let controllerB = PlayerControllerProtocolSpy()

        manager.setActivePlayer(controllerA)
        XCTAssertTrue(manager.activeController === controllerA)

        manager.setActivePlayer(controllerB)
        XCTAssertTrue(manager.activeController === controllerB)

        manager.clear()
        XCTAssertNil(manager.activeController)
    }
}
