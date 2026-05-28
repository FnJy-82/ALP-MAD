//
//  Task.swift
//  ALP MAD
//
//  Created by student on 28/05/26.
//

import Foundation
import SwiftData

enum Priority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

@Model
final class Task {
    var id: UUID
    var title: String
    var priority: Priority
    var deadline: Date?
    var isDone: Bool
    var createdAt: Date

    //Relasi ke Interest
    var interest: Interest?

    init(
        id: UUID = UUID(),
        title: String,
        priority: Priority = .medium,
        deadline: Date? = nil,
        isDone: Bool = false,
        createdAt: Date = .now,
        interest: Interest? = nil
    ) {
        self.id = id
        self.title = title
        self.priority = priority
        self.deadline = deadline
        self.isDone = isDone
        self.createdAt = createdAt
        self.interest = interest
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var isOverdue: Bool {
        guard let deadline, !isDone else { return false }
        return deadline < .now
    }
}
