//
//  HabitViewModel.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 28/05/26.
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class HabitViewModel {

    private let modelContext: ModelContext
    private let notificationService: NotificationService

    var habits: [HabitModel] = []
    var logs: [HabitLogModel] = []
    var errorMessage: String?

    init(
        modelContext: ModelContext,
        notificationService: NotificationService = .shared
    ) {
        self.modelContext = modelContext
        self.notificationService = notificationService
    }

    func fetchHabits() {
        let descriptor = FetchDescriptor<HabitModel>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        do {
            habits = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Gagal memuat habit: \(error.localizedDescription)"
        }
    }

    func addHabit(name: String, colorHex: String) {
        let habit = HabitModel(name: name, colorHex: colorHex)
        guard habit.isValid else {
            errorMessage = "Nama habit tidak boleh kosong."
            return
        }
        modelContext.insert(habit)
        save()
        fetchHabits()
    }

    func deleteHabit(_ habit: HabitModel) {
        modelContext.delete(habit)
        save()
        fetchHabits()
    }

    func fetchLogs(for date: Date) {
        let start = DateHelper.startOfDay(date)
        let end = DateHelper.endOfDay(date)
        let predicate = #Predicate<HabitLogModel> { log in
            log.date >= start && log.date <= end
        }
        let descriptor = FetchDescriptor<HabitLogModel>(predicate: predicate)
        do {
            logs = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Gagal memuat log: \(error.localizedDescription)"
        }
    }

    func markComplete(habit: HabitModel, on date: Date = .now) {
        let start = DateHelper.startOfDay(date)
        let end = DateHelper.endOfDay(date)
        let habitId = habit.id

        let existing = logs.first {
            guard let logHabit = $0.habit else { return false }
            return logHabit.id == habitId &&
                   $0.date >= start &&
                   $0.date <= end
        }

        if let existing {
            existing.isCompleted.toggle()
            if !existing.isCompleted {
                recalculateStreak(for: habit)
            } else {
                updateStreak(for: habit)
            }
        } else {
            let log = HabitLogModel(date: date, isCompleted: true, habit: habit)
            modelContext.insert(log)
            updateStreak(for: habit)
        }

        save()
        fetchLogs(for: date)
        fetchHabits()
    }

    func isCompleted(habit: HabitModel, on date: Date = .now) -> Bool {
        let start = DateHelper.startOfDay(date)
        let end = DateHelper.endOfDay(date)
        return logs.contains {
            guard let logHabit = $0.habit else { return false }
            return logHabit.id == habit.id &&
                   $0.date >= start &&
                   $0.date <= end &&
                   $0.isCompleted
        }
    }

    private func updateStreak(for habit: HabitModel) {
        habit.streakCount += 1
    }

    private func recalculateStreak(for habit: HabitModel) {
        let habitId = habit.id
        let predicate = #Predicate<HabitLogModel> { log in
            log.habit?.id == habitId && log.isCompleted == true
        }
        let descriptor = FetchDescriptor<HabitLogModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        guard let allLogs = try? modelContext.fetch(descriptor) else { return }

        var streak = 0
        var checkDate = DateHelper.startOfDay(.now)

        for log in allLogs {
            let logDay = DateHelper.startOfDay(log.date)
            if logDay == checkDate {
                streak += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        habit.streakCount = streak
    }

    func syncToWatch() {
        WatchConnectivityService.shared.sendHabits(habits)
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Gagal menyimpan: \(error.localizedDescription)"
        }
    }
}
