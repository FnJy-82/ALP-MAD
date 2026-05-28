//
//  TimeBlock.swift
//  ALP MAD
//
//  Created by student on 28/05/26.
//

import Foundation
import SwiftData

@Model
final class TimeBlock {
    var id: UUID
    var title: String
    var startTime: Date
    var endTime: Date
    var interestId: UUID

    init(
        id: UUID = UUID(),
        title: String,
        startTime: Date,
        endTime: Date,
        interestId: UUID
    ) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.interestId = interestId
    }

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    var isValid: Bool {
        endTime > startTime && !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
