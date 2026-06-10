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
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            errorMessage = "Nama habit tidak boleh kosong."
            return
        }
        let habit = HabitModel(name: trimmed, colorHex: colorHex)
        modelContext.insert(habit)
        save()
        fetchHabits()
        syncToWatch()
    }

    func deleteHabit(_ habit: HabitModel) {
        guard habit.modelContext != nil else {
            errorMessage = "Habit tidak ditemukan."
            return
        }
        modelContext.delete(habit)
        save()
        fetchHabits()
        syncToWatch()
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
        // refresh logs untuk tanggal ini dulu supaya cek "existing" tidak memakai state stale
        // (mencegah log ganda untuk hari yang sama).
        fetchLogs(for: date)

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
        } else {
            let log = HabitLogModel(date: date, isCompleted: true, habit: habit)
            modelContext.insert(log)
        }

        // simpan dulu supaya recalculate membaca log terbaru dari context,
        // lalu hitung ulang streak hari berturut-turut (akurat untuk complete & un-complete).
        save()
        recalculateStreak(for: habit)
        save()

        fetchLogs(for: date)
        fetchHabits()
        syncToWatch()
    }

    /// Tandai habit SELESAI untuk tanggal tsb tanpa toggle (idempoten).
    /// Dipakai saat sesi Pomodoro selesai — menyelesaikan beberapa sesi di hari
    /// yang sama tidak boleh malah meng-uncheck habit (beda dengan markComplete).
    func markCompleted(habit: HabitModel, on date: Date = .now) {
        fetchLogs(for: date)

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
            existing.isCompleted = true
        } else {
            let log = HabitLogModel(date: date, isCompleted: true, habit: habit)
            modelContext.insert(log)
        }

        save()
        recalculateStreak(for: habit)
        save()

        fetchLogs(for: date)
        fetchHabits()
        syncToWatch()
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

    // Sinkronkan nilai tersimpan (dipakai WatchConnectivity) dengan streak turunan dari logs.
    private func recalculateStreak(for habit: HabitModel) {
        habit.streakCount = habit.currentStreak
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
    
    func updateHabit(_ habit: HabitModel, name: String, colorHex: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Nama habit tidak boleh kosong."
            return
        }
        habit.name = name
        habit.colorHex = colorHex
        save()
        fetchHabits()
        syncToWatch()
    }
}
