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

    private func makeViewModel(
        notificationService: NotificationScheduling? = nil
    ) throws -> SchedulerViewModel {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: TimeBlockModel.self, InterestModel.self, TaskModel.self,
                HabitModel.self, HabitLogModel.self, PomodoroSessionModel.self,
            configurations: config
        )
        let context = ModelContext(container)
        if let notificationService {
            return SchedulerViewModel(modelContext: context, notificationService: notificationService)
        }
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

    // Tanggal tetap supaya test deterministik (tidak bergantung waktu run).
    private func fixedDate(day: Int, hour: Int, minute: Int = 0) -> Date {
        var c = DateComponents()
        c.year = 2026
        c.month = 6
        c.day = day
        c.hour = hour
        c.minute = minute
        return Calendar.current.date(from: c)!
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

    //Fetch Tests
    @Test("fetchBlocks hanya mengambil blok pada hari yang diminta")
    func fetchBlocksFiltersByDay() throws {
        let vm = try makeViewModel()
        let day1 = fixedDate(day: 10, hour: 9)
        let day2 = fixedDate(day: 11, hour: 9)
        vm.addBlock(makeBlock(title: "Hari 1", start: day1))
        vm.addBlock(makeBlock(title: "Hari 2", start: day2))

        vm.fetchBlocks(for: day1)
        #expect(vm.timeBlocks.count == 1)
        #expect(vm.timeBlocks.first?.title == "Hari 1")
    }

    @Test("fetchBlocks mengurutkan blok berdasarkan startTime")
    func fetchBlocksSortedByStart() throws {
        let vm = try makeViewModel()
        let later = fixedDate(day: 10, hour: 15)
        let earlier = fixedDate(day: 10, hour: 8)
        vm.addBlock(makeBlock(title: "Siang", start: later))
        vm.addBlock(makeBlock(title: "Pagi", start: earlier))

        vm.fetchBlocks(for: fixedDate(day: 10, hour: 12))
        #expect(vm.timeBlocks.map(\.title) == ["Pagi", "Siang"])
    }

    //Conflict Boundary Tests
    @Test("Blok back-to-back (mulai = selesai blok sebelumnya) tidak dianggap bentrok")
    func adjacentBlocksDoNotConflict() throws {
        let vm = try makeViewModel()
        let start = fixedDate(day: 10, hour: 9)
        vm.addBlock(makeBlock(title: "Pertama", start: start, durationMinutes: 60))
        let next = makeBlock(title: "Kedua", start: start.addingTimeInterval(3600), durationMinutes: 60)
        vm.addBlock(next)
        #expect(vm.errorMessage == nil)
    }

    @Test("Beberapa blok tidak bentrok di hari yang sama semuanya tersimpan")
    func multipleNonConflictingBlocks() throws {
        let vm = try makeViewModel()
        let base = fixedDate(day: 10, hour: 8)
        vm.addBlock(makeBlock(title: "A", start: base, durationMinutes: 60))
        vm.addBlock(makeBlock(title: "B", start: base.addingTimeInterval(2 * 3600), durationMinutes: 60))
        vm.addBlock(makeBlock(title: "C", start: base.addingTimeInterval(4 * 3600), durationMinutes: 60))

        vm.fetchBlocks(for: base)
        #expect(vm.timeBlocks.count == 3)
    }

    //Delete Edge Tests
    @Test("Hapus blok dengan id tidak dikenal tidak mengubah apa pun")
    func deleteUnknownIdIsNoOp() throws {
        let vm = try makeViewModel()
        let start = fixedDate(day: 10, hour: 9)
        vm.addBlock(makeBlock(start: start))
        vm.fetchBlocks(for: start)
        let countBefore = vm.timeBlocks.count

        vm.deleteBlock(id: UUID())
        #expect(vm.timeBlocks.count == countBefore)
        #expect(vm.errorMessage == nil)
    }

    //Update Move-Day Tests
    @Test("Update memindahkan blok ke hari lain ter-fetch dengan benar")
    func updateMovesBlockToAnotherDay() throws {
        let vm = try makeViewModel()
        let day1 = fixedDate(day: 10, hour: 9)
        let block = makeBlock(start: day1, durationMinutes: 60)
        vm.addBlock(block)

        let day2 = fixedDate(day: 12, hour: 9)
        block.startTime = day2
        block.endTime = day2.addingTimeInterval(3600)
        vm.updateBlock(block)
        #expect(vm.errorMessage == nil)

        vm.fetchBlocks(for: day1)
        #expect(vm.timeBlocks.isEmpty)
        vm.fetchBlocks(for: day2)
        #expect(vm.timeBlocks.count == 1)
    }

    //blocksForWeek Tests
    @Test("blocksForWeek mengembalikan blok dalam minggu yang sama")
    func blocksForWeekReturnsWithinWeek() throws {
        let vm = try makeViewModel()
        let day = fixedDate(day: 10, hour: 9)
        vm.addBlock(makeBlock(title: "Minggu ini", start: day))

        let result = vm.blocksForWeek(containing: day)
        #expect(result.contains { $0.title == "Minggu ini" })
    }

    @Test("blocksForWeek tidak menyertakan blok dari minggu lain")
    func blocksForWeekExcludesOtherWeeks() throws {
        let vm = try makeViewModel()
        let thisWeek = fixedDate(day: 10, hour: 9)
        let nextWeek = fixedDate(day: 20, hour: 9)
        vm.addBlock(makeBlock(title: "Ini", start: thisWeek))
        vm.addBlock(makeBlock(title: "Depan", start: nextWeek))

        let result = vm.blocksForWeek(containing: thisWeek)
        #expect(result.contains { $0.title == "Ini" })
        #expect(!result.contains { $0.title == "Depan" })
    }

    //DateHelper Extra Tests
    @Test("endOfDay mengembalikan 23:59:59")
    func endOfDayIsCorrect() {
        let date = fixedDate(day: 10, hour: 9)
        let end = DateHelper.endOfDay(date)
        let c = Calendar.current.dateComponents([.hour, .minute, .second], from: end)
        #expect(c.hour == 23)
        #expect(c.minute == 59)
        #expect(c.second == 59)
    }

    @Test("weekRange mencakup tanggal yang diberikan dan mulai di awal hari")
    func weekRangeContainsDate() {
        let date = fixedDate(day: 10, hour: 14)
        let range = DateHelper.weekRange(containing: date)
        #expect(range.start <= date)
        #expect(date <= range.end)
        let startComps = Calendar.current.dateComponents([.hour], from: range.start)
        #expect(startComps.hour == 0)
    }

    @Test("formattedTime memformat jam:menit dua digit")
    func formattedTimeIsCorrect() {
        let date = fixedDate(day: 10, hour: 9, minute: 5)
        #expect(DateHelper.formattedTime(date) == "09:05")
    }

    @Test("formattedDate memuat tanggal dan tahun")
    func formattedDateIsCorrect() {
        let date = fixedDate(day: 10, hour: 9)
        let result = DateHelper.formattedDate(date)
        #expect(result.contains("10"))
        #expect(result.contains("2026"))
    }

    @Test("weekRange selesai setelah mulai dengan rentang sekitar satu minggu")
    func weekRangeSpansOneWeek() {
        let date = fixedDate(day: 10, hour: 9)
        let range = DateHelper.weekRange(containing: date)
        #expect(range.end > range.start)
        let days = range.end.timeIntervalSince(range.start) / 86_400
        #expect(days > 6.9 && days < 7.0)
    }

    //TimeBlock Model Happy-Path Tests
    @Test("isValid true untuk blok dengan judul dan waktu benar")
    func blockIsValidWhenCorrect() {
        let block = makeBlock(title: "Olahraga", durationMinutes: 30)
        #expect(block.isValid == true)
    }

    @Test("isValid false jika judul hanya berisi spasi")
    func blockIsInvalidWithWhitespaceTitle() {
        let block = makeBlock(title: "   ")
        #expect(block.isValid == false)
    }

    //Notification Tests (pakai mock, tidak menyentuh UNUserNotificationCenter asli)
    @Test("Notifikasi dijadwalkan saat notifyOnStart true")
    func notificationScheduledWhenEnabled() throws {
        let spy = SpyNotificationService()
        let vm = try makeViewModel(notificationService: spy)
        let block = makeBlock(start: fixedDate(day: 10, hour: 9))
        block.notifyOnStart = true
        vm.addBlock(block)
        #expect(spy.scheduledIds.contains(block.id))
    }

    @Test("Notifikasi tidak dijadwalkan saat notifyOnStart false")
    func notificationNotScheduledWhenDisabled() throws {
        let spy = SpyNotificationService()
        let vm = try makeViewModel(notificationService: spy)
        let block = makeBlock(start: fixedDate(day: 10, hour: 9))
        block.notifyOnStart = false
        vm.addBlock(block)
        #expect(spy.scheduledIds.isEmpty)
    }

    @Test("Hapus blok membatalkan notifikasinya")
    func deleteCancelsNotification() throws {
        let spy = SpyNotificationService()
        let vm = try makeViewModel(notificationService: spy)
        let start = fixedDate(day: 10, hour: 9)
        let block = makeBlock(start: start)
        vm.addBlock(block)
        vm.fetchBlocks(for: start)
        vm.deleteBlock(id: block.id)
        #expect(spy.cancelledIds.contains(block.id))
    }

    @Test("Update dengan notifyOnStart false tidak menjadwalkan ulang notifikasi")
    func updateWithNotifyDisabledDoesNotReschedule() throws {
        let spy = SpyNotificationService()
        let vm = try makeViewModel(notificationService: spy)
        let start = fixedDate(day: 10, hour: 9)
        let block = makeBlock(start: start)
        block.notifyOnStart = true
        vm.addBlock(block)   // terjadwal 1x

        block.notifyOnStart = false
        block.title = "Tanpa notif"
        vm.updateBlock(block)

        #expect(spy.cancelledIds.contains(block.id))                       // update selalu cancel dulu
        #expect(spy.scheduledIds.filter { $0 == block.id }.count == 1)     // tidak ada penjadwalan kedua
    }
}

// Mock untuk memverifikasi pemanggilan notifikasi tanpa efek samping nyata.
@MainActor
private final class SpyNotificationService: NotificationScheduling {
    var scheduledIds: [UUID] = []
    var cancelledIds: [UUID] = []

    func scheduleNotification(for block: TimeBlockModel) {
        scheduledIds.append(block.id)
    }

    func cancelNotification(id: UUID) {
        cancelledIds.append(id)
    }
}


