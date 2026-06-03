//
//  HabitLogModel.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 28/05/26.
//

import Foundation
import SwiftData

@Model
final class HabitLogModel {
    var id: UUID
    var date: Date
    var isCompleted: Bool
    var habit: HabitModel?

    init(
        id: UUID = UUID(),
        date: Date = .now,
        isCompleted: Bool = false,
        habit: HabitModel? = nil
    ) {
        self.id = id
        self.date = date
        self.isCompleted = isCompleted
        self.habit = habit
    }
}
