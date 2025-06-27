//
//  CourseStructureHolder.swift
//  Course
//
//  Created by Shafqat Muneer on 6/25/25.
//

import Foundation
import Core

public protocol CourseStructureHolderProtocol {
    var value: CourseStructure? { get set }
}

public final class CourseStructureHolder: CourseStructureHolderProtocol {
    public var value: CourseStructure?

    public init(value: CourseStructure? = nil) {
        self.value = value
    }
}

#if DEBUG
public final class CourseStructureHolderMock: CourseStructureHolderProtocol {
    public var value: Core.CourseStructure?
    
    public init() {}
}
#endif
