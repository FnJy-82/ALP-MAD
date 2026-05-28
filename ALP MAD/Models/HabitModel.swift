//
//  HabitModel.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 28/05/26.
//

import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var colorHex: String
    var streakCount: Int
    var createdAt: Date

    @Relationship(deleteRule: .cascade) var logs: [HabitLog] = []

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String,
        streakCount: Int = 0,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.streakCount = streakCount
        self.createdAt = createdAt
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

// Models/PomodoroSession.swift

