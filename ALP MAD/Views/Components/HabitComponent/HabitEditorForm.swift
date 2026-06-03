//
//  HabitEditorForm.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 04/06/26.
//

import SwiftUI

struct HabitEditorForm: View {
    @Environment(\.dismiss) private var dismiss

    let vm: HabitViewModel
    let existingHabit: HabitModel?

    @State private var name: String = ""
    @State private var selectedColorHex: String = "#4A90D9"
    @FocusState private var nameFocused: Bool

    private let presetColors: [String] = [
        "#4A90D9", "#27AE60", "#E67E22", "#9B59B6",
        "#E74C3C", "#1ABC9C", "#F39C12", "#2C3E50"
    ]

    private var isEditing: Bool { existingHabit != nil }
    private var isSaveDisabled: Bool {
        name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // Nama
                Section("Nama Kebiasaan") {
                    TextField("Contoh: Olahraga pagi", text: $name)
                        .focused($nameFocused)
                        .accessibilityIdentifier("habit-name-field")
                }

                // Pilih warna
                Section("Warna Kategori") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(presetColors, id: \.self) { hex in
                                Button {
                                    selectedColorHex = hex
                                } label: {
                                    Circle()
                                        .fill(Color(hex: hex))
                                        .frame(width: 36, height: 36)
                                        .overlay {
                                            if selectedColorHex == hex {
                                                Circle()
                                                    .stroke(.white, lineWidth: 3)
                                                    .padding(3)
                                            }
                                        }
                                        .shadow(
                                            color: selectedColorHex == hex
                                                ? Color(hex: hex).opacity(0.5)
                                                : .clear,
                                            radius: 4
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }

                // Preview warna terpilih
                Section {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color(hex: selectedColorHex))
                            .frame(width: 12, height: 12)
                        Text(name.isEmpty ? "Nama kebiasaanmu" : name)
                            .font(.body)
                            .foregroundStyle(name.isEmpty ? .secondary : .primary)
                    }
                } header: {
                    Text("Preview")
                }

                // Error
                if let error = vm.errorMessage {
                    Section {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Kebiasaan" : "Kebiasaan Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                        .accessibilityIdentifier("cancel-habit-button")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") { save() }
                        .disabled(isSaveDisabled)
                        .accessibilityIdentifier("save-habit-button")
                }
            }
            .onAppear {
                nameFocused = true
                if let habit = existingHabit {
                    name = habit.name
                    selectedColorHex = habit.colorHex
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if let existing = existingHabit {
            vm.updateHabit(existing, name: trimmed, colorHex: selectedColorHex)
        } else {
            vm.addHabit(name: trimmed, colorHex: selectedColorHex)
        }
        if vm.errorMessage == nil {
            dismiss()
        }
    }
}
