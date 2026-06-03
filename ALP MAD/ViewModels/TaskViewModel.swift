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
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Nama kategori tidak boleh kosong."
            return
        }
        guard !isDuplicateInterest(name: name) else {
            errorMessage = "Kategori dengan nama ini sudah ada."
            return
        }
        let interest = InterestModel(name: name, colorHex: colorHex)
        if interest.modelContext == nil {
            modelContext.insert(interest)
        }
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

    private func isDuplicateInterest(name: String) -> Bool {
        interests.contains {
            $0.name.lowercased() == name.lowercased().trimmingCharacters(in: .whitespaces)
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

