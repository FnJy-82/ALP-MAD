//
//  TaskEditorForm.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct TaskEditorForm: View {
    @Environment(\.dismiss) private var dismiss

    let vm: TaskViewModel
    let interests: [InterestModel]
    let existingTask: TaskModel?
    let defaultInterest: InterestModel?
    let hideInterestPicker: Bool
    
    @State private var title: String = ""
    @State private var priority: Priority = .medium
    @State private var deadline: Date? = nil
    @State private var hasDeadline: Bool = false
    @State private var selectedInterest: InterestModel? = nil

    @FocusState private var titleFocused: Bool

    private var isEditing: Bool { existingTask != nil }
    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Judul
                Section("Tugas") {
                    TextField("Nama tugas", text: $title)
                        .focused($titleFocused)
                        .accessibilityIdentifier("task-title-field")
                }

                // MARK: - Kategori
                Section("Kategori") {
                    if hideInterestPicker {
                        // tampilkan saja interest aktif, tidak bisa diubah
                        if let interest = selectedInterest {
                            InterestBadge(interest: interest, isSelected: true)
                        }
                    } else if interests.isEmpty {
                        Text("Buat kategori dulu")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Button {
                                    selectedInterest = nil
                                } label: {
                                    Text("Tanpa Kategori")
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedInterest == nil
                                                      ? Color.accentColor.opacity(0.15)
                                                      : Color(.systemGray6))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(selectedInterest == nil
                                                        ? Color.accentColor
                                                        : Color.clear,
                                                        lineWidth: 1.5)
                                        )
                                }
                                .buttonStyle(.plain)

                                ForEach(interests) { interest in
                                    InterestBadge(
                                        interest: interest,
                                        isSelected: selectedInterest?.id == interest.id
                                    )
                                    .onTapGesture {
                                        selectedInterest = interest
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                // MARK: - Prioritas
                Section("Prioritas") {
                    Picker("Prioritas", selection: $priority) {
                        Text("Rendah").tag(Priority.low)
                        Text("Sedang").tag(Priority.medium)
                        Text("Tinggi").tag(Priority.high)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("task-priority-picker")
                }

                // MARK: - Deadline
                Section("Deadline") {
                    Toggle("Tambah deadline", isOn: $hasDeadline)

                    if hasDeadline {
                        DatePicker(
                            "Tanggal",
                            selection: Binding(
                                get: { deadline ?? .now },
                                set: { deadline = $0 }
                            ),
                            in: Date.now...,
                            displayedComponents: .date
                        )
                        .accessibilityIdentifier("task-deadline-picker")
                    }
                }

                // MARK: - Error
                if let error = vm.errorMessage {
                    Section {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Tugas" : "Tugas Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                        .accessibilityIdentifier("cancel-task-button")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") { saveTask() }
                        .disabled(isSaveDisabled)
                        .accessibilityIdentifier("save-task-button")
                }
            }
            .onAppear {
                titleFocused = true
                prefillIfEditing()
                if selectedInterest == nil {
                    selectedInterest = defaultInterest
                }
            }
        }
    }

    private func prefillIfEditing() {
        guard let task = existingTask else { return }
        title = task.title
        priority = task.priority
        deadline = task.deadline
        hasDeadline = task.deadline != nil
        selectedInterest = task.interest
    }

    private func saveTask() {
        if isEditing, let task = existingTask {
            task.title = title
            task.priority = priority
            task.deadline = hasDeadline ? deadline : nil
            task.interest = selectedInterest
            vm.addTask(
                title: task.title,
                priority: task.priority,
                deadline: task.deadline,
                to: task.interest
            )
        } else {
            vm.addTask(
                title: title,
                priority: priority,
                deadline: hasDeadline ? deadline : nil,
                to: selectedInterest
            )
        }

        if vm.errorMessage == nil {
            dismiss()
        }
    }
}

