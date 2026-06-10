//
//  SchedulerViewModelTests.swift
//  ALP MADTests
//
//  Created by student on 28/05/26.
//

import Foundation
import Testing
import SwiftData
@testable import ALP_MAD

@Suite("SchedulerViewModel Tests", .serialized)
@MainActor
struct SchedulerViewModelTests {

    private func makeViewModel() throws -> SchedulerViewModel {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: TimeBlockModel.self, InterestModel.self, TaskModel.self,
                HabitModel.self, HabitLogModel.self, PomodoroSessionModel.self,
            configurations: config
        )
        let context = ModelContext(container)
        return SchedulerViewModel(modelContext: context)
    }

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

    //Add Tests
    @Test("Tambah blok valid berhasil")
    func addValidBlock() throws {
        let vm = try makeViewModel()
        let block = makeBlock()
        vm.addBlock(block)
        #expect(vm.errorMessage == nil)
    }

    @Test("Tambah blok dengan judul kosong gagal")
    func addBlockWithEmptyTitle() throws {
        let vm = try makeViewModel()
        let block = makeBlock(title: "   ")
        vm.addBlock(block)
        #expect(vm.errorMessage != nil)
    }

    @Test("Tambah blok dengan endTime sebelum startTime gagal")
    func addBlockWithInvalidTimeRange() throws {
        let vm = try makeViewModel()
        let now = Date.now
        let block = TimeBlockModel(
            title: "Invalid",
            startTime: now,
            endTime: now.addingTimeInterval(-60),
            interestId: UUID()
        )
        vm.addBlock(block)
        #expect(vm.errorMessage != nil)
    }

    //Conflict Tests
    @Test("Blok yang bentrok ditolak")
    func conflictingBlockRejected() throws {
        let vm = try makeViewModel()
        let now = Date.now
        vm.selectedDate = now
        let first = makeBlock(start: now, durationMinutes: 60)
        vm.addBlock(first)
        vm.fetchBlocks(for: now)
        let overlapping = makeBlock(title: "Bentrok", start: now.addingTimeInterval(1800), durationMinutes: 60)
        vm.addBlock(overlapping)
        #expect(vm.errorMessage != nil)
    }

    //Delete Tests
    @Test("Hapus blok yang ada berhasil")
    func deleteExistingBlock() throws {
        let vm = try makeViewModel()
        let now = Date.now
        vm.selectedDate = now
        let block = makeBlock(start: now)
        vm.addBlock(block)
        vm.fetchBlocks(for: now)
        vm.deleteBlock(id: block.id)
        vm.fetchBlocks(for: now)
        #expect(vm.timeBlocks.isEmpty)
    }

    //Update Tests
    @Test("Update blok valid berhasil dan perubahan tersimpan")
    func updateValidBlock() throws {
        let vm = try makeViewModel()
        let now = Date.now
        vm.selectedDate = now
        let block = makeBlock(start: now, durationMinutes: 60)
        vm.addBlock(block)

        block.title = "Judul Baru"
        vm.updateBlock(block)
        #expect(vm.errorMessage == nil)

        vm.fetchBlocks(for: now)
        #expect(vm.timeBlocks.first?.title == "Judul Baru")
    }

    @Test("Update blok jadi tidak valid (endTime <= startTime) ditolak")
    func updateInvalidBlockRejected() throws {
        let vm = try makeViewModel()
        let now = Date.now
        vm.selectedDate = now
        let block = makeBlock(start: now, durationMinutes: 60)
        vm.addBlock(block)

        block.endTime = block.startTime
        vm.updateBlock(block)
        #expect(vm.errorMessage != nil)
    }

    @Test("Update blok jadi bentrok dengan blok lain ditolak")
    func updateConflictingBlockRejected() throws {
        let vm = try makeViewModel()
        let now = Date.now
        vm.selectedDate = now

        let first = makeBlock(title: "Pertama", start: now, durationMinutes: 60)
        vm.addBlock(first)

        // blok kedua 2 jam setelah blok pertama (belum bentrok)
        let second = makeBlock(title: "Kedua", start: now.addingTimeInterval(2 * 3600), durationMinutes: 60)
        vm.addBlock(second)
        #expect(vm.errorMessage == nil)

        // geser blok kedua mundur supaya overlap dengan blok pertama
        second.startTime = now.addingTimeInterval(30 * 60)
        second.endTime = now.addingTimeInterval(90 * 60)
        vm.updateBlock(second)
        #expect(vm.errorMessage != nil)
    }

    //DateHelper Tests
    @Test("startOfDay mengembalikan jam 00:00")
    func startOfDayIsCorrect() {
        let date = Date.now
        let start = DateHelper.startOfDay(date)
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: start)
        #expect(components.hour == 0)
        #expect(components.minute == 0)
        #expect(components.second == 0)
    }

    @Test("isSameDay benar untuk tanggal yang sama")
    func isSameDayCorrect() {
        let a = Date.now
        let b = a.addingTimeInterval(3600)
        #expect(DateHelper.isSameDay(a, b) == true)
    }

    @Test("isSameDay salah untuk tanggal berbeda")
    func isSameDayWrongForDifferentDays() {
        let a = Date.now
        let b = Calendar.current.date(byAdding: .day, value: 2, to: a)!
        #expect(DateHelper.isSameDay(a, b) == false)
    }

    //TimeBlock Model Tests
    @Test("duration terhitung dengan benar")
    func blockDurationIsCorrect() {
        let block = makeBlock(durationMinutes: 90)
        #expect(block.duration == 90 * 60)
    }

    @Test("isValid false jika judul kosong")
    func blockIsInvalidWithEmptyTitle() {
        let block = makeBlock(title: "")
        #expect(block.isValid == false)
    }

    @Test("isValid false jika endTime <= startTime")
    func blockIsInvalidWithWrongTimeOrder() {
        let now = Date.now
        let block = TimeBlockModel(
            title: "Test",
            startTime: now,
            endTime: now,
            interestId: UUID()
        )
        #expect(block.isValid == false)
    }
}


