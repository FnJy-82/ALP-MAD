//
//  ALP_MAD_Watch_App_Watch_AppTests.swift
//  ALP MAD Watch App Watch AppTests
//
//  Created by Emma Puspa Sari on 11/06/26.
//

import Testing
import Foundation
@testable import ALP_MAD_Watch_App_Watch_App

struct ALP_MAD_Watch_App_Watch_AppTests {

    // MARK: TimeBlock parsing
    @Test("parseTimeBlocks: payload valid jadi WatchTimeBlock")
    func parseTimeBlocksValid() {
        let now = Date().timeIntervalSince1970
        let data: [String: Any] = [
            "timeBlocks": [
                ["id": "1", "title": "Belajar", "startTime": now, "endTime": now + 3600, "interestId": "x"]
            ]
        ]
        let blocks = WatchConnectivityProvider.parseTimeBlocks(data)
        #expect(blocks.count == 1)
        #expect(blocks.first?.title == "Belajar")
        #expect(blocks.first?.end.timeIntervalSince1970 == now + 3600)
    }

    @Test("parseTimeBlocks: diurutkan berdasarkan waktu mulai")
    func parseTimeBlocksSorted() {
        let now = Date().timeIntervalSince1970
        let data: [String: Any] = [
            "timeBlocks": [
                ["id": "2", "title": "Siang", "startTime": now + 7200, "endTime": now + 9000, "interestId": "x"],
                ["id": "1", "title": "Pagi", "startTime": now, "endTime": now + 3600, "interestId": "x"]
            ]
        ]
        let blocks = WatchConnectivityProvider.parseTimeBlocks(data)
        #expect(blocks.map(\.title) == ["Pagi", "Siang"])
    }

    @Test("parseTimeBlocks: entri tanpa field wajib di-skip")
    func parseTimeBlocksSkipsInvalid() {
        let data: [String: Any] = [
            "timeBlocks": [
                ["id": "1", "title": "Tanpa waktu"],   // tanpa start/end → skip
                ["id": "2", "title": "Valid", "startTime": 0.0, "endTime": 3600.0, "interestId": "x"]
            ]
        ]
        let blocks = WatchConnectivityProvider.parseTimeBlocks(data)
        #expect(blocks.count == 1)
        #expect(blocks.first?.title == "Valid")
    }

    // MARK: Habit parsing
    @Test("parseHabits: payload valid jadi WatchHabit dengan streak")
    func parseHabitsValid() {
        let data: [String: Any] = [
            "habits": [
                ["id": "1", "name": "Lari", "colorHex": "#FF0000", "streakCount": 3]
            ]
        ]
        let habits = WatchConnectivityProvider.parseHabits(data)
        #expect(habits.count == 1)
        #expect(habits.first?.name == "Lari")
        #expect(habits.first?.colorHex == "#FF0000")
        #expect(habits.first?.streak == 3)
    }

    @Test("parseHabits: entri tanpa nama di-skip")
    func parseHabitsSkipsInvalid() {
        let data: [String: Any] = [
            "habits": [
                ["id": "1"],                       // tanpa name → skip
                ["id": "2", "name": "Valid"]
            ]
        ]
        let habits = WatchConnectivityProvider.parseHabits(data)
        #expect(habits.count == 1)
        #expect(habits.first?.name == "Valid")
        #expect(habits.first?.streak == 0)         // default saat streakCount tidak ada
    }

    // MARK: Edge
    @Test("parse mengembalikan kosong jika key tidak ada")
    func parseEmptyWhenMissingKey() {
        #expect(WatchConnectivityProvider.parseTimeBlocks([:]).isEmpty)
        #expect(WatchConnectivityProvider.parseHabits([:]).isEmpty)
    }
}
