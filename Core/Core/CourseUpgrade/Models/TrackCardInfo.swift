//
//  TrackCardInfo.swift
//  Core
//
//  Created by Muhammad Tayyab Akram on 5/5/25.
//

struct TrackCardInfo {
    var heading: String
    var subheading: String
    var description: String

    var paragraphs: [String] {
        return description
            .split(separator: "\n")
            .map { String($0) }
    }
}
