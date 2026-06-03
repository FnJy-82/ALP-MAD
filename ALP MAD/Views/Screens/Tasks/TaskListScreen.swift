//
//  TaskListScreen.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI
import SwiftData

struct TaskListScreen: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\InterestModel.createdAt)])
    private var allInterests: [InterestModel]

    let interest: InterestModel
    
    @State private var vm: TaskViewModel
    @State private var showTaskEditor = false
    @State private var selectedTask: TaskModel? = nil
    @State private var showCompleted = false

    init(interest: InterestModel, modelContext: ModelContext) {
        self.interest = interest
        _vm = State(initialValue: TaskViewModel(modelContext: modelContext))
    }

    var body: some View {
        Group {
            if vm.tasks.isEmpty {
                EmptyStateView(
                    icon: "checkmark.circle",
                    title: "Belum ada tugas",
                    subtitle: "Tap + untuk menambahkan tugas di kategori ini"
                )
            } else {
                taskList
            }
        }
        .navigationTitle(interest.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    selectedTask = nil
                    showTaskEditor = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("add-task-button")
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showCompleted.toggle()
                } label: {
                    Image(systemName: showCompleted ? "eye.slash" : "eye")
                }
                .accessibilityIdentifier("toggle-completed-button")
            }
        }
        .sheet(isPresented: $showTaskEditor, onDismiss: {
            vm.fetchTasks(for: interest)
            vm.errorMessage = nil
            selectedTask = nil
        }) {
            TaskEditorForm(
                vm: vm,
                interests: allInterests,
                existingTask: selectedTask,
                defaultInterest: interest,
                hideInterestPicker: true
            )
        }
        .onAppear {
            vm.fetchTasks(for: interest)
        }
    }

    private var taskList: some View {
        List {
            // pending tasks
            if !vm.pendingTasks.isEmpty {
                Section("Belum Selesai") {
                    ForEach(vm.pendingTasks) { task in
                        TaskRow(
                            task: task,
                            interest: interest,
                            onToggle: { task in
                                vm.toggleDone(task)
                                vm.fetchTasks(for: interest)  // ← tambah
                            },
                            onDelete: { vm.deleteTask($0) }
                        )
                        .onTapGesture {
                            selectedTask = task
                            showTaskEditor = true
                        }
                    }
                }
            }

            // completed tasks
            if showCompleted && !vm.completedTasks.isEmpty {
                Section("Selesai (\(vm.completedTasks.count))") {
                    ForEach(vm.completedTasks) { task in
                        TaskRow(
                            task: task,
                            interest: interest,
                            onToggle: { task in
                                vm.toggleDone(task)
                                vm.fetchTasks(for: interest)  // ← tambah
                            },
                            onDelete: { vm.deleteTask($0) }
                        )
                    }
                }
            }

            // overdue warning
            if !vm.overdueTasks.isEmpty {
                Section {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Text("\(vm.overdueTasks.count) tugas melewati deadline")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}


