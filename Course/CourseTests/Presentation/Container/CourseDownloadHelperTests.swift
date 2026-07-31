//
//  CourseDownloadHelperTests.swift
//  CourseTests
//
//  Created by Abid Bhatti on 29/07/26.
//

import SwiftyMocky
import XCTest
@testable import Core
@testable import Course
import Combine

final class CourseDownloadHelperTests: XCTestCase {

    var downloadManagerMock: DownloadManagerProtocolMock!
    var helper: CourseDownloadHelper!
    var downloadPublisher: PassthroughSubject<DownloadManagerEvent, Never>!
    var block: CourseBlock!
    var sequential: CourseSequential!
    var task: DownloadDataTask!

    override func setUp() {
        super.setUp()
        downloadManagerMock = DownloadManagerProtocolMock()
        downloadPublisher = PassthroughSubject<DownloadManagerEvent, Never>()

        block = CourseBlock(
            blockId: "",
            id: "1",
            courseId: "123",
            topicId: "",
            graded: false,
            due: Date(),
            completion: 0,
            type: .video,
            displayName: "",
            studentUrl: "",
            webUrl: "",
            encodedVideo: .init(
                fallback: nil,
                youtube: nil,
                desktopMP4: .init(url: "http://test/test.mp4", fileSize: 1000,
                                  streamPriority: 1, type: .desktopMP4),
                mobileHigh: nil,
                mobileLow: nil,
                hls: nil
            ),
            multiDevice: true,
            authorizationDenialReason: .none,
            offlineDownload: nil
        )

        let vertical = CourseVertical(
            blockId: "", id: "", courseId: "123",
            displayName: "", type: .vertical, completion: 0,
            childs: [block], webUrl: ""
        )
        sequential = CourseSequential(
            blockId: "", id: "", displayName: "",
            type: .chapter, completion: 0, childs: [vertical],
            sequentialProgress: nil, due: Date()
        )
        let chapter = CourseChapter(
            blockId: "", id: "", displayName: "",
            type: .chapter, childs: [sequential]
        )
        let courseStructure = CourseStructure(
            id: "123", graded: true, completion: 0,
            viewYouTubeUrl: "", encodedVideo: "", displayName: "",
            topicID: nil, childs: [chapter],
            media: DataLayer.CourseMedia(image: DataLayer.Image(raw: "", small: "", large: "")),
            certificate: nil, org: "", isSelfPaced: true,
            isUpgradeable: false, sku: nil, coursewareAccessDetails: nil,
            courseProgress: nil, lmsPrice: .zero
        )

        task = DownloadDataTask(
            id: "1", blockId: "1", courseId: "123", userId: 0,
            url: "http://test/test.mp4", fileName: "test.mp4",
            displayName: "test.mp4", progress: 0, resumeData: nil,
            state: .inProgress, type: .video, fileSize: 1000
        )

        let taskCopy = task!
        let publisher = downloadPublisher.eraseToAnyPublisher()

        Given(downloadManagerMock, .getDownloadTasks(willReturn: [taskCopy]))
        Given(downloadManagerMock, .currentDownloadTask(getter: taskCopy))
        Given(downloadManagerMock, .eventPublisher(willReturn: publisher))

        helper = CourseDownloadHelper(courseStructure: courseStructure, manager: downloadManagerMock)
    }

    override func tearDown() {
        super.tearDown()
        helper = nil
        downloadManagerMock = nil
    }

    func testSizeForBlock_whenCalled_ShouldReturnSize() {
        let size = helper.sizeFor(block: block)
        XCTAssertEqual(size, block.fileSize)
    }

    func testSizeForBlocks_whenCalled_ShouldReturnSize() {
        let size = helper.sizeFor(blocks: [block])
        XCTAssertEqual(size, block.fileSize ?? 0)
    }

    func testSizeForSequential_whenCalled_ShouldReturnSize() {
        let size = helper.sizeFor(sequential: sequential)
        XCTAssertEqual(size, sequential.totalSize)
    }

    func testSizeForSequentials_whenCalled_ShouldReturnSize() {
        let size = helper.sizeFor(sequentials: [sequential])
        XCTAssertEqual(size, sequential.totalSize)
    }

    func testCancelDownloading_whenCalled_ShouldCallManagerMethod() async throws {
        try await helper.cancelDownloading(task: task)
        Verify(downloadManagerMock, .cancelDownloading(task: .any))
    }
}
