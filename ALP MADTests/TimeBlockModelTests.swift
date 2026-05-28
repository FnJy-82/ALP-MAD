//
//  TimeBlockModelTests.swift
//  ALP MADTests
//
//  Created by student on 28/05/26.
//

import Testing
import Foundation
import SwiftData
@testable import ALP_MAD

@Suite("TimeBlock Model Tests")
struct TimeBlockModelTests {

    private func makeBlock(
        title: String = "Belajar Swift",
        start: Date = .now,
        durationMinutes: Double = 60
    ) -> TimeBlockModel {
        TimeBlockModel(
            title: title,
            startTime: start,
            endTime: start.addingTimeInterval(durationMinutes * 60),
            interestId: UUID()
        )
    }

    @Test("isValid true untuk blok yang benar")
    func validBlock() {
        let block = makeBlock()
        #expect(block.isValid == true)
    }

    @Test("isValid false jika judul kosong")
    func emptyTitle() {
        let block = makeBlock(title: "")
        #expect(block.isValid == false)
    }

    @Test("isValid false jika judul hanya spasi")
    func whitespaceTitle() {
        let block = makeBlock(title: "   ")
        #expect(block.isValid == false)
    }

    @Test("isValid false jika endTime sama dengan startTime")
    func sameStartEnd() {
        let now = Date.now
        let block = TimeBlockModel(
            title: "Test",
            startTime: now,
            endTime: now,
            interestId: UUID()
        )
        #expect(block.isValid == false)
    }

    @Test("isValid false jika endTime sebelum startTime")
    func endBeforeStart() {
        let now = Date.now
        let block = TimeBlockModel(
            title: "Test",
            startTime: now,
            endTime: now.addingTimeInterval(-60),
            interestId: UUID()
        )
        #expect(block.isValid == false)
    }

    @Test("duration terhitung benar untuk 90 menit")
    func durationNinetyMinutes() {
        let block = makeBlock(durationMinutes: 90)
        #expect(block.duration == 90 * 60)
    }

    @Test("duration terhitung benar untuk 30 menit")
    func durationThirtyMinutes() {
        let block = makeBlock(durationMinutes: 30)
        #expect(block.duration == 30 * 60)
    }

    @Test("id unik untuk setiap blok")
    func uniqueIds() {
        let a = makeBlock()
        let b = makeBlock()
        #expect(a.id != b.id)
    }
}
