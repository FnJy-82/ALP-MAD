//
//  SchedulerViewModel.swift
//  ALP MAD
//
//  Created by student on 28/05/26.
//
import Foundation
import SwiftData
import Observation
import WatchConnectivity

@MainActor
@Observable
final class SchedulerViewModel {
    //Dependencies
    private let notificationService: NotificationService
    private let modelContext: ModelContext
    //State
    var timeBlocks: [TimeBlockModel] = []
    var selectedDate: Date = .now
    var errorMessage: String?
    init(
        modelContext: ModelContext,
        notificationService: NotificationService = .shared
    ) {
        self.modelContext = modelContext
        self.notificationService = notificationService
    }
    //Fetch
    func fetchBlocks(for date: Date) {
        let startOfDay = DateHelper.startOfDay(date)
        let endOfDay = DateHelper.endOfDay(date)
        let predicate = #Predicate<TimeBlockModel> { block in
            block.startTime >= startOfDay && block.startTime <= endOfDay
        }
        let descriptor = FetchDescriptor<TimeBlockModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startTime)]
        )
        do {
            timeBlocks = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Gagal memuat jadwal: \(error.localizedDescription)"
        }
    }
    
    //Add
    func addBlock(_ block: TimeBlockModel) {
        guard block.isValid else {
            errorMessage = "Jadwal tidak valid."
            return
        }

        // ← fetch dulu untuk hari yang sama dengan block baru
        fetchBlocks(for: block.startTime)

        guard !hasConflict(with: block) else {
            errorMessage = "Jadwal bentrok dengan blok waktu lain."
            return
        }

        modelContext.insert(block)
        save()
        fetchBlocks(for: block.startTime)  // ← fetch by startTime block, bukan selectedDate
        notificationService.scheduleNotification(for: block)
        WatchConnectivityService.shared.sendTimeBlocks(timeBlocks)
    }

    //Delete
    func deleteBlock(id: UUID) {
        guard let block = timeBlocks.first(where: { $0.id == id }) else { return }
        notificationService.cancelNotification(id: id)
        modelContext.delete(block)
        save()
        if WCSession.isSupported() {
            WatchConnectivityService.shared.sendTimeBlocks(timeBlocks)
        }
        fetchBlocks(for: selectedDate)
    }
    //Update
    func updateBlock(_ updated: TimeBlockModel) {
        guard updated.isValid else {
            errorMessage = "Jadwal tidak valid."
            return
        }
        notificationService.cancelNotification(id: updated.id)
        save()
        fetchBlocks(for: selectedDate)
        notificationService.scheduleNotification(for: updated)
    }
    
    //Helpers
    func blocksForWeek(containing date: Date) -> [TimeBlockModel] {
        let range = DateHelper.weekRange(containing: date)
        let rangeStart = range.start
        let rangeEnd = range.end

        let predicate = #Predicate<TimeBlockModel> { block in
            block.startTime >= rangeStart && block.startTime <= rangeEnd
        }
        let descriptor = FetchDescriptor<TimeBlockModel>(predicate: predicate)
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    private func hasConflict(with newBlock: TimeBlockModel, excluding id: UUID? = nil) -> Bool {
        timeBlocks
            .filter { $0.id != id }
            .contains { existing in
                newBlock.startTime < existing.endTime &&
                newBlock.endTime > existing.startTime
            }
    }
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Gagal menyimpan: \(error.localizedDescription)"
        }
    }
}


