//
//  CoursePersistence.swift
//  Course
//
//  Created by  Stepanok Ivan on 15.12.2022.
//

import CoreData
import Core

public protocol CoursePersistenceProtocol {
    func loadEnrollments() async throws -> [Core.CourseItem]
    func saveEnrollments(items: [Core.CourseItem])
    func loadCourseStructure(courseID: String) async throws -> DataLayer.CourseStructure
    func saveCourseStructure(structure: DataLayer.CourseStructure)
    func saveSubtitles(url: String, subtitlesString: String)
    func loadSubtitles(url: String) async -> String?
    func saveCourseDates(courseID: String, courseDates: CourseDates)
    func loadCourseDates(courseID: String) throws -> CourseDates
    func saveCourseProgress(courseID: String, courseProgress: CourseProgressDetails) async
    func loadCourseProgress(courseID: String) async throws -> CourseProgressDetails
    func updateLocalVideoProgress(blockID: String, progress: Double) async
    func loadLocalVideoProgress(blockID: String) async -> Double?
}

public final class CourseBundle {
    private init() {}
}
    
