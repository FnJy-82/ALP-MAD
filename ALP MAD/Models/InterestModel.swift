//
//  InterestModel.swift
//  ALP MAD
//
//  Created by student on 28/05/26.
//

import Foundation
import SwiftData

@Model
final class Interest {
    var id: UUID
    var name: String
    var colorHex: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.createdAt = createdAt
    }
}
