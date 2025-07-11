//
//  CourseRouter.swift
//  Course
//
//  Created by  Stepanok Ivan on 16.11.2022.
//

import Foundation
import Core
import Combine

public protocol CourseRouter: BaseRouter {
    
    func presentAppReview()
    
    func showCourseUnit(
        courseName: String,
        blockId: String,
        courseID: String,
        verticalIndex: Int,
        chapters: [CourseChapter],
        chapterIndex: Int,
        sequentialIndex: Int,
        courseStructurePublisher: AnyPublisher<CourseStructure?, Never>?
    )
    
    func replaceCourseUnit(
        courseName: String,
        blockId: String,
        courseID: String,
        verticalIndex: Int,
        chapters: [CourseChapter],
        chapterIndex: Int,
        sequentialIndex: Int,
        animated: Bool,
        courseStructurePublisher: AnyPublisher<CourseStructure?, Never>?
    )
    
    func showCourseVerticalView(
        courseID: String,
        courseName: String,
        title: String,
        chapters: [CourseChapter],
        chapterIndex: Int,
        sequentialIndex: Int,
        courseStructurePublisher: AnyPublisher<CourseStructure?, Never>?
    )
    
    func showHandoutsUpdatesView(
        handouts: String?,
        announcements: [CourseUpdate]?,
        router: Course.CourseRouter,
        cssInjector: CSSInjector,
        type: HandoutsItemType
    )
    
    func showCourseComponent(
        componentID: String,
        courseStructure: CourseStructure,
        blockLink: String
    )

    func showDownloads(
        downloads: [DownloadDataTask],
        manager: DownloadManagerProtocol
    )
    
    func showTabScreen(tab: MainTab)
    
    func showGatedContentError(url: String)
}

// Mark - For testing and SwiftUI preview
#if DEBUG
public class CourseRouterMock: BaseRouterMock, CourseRouter {
    
    public override init() {}
    
    public func presentAppReview() {}
    
    public func showCourseUnit(
        courseName: String,
        blockId: String,
        courseID: String,
        verticalIndex: Int,
        chapters: [CourseChapter],
        chapterIndex: Int,
        sequentialIndex: Int,
        courseStructurePublisher: AnyPublisher<CourseStructure?, Never>? = nil
    ) {}
    
    public func replaceCourseUnit(
        courseName: String,
        blockId: String,
        courseID: String,
        verticalIndex: Int,
        chapters: [CourseChapter],
        chapterIndex: Int,
        sequentialIndex: Int,
        animated: Bool,
        courseStructurePublisher: AnyPublisher<CourseStructure?, Never>? = nil
    ) {}
    
    public func showCourseVerticalView(
        courseID: String,
        courseName: String,
        title: String,
        chapters: [CourseChapter],
        chapterIndex: Int,
        sequentialIndex: Int,
        courseStructurePublisher: AnyPublisher<CourseStructure?, Never>? = nil
    ) {}
    
    public func showHandoutsUpdatesView(
        handouts: String?,
        announcements: [CourseUpdate]?,
        router: Course.CourseRouter,
        cssInjector: CSSInjector,
        type: HandoutsItemType
    ) {}
    
    public func showCourseComponent(
        componentID: String,
        courseStructure: CourseStructure,
        blockLink: String
    ) {}

    public func showDownloads(
        downloads: [Core.DownloadDataTask],
        manager: Core.DownloadManagerProtocol
    ) {}
    
    public func showTabScreen(tab: MainTab) {}
    
    public func showGatedContentError(url: String) {}
}
#endif
