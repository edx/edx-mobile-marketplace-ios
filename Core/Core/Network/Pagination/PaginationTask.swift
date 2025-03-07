//
//  PaginationTask.swift
//  Core
//
//  Created by Muhammad Tayyab  Akram on 1/30/25.
//

import Foundation

private final class TaskHolder<Item> {
    var task: PaginationTask<Item>!
}

/// A structure representing an ongoing pagination task.
public struct PaginationTask<Item>: Equatable {
    typealias Operation = (PaginationTask<Item>) async throws -> [Item]
    
    private let task: Task<[Item], Error>
    
    private init(task: Task<[Item], Error>) {
        self.task = task
    }
    
    @MainActor
    static func create(operation: @escaping Operation) -> PaginationTask<Item> {
        let taskHolder = TaskHolder<Item>()
        taskHolder.task = PaginationTask(
            task: Task { @MainActor in
                try await operation(taskHolder.task)
            }
        )
        
        return taskHolder.task
    }
    
    /// Cancels the ongoing pagination task.
    public func cancel() {
        task.cancel()
    }
    
    /// A Boolean value that indicates whether the pagination task was canceled.
    public var isCancelled: Bool {
        return task.isCancelled
    }
    
    /// Returns the fetched items asynchronously, throwing an error if the task fails.
    public var items: [Item] {
        get async throws {
            return try await task.value
        }
    }
    
    /// Returns the result of the task asynchronously as a `Result` type.
    public var result: Result<[Item], Error> {
        get async {
            return await task.result
        }
    }
}
