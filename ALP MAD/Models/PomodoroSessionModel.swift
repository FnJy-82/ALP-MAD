//
//  PomodoroSession.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 28/05/26.
//

import Foundation
import SwiftData

enum PomodoroState: String, Codable {
    case idle
    case running
    case paused
    case onBreak
    case completed
}

@Model
final class PomodoroSessionModel {
    var id: UUID
    var focusDuration: Int
    var breakDuration: Int
    var completedCycles: Int
    var state: PomodoroState
    var startedAt: Date
    var linkedHabitId: UUID?

    init(
        id: UUID = UUID(),
        focusDuration: Int = 25 * 60,
        breakDuration: Int = 5 * 60,
        completedCycles: Int = 0,
        state: PomodoroState = .idle,
        startedAt: Date = .now,
        linkedHabitId: UUID? = nil
    ) {
        self.id = id
        self.focusDuration = focusDuration
        self.breakDuration = breakDuration
        self.completedCycles = completedCycles
        self.state = state
        self.startedAt = startedAt
        self.linkedHabitId = linkedHabitId
    }

    var isRunning: Bool {
        state == .running || state == .onBreak
    }

    var currentDuration: Int {
        state == .onBreak ? breakDuration : focusDuration
    }
}
