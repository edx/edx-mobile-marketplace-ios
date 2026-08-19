//
//  PlayerControllerProtocol.swift
//  Course
//
//  Created by Vadim Kuznetsov on 22.04.24.
//

import Foundation

public protocol PlayerControllerProtocol: AnyObject {
    func play()
    func pause()
    func seekTo(to date: Date)
    func seek(to time: TimeInterval)
    func stop()
}
