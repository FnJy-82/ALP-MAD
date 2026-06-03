import Testing
import Foundation
import SwiftData
@testable import ALP_MAD

@Suite("TaskViewModel Tests")
@MainActor
struct TaskViewModelTests {

    private func makeViewModel() throws -> TaskViewModel {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: InterestModel.self, TaskModel.self,
            configurations: config
        )
        return TaskViewModel(modelContext: container.mainContext)
    }

    //Interest Tests
    @Test("Tambah interest valid berhasil")
    func addValidInterest() throws {
        let vm = try makeViewModel()
        vm.addInterest(name: "Gaming", colorHex: "#FF0000")
        vm.fetchInterests()
        #expect(vm.interests.count == 1)
        #expect(vm.errorMessage == nil)
    }

    @Test("Tambah interest nama kosong menghasilkan error")
    func addEmptyInterest() throws {
        let vm = try makeViewModel()
        vm.addInterest(name: "", colorHex: "#FF0000")
        #expect(vm.errorMessage != nil)
    }

    @Test("Tambah interest duplikat menghasilkan error")
    func addDuplicateInterest() throws {
        let vm = try makeViewModel()
        vm.addInterest(name: "Gaming", colorHex: "#FF0000")
        vm.fetchInterests()
        vm.errorMessage = nil

        vm.addInterest(name: "Gaming", colorHex: "#00FF00")
        #expect(vm.errorMessage != nil)
    }

    @Test("Duplikat case-insensitive ditolak")
    func addDuplicateCaseInsensitive() throws {
        let vm = try makeViewModel()
        vm.addInterest(name: "gaming", colorHex: "#FF0000")
        vm.fetchInterests()
        vm.errorMessage = nil

        vm.addInterest(name: "GAMING", colorHex: "#00FF00")
        #expect(vm.errorMessage != nil)
    }

    @Test("Hapus interest berhasil")
    func deleteInterest() throws {
        let vm = try makeViewModel()
        vm.addInterest(name: "Music", colorHex: "#0000FF")
        vm.fetchInterests()

        let interest = try #require(vm.interests.first)
        vm.deleteInterest(interest)
        #expect(vm.interests.isEmpty)
    }

    @Test("Hapus interest yang sedang dipilih reset selectedInterest")
    func deleteSelectedInterest() throws {
        let vm = try makeViewModel()
        vm.addInterest(name: "Music", colorHex: "#0000FF")
        vm.fetchInterests()

        let interest = try #require(vm.interests.first)
        vm.selectInterest(interest)
        vm.deleteInterest(interest)

        #expect(vm.selectedInterest == nil)
    }

    //Task Tests
    @Test("Tambah task valid berhasil")
    func addValidTask() throws {
        let vm = try makeViewModel()
        vm.addTask(title: "Latihan", priority: .high, deadline: nil, to: nil)
        vm.fetchTasks(for: nil)
        #expect(vm.tasks.count == 1)
        #expect(vm.errorMessage == nil)
    }

    @Test("Tambah task judul kosong menghasilkan error")
    func addEmptyTask() throws {
        let vm = try makeViewModel()
        vm.addTask(title: "", priority: .low, deadline: nil, to: nil)
        #expect(vm.errorMessage != nil)
    }

    @Test("Toggle done mengubah status task")
    func toggleDone() throws {
        let vm = try makeViewModel()
        vm.addTask(title: "Tugas", priority: .medium, deadline: nil, to: nil)
        vm.fetchTasks(for: nil)

        let task = try #require(vm.tasks.first)
        #expect(task.isDone == false)

        vm.toggleDone(task)
        #expect(task.isDone == true)

        vm.toggleDone(task)
        #expect(task.isDone == false)
    }

    @Test("Hapus task berhasil")
    func deleteTask() throws {
        let vm = try makeViewModel()
        vm.addTask(title: "Tugas", priority: .medium, deadline: nil, to: nil)
        vm.fetchTasks(for: nil)

        let task = try #require(vm.tasks.first)
        vm.deleteTask(task)
        vm.fetchTasks(for: nil)

        #expect(vm.tasks.isEmpty)
    }

    @Test("Filter task berdasarkan interest")
    func filterByInterest() throws {
        let vm = try makeViewModel()

        vm.addInterest(name: "Gaming", colorHex: "#FF0000")
        vm.addInterest(name: "Music", colorHex: "#00FF00")
        vm.fetchInterests()

        let gaming = try #require(vm.interests.first { $0.name == "Gaming" })
        let music = try #require(vm.interests.first { $0.name == "Music" })

        vm.addTask(title: "Main game", priority: .low, deadline: nil, to: gaming)
        vm.addTask(title: "Latihan gitar", priority: .medium, deadline: nil, to: music)

        vm.fetchTasks(for: gaming)
        #expect(vm.tasks.count == 1)
        #expect(vm.tasks.first?.title == "Main game")
    }

    @Test("pendingTasks hanya berisi task yang belum selesai")
    func pendingTasksFilter() throws {
        let vm = try makeViewModel()
        vm.addTask(title: "Tugas A", priority: .high, deadline: nil, to: nil)
        vm.addTask(title: "Tugas B", priority: .low, deadline: nil, to: nil)
        vm.fetchTasks(for: nil)

        let first = try #require(vm.tasks.first)
        vm.toggleDone(first)

        #expect(vm.pendingTasks.count == 1)
        #expect(vm.completedTasks.count == 1)
    }
}


