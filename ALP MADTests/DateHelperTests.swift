//
//  DateHelperTests.swift
//  ALP MADTests
//
//  Created by student on 28/05/26.
//

import Testing
import Foundation
@testable import ALP_MAD

@Suite("DateHelper Tests")
struct DateHelperTests {

    @Test("startOfDay mengembalikan jam 00:00:00")
    func startOfDay() {
        let date = Date.now
        let start = DateHelper.startOfDay(date)
        let components = Calendar.current.dateComponents(
            [.hour, .minute, .second],
            from: start
        )
        #expect(components.hour == 0)
        #expect(components.minute == 0)
        #expect(components.second == 0)
    }

    @Test("endOfDay mengembalikan jam 23:59:59")
    func endOfDay() {
        let date = Date.now
        let end = DateHelper.endOfDay(date)
        let components = Calendar.current.dateComponents(
            [.hour, .minute, .second],
            from: end
        )
        #expect(components.hour == 23)
        #expect(components.minute == 59)
        #expect(components.second == 59)
    }

    @Test("isSameDay true untuk waktu berbeda di hari sama")
    func sameDayDifferentTime() {
        let a = Date.now
        let b = a.addingTimeInterval(3600)
        #expect(DateHelper.isSameDay(a, b) == true)
    }

    @Test("isSameDay false untuk hari berbeda")
    func differentDay() {
        let a = Date.now
        let b = a.addingTimeInterval(86400 * 2)
        #expect(DateHelper.isSameDay(a, b) == false)
    }

    @Test("weekRange start lebih awal dari end")
    func weekRangeStartBeforeEnd() {
        let range = DateHelper.weekRange(containing: .now)
        #expect(range.start < range.end)
    }

    @Test("weekRange mengandung tanggal yang diberikan")
    func weekRangeContainsDate() {
        let date = Date.now
        let range = DateHelper.weekRange(containing: date)
        #expect(date >= range.start && date <= range.end)
    }

    @Test("formattedTime mengembalikan format HH:mm")
    func formattedTime() {
        var components = DateComponents()
        components.hour = 9
        components.minute = 5
        let date = Calendar.current.date(from: components)!
        #expect(DateHelper.formattedTime(date) == "09:05")
    }
}


