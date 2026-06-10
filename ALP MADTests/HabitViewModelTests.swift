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

    //Streak Accuracy Tests
    @Test("Streak menghitung hari berturut-turut")
    func streakCountsConsecutiveDays() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "Lari", colorHex: "#FF0000")
        vm.fetchHabits()
        let habit = try #require(vm.habits.first)

        let today = Date.now
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        vm.markComplete(habit: habit, on: yesterday)
        vm.markComplete(habit: habit, on: today)
        vm.fetchHabits()

        #expect(vm.habits.first?.streakCount == 2)
    }

    @Test("Streak 0 jika hari ini belum complete meski hari lalu pernah")
    func streakZeroIfTodayNotDone() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "Lari", colorHex: "#FF0000")
        vm.fetchHabits()
        let habit = try #require(vm.habits.first)

        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: .now)!
        vm.markComplete(habit: habit, on: twoDaysAgo)
        vm.fetchHabits()

        #expect(vm.habits.first?.streakCount == 0)   // streak putus karena hari ini belum
    }

    @Test("Streak kembali 0 setelah un-complete hari ini")
    func streakResetsAfterUncomplete() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "Lari", colorHex: "#FF0000")
        vm.fetchHabits()
        let habit = try #require(vm.habits.first)

        let today = Date.now
        vm.markComplete(habit: habit, on: today)   // streak 1
        vm.markComplete(habit: habit, on: today)   // toggle off → streak 0
        vm.fetchHabits()

        #expect(vm.habits.first?.streakCount == 0)
    }

    @Test("markComplete tidak membuat log ganda untuk hari yang sama")
    func markCompleteNoDuplicateLog() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "Membaca", colorHex: "#00FF00")
        vm.fetchHabits()
        let habit = try #require(vm.habits.first)

        let today = Date.now
        vm.markComplete(habit: habit, on: today)
        vm.markComplete(habit: habit, on: today)   // tanpa fetchLogs manual di antara
        vm.fetchLogs(for: today)

        #expect(vm.logs.count == 1)
    }

    @Test("Nama habit di-trim sebelum disimpan")
    func addHabitTrimsName() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "  Meditasi  ", colorHex: "#00FF00")
        vm.fetchHabits()

        #expect(vm.habits.first?.name == "Meditasi")
    }

    @Test("currentStreak: kemarin & lusa selesai, hari ini belum → tetap 2 (tenggang hari ini)")
    func currentStreakGraceForToday() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "Lari", colorHex: "#FF0000")
        vm.fetchHabits()
        let habit = try #require(vm.habits.first)

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        let dayBefore = Calendar.current.date(byAdding: .day, value: -2, to: .now)!
        vm.markCompleted(habit: habit, on: dayBefore)
        vm.markCompleted(habit: habit, on: yesterday)
        // hari ini sengaja TIDAK dicentang

        vm.fetchHabits()
        #expect(vm.habits.first?.currentStreak == 2)   // tenggang: hari ini belum tidak memutus
    }

    @Test("currentStreak 0 jika tidak ada hari yang selesai")
    func currentStreakZeroWhenNoLogs() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "Lari", colorHex: "#FF0000")
        vm.fetchHabits()
        let habit = try #require(vm.habits.first)

        #expect(habit.currentStreak == 0)
    }

    @Test("markCompleted idempoten — beberapa sesi Pomodoro tidak meng-uncheck habit")
    func markCompletedIsIdempotent() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = HabitViewModel(modelContext: context)

        vm.addHabit(name: "Belajar", colorHex: "#0000FF")
        vm.fetchHabits()
        let habit = try #require(vm.habits.first)

        let today = Date.now
        vm.markCompleted(habit: habit, on: today)
        vm.markCompleted(habit: habit, on: today)   // sesi Pomodoro kedua di hari sama
        vm.fetchLogs(for: today)

        #expect(vm.isCompleted(habit: habit, on: today) == true)   // tetap selesai
        #expect(vm.logs.count == 1)                                 // tidak ada log ganda
        #expect(vm.habits.first?.streakCount == 1)                  // streak tidak rusak
    }
}
