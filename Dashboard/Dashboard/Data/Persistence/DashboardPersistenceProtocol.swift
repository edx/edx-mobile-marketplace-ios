//
//  DashboardPersistence.swift
//  Dashboard
//
//  Created by  Stepanok Ivan on 27.12.2022.
//

import CoreData
import Core

public protocol DashboardPersistenceProtocol: Sendable {
    func loadServerConfig() async throws -> DataLayer.ServerConfigs?
    func saveServerConfig(configs: DataLayer.ServerConfigs?)
    func loadEnrollments() async throws -> [CourseItem]
    func saveEnrollments(items: [CourseItem]) async
    func loadPrimaryEnrollment() async throws -> PrimaryEnrollment
    func savePrimaryEnrollment(enrollments: PrimaryEnrollment) async
}

public final class DashboardBundle {
    private init() {}
}
