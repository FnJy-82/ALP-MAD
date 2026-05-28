//
//  HabitModelTests.swift
//  ALP MADTests
//
//  Created by Emma Puspa Sari on 28/05/26.
//

import Testing
import Foundation
@testable import ALP_MAD

@Suite("Habit Model Tests")
struct HabitModelTests {

    @Test("isValid true untuk nama yang benar")
    func validHabit() {
        let habit = Habit(name: "Olahraga", colorHex: "#FF0000")
        #expect(habit.isValid == true)
    }

    @Test("isValid false untuk nama kosong")
    func emptyName() {
        let habit = Habit(name: "", colorHex: "#FF0000")
        #expect(habit.isValid == false)
    }

    @Test("isValid false untuk nama spasi")
    func whitespaceName() {
        let habit = Habit(name: "   ", colorHex: "#FF0000")
        #expect(habit.isValid == false)
    }

    @Test("streakCount default adalah 0")
    func defaultStreak() {
        let habit = Habit(name: "Meditasi", colorHex: "#00FF00")
        #expect(habit.streakCount == 0)
    }

    @Test("id unik untuk setiap habit")
    func uniqueIds() {
        let a = Habit(name: "A", colorHex: "#000000")
        let b = Habit(name: "B", colorHex: "#FFFFFF")
        #expect(a.id != b.id)
    }
}
