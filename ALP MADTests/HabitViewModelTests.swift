//
//  HabitViewModelTests.swift
//  ALP MADTests
//
//  Created by Emma Puspa Sari on 28/05/26.
//

import Testing
import Foundation
import SwiftData
@testable import ALP_MAD

@Suite("HabitViewModel Tests")
@MainActor
struct HabitViewModelTests {

    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: HabitModel.self, HabitLogModel.self,
            configurations: config
        )
    }

    @Test("Tambah habit valid berhasil")
    func addValidHabit() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "Test", colorHex: "#FF0000")
        vm.fetchHabits()

        #expect(vm.habits.count == 1)
        #expect(vm.errorMessage == nil)
    }

    @Test("Tambah habit nama kosong menghasilkan error")
    func addEmptyHabit() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "", colorHex: "#FF0000")
        #expect(vm.errorMessage != nil)
    }

    @Test("Hapus habit berhasil")
    func deleteHabit() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "Meditasi", colorHex: "#0000FF")
        vm.fetchHabits()

        let habit = try #require(vm.habits.first)
        vm.deleteHabit(habit)
        vm.fetchHabits()

        #expect(vm.habits.isEmpty)
    }

    @Test("markComplete membuat log baru")
    func markCompleteCreatesLog() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "Membaca", colorHex: "#00FF00")
        vm.fetchHabits()

        let habit = try #require(vm.habits.first)
        let today = Date.now
        vm.fetchLogs(for: today)

        vm.markComplete(habit: habit, on: today)
        vm.fetchLogs(for: today)

        #expect(vm.logs.count == 1)
        #expect(vm.isCompleted(habit: habit, on: today) == true)
    }

    @Test("markComplete dua kali toggle status")
    func markCompleteToggle() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "Membaca", colorHex: "#00FF00")
        vm.fetchHabits()

        let habit = try #require(vm.habits.first)
        let today = Date.now
        vm.fetchLogs(for: today)

        vm.markComplete(habit: habit, on: today)
        vm.fetchLogs(for: today)
        #expect(vm.isCompleted(habit: habit, on: today) == true)

        vm.markComplete(habit: habit, on: today)
        vm.fetchLogs(for: today)
        #expect(vm.isCompleted(habit: habit, on: today) == false)
    }

    @Test("streak bertambah setelah markComplete")
    func streakIncreasesAfterComplete() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "Olahraga", colorHex: "#FF0000")
        vm.fetchHabits()

        let habit = try #require(vm.habits.first)
        vm.fetchLogs(for: .now)
        vm.markComplete(habit: habit, on: .now)
        vm.fetchHabits()

        let updated = try #require(vm.habits.first)
        #expect(updated.streakCount == 1)
    }

    @Test("isCompleted false untuk habit yang belum di-complete")
    func isCompletedFalseForUntouched() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "Yoga", colorHex: "#FF00FF")
        vm.fetchHabits()

        let habit = try #require(vm.habits.first)
        vm.fetchLogs(for: .now)

        #expect(vm.isCompleted(habit: habit, on: .now) == false)
    }
}
