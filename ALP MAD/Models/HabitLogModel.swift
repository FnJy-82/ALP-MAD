//
//  HabitLogModel.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 28/05/26.
//

import Foundation
import SwiftData

@Model
final class HabitLog {
    var id: UUID
    var date: Date
    var isCompleted: Bool
    var habit: Habit?

    init(
        id: UUID = UUID(),
        date: Date = .now,
        isCompleted: Bool = false,
        habit: Habit? = nil
    ) {
        self.id = id
        self.date = date
        self.isCompleted = isCompleted
        self.habit = habit
    }
}
