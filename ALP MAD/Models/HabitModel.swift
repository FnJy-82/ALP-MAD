//
//  HabitModel.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 28/05/26.
//

import Foundation
import SwiftData

@Model
final class HabitModel {
    var id: UUID
    var name: String
    var colorHex: String
    var streakCount: Int
    var createdAt: Date

    @Relationship(deleteRule: .cascade) var logs: [HabitLogModel] = []

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

    /// Streak hari berturut-turut yang DITURUNKAN dari logs — selalu konsisten dengan
    /// data (tidak bisa basi seperti nilai tersimpan). Hari ini diberi tenggang: streak
    /// tidak putus hanya karena hari ini belum dicentang (dihitung mundur dari kemarin).
    var currentStreak: Int {
        let cal = Calendar.current
        let completedDays = Set(
            logs.filter { $0.isCompleted }.map { cal.startOfDay(for: $0.date) }
        )
        guard !completedDays.isEmpty else { return 0 }

        var day = cal.startOfDay(for: .now)
        if !completedDays.contains(day) {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }

        var streak = 0
        while completedDays.contains(day) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }
}
