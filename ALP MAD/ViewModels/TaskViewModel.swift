import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class TaskViewModel {

    //Dependencies
    private let modelContext: ModelContext

    //State
    var interests: [InterestModel] = []
    var tasks: [TaskModel] = []
    var selectedInterest: InterestModel?
    var errorMessage: String?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    //Interest CRUD
    func fetchInterests() {
        let descriptor = FetchDescriptor<InterestModel>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        do {
            interests = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Gagal memuat kategori: \(error.localizedDescription)"
        }
    }

    func addInterest(name: String, colorHex: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            errorMessage = "Nama kategori tidak boleh kosong."
            return
        }
        guard !isDuplicateInterest(name: trimmedName) else {
            errorMessage = "Kategori dengan nama ini sudah ada."
            return
        }
        let interest = InterestModel(name: trimmedName, colorHex: colorHex)
        modelContext.insert(interest)
        save()
        fetchInterests()
    }

    func updateInterest(_ interest: InterestModel, name: String, colorHex: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            errorMessage = "Nama kategori tidak boleh kosong."
            return
        }
        // izinkan nama sama dengan dirinya sendiri (excluding), tolak jika bentrok kategori lain
        guard !isDuplicateInterest(name: trimmedName, excluding: interest.id) else {
            errorMessage = "Kategori dengan nama ini sudah ada."
            return
        }
        interest.name = trimmedName
        interest.colorHex = colorHex
        save()
        fetchInterests()
    }

    func deleteInterest(_ interest: InterestModel) {
        modelContext.delete(interest)
        if selectedInterest?.id == interest.id {
            selectedInterest = nil
        }
        save()
        fetchInterests()
        fetchTasks(for: selectedInterest)
    }

    //Task CRUD
    func fetchTasks(for interest: InterestModel?) {
        if let interest {
            let id = interest.id
            let predicate = #Predicate<TaskModel> { task in
                task.interest?.id == id
            }
            let descriptor = FetchDescriptor<TaskModel>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.createdAt)]
            )
            do {
                tasks = try modelContext.fetch(descriptor)
            } catch {
                errorMessage = "Gagal memuat tugas: \(error.localizedDescription)"
            }
        } else {
            fetchAllTasks()
        }
    }

    func addTask(title: String, priority: Priority, deadline: Date?, to interest: InterestModel?) {
        let task = TaskModel(
            title: title,
            priority: priority,
            deadline: deadline,
            interest: interest
        )
        guard task.isValid else {
            errorMessage = "Judul tugas tidak boleh kosong."
            return
        }

        modelContext.insert(task)
        save()
        fetchTasks(for: selectedInterest)
    }

    func updateTask(_ task: TaskModel) {
        // task adalah objek @Model yang sudah dimutasi oleh editor; cukup validasi + simpan.
        guard task.isValid else {
            errorMessage = "Judul tugas tidak boleh kosong."
            return
        }
        save()
        fetchTasks(for: selectedInterest)
    }

    func toggleDone(_ task: TaskModel) {
        task.isDone.toggle()
        save()
        fetchTasks(for: selectedInterest)
    }

    func deleteTask(_ task: TaskModel) {
        modelContext.delete(task)
        save()
        fetchTasks(for: selectedInterest)
    }

    func selectInterest(_ interest: InterestModel?) {
        selectedInterest = interest
        fetchTasks(for: interest)
    }

    //Helpers
    var pendingTasks: [TaskModel] {
        tasks.filter { !$0.isDone }
    }

    var completedTasks: [TaskModel] {
        tasks.filter { $0.isDone }
    }

    var overdueTasks: [TaskModel] {
        tasks.filter { $0.isOverdue }
    }

    private func fetchAllTasks() {
        let descriptor = FetchDescriptor<TaskModel>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        do {
            tasks = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Gagal memuat semua tugas: \(error.localizedDescription)"
        }
    }

    private func isDuplicateInterest(name: String, excluding id: UUID? = nil) -> Bool {
        let target = name.lowercased().trimmingCharacters(in: .whitespaces)
        return interests.contains { $0.id != id && $0.name.lowercased() == target }
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Gagal menyimpan: \(error.localizedDescription)"
        }
    }
}

