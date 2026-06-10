//
//  InterestEditorForm.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct InterestEditorForm: View {
    @Environment(\.dismiss) private var dismiss

    let vm: TaskViewModel
    var existingInterest: InterestModel? = nil

    @State private var name: String = ""
    @State private var selectedColorHex: String = "#4A90D9"

    private let colorOptions: [String] = [
        "#4A90D9", "#27AE60", "#E67E22", "#E74C3C",
        "#9B59B6", "#1ABC9C", "#F39C12", "#2C3E50"
    ]

    private var isEditing: Bool { existingInterest != nil }

    private var isSaveDisabled: Bool {
        name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // ← fix: pecah jadi computed property, hindari type-check timeout
    private var previewInterest: InterestModel {
        InterestModel(
            name: name.isEmpty ? "Nama Kategori" : name,
            colorHex: selectedColorHex
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Nama Kategori") {
                    TextField("Contoh: Kuliah, Olahraga", text: $name)
                        .accessibilityIdentifier("interest-name-field")
                }

                Section("Warna") {
                    LazyVGrid(
                        columns: Array(repeating: .init(.flexible()), count: 8),
                        spacing: 12
                    ) {
                        ForEach(colorOptions, id: \.self) { hex in
                            ColorCircleOption(
                                hex: hex,
                                isSelected: selectedColorHex == hex,
                                onTap: { selectedColorHex = hex }
                            )
                            .accessibilityIdentifier("color-option-\(hex)")
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Preview") {
                    // ← fix: pakai computed property, bukan inline init
                    InterestBadge(
                        interest: previewInterest,
                        isSelected: true,
                        size: .large
                    )
                }

                if let error = vm.errorMessage {
                    Section {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Kategori" : "Kategori Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                        .accessibilityIdentifier("cancel-interest-button")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        if let existing = existingInterest {
                            vm.updateInterest(existing, name: name, colorHex: selectedColorHex)
                        } else {
                            vm.addInterest(name: name, colorHex: selectedColorHex)
                        }
                        if vm.errorMessage == nil { dismiss() }
                    }
                    .disabled(isSaveDisabled)
                    .accessibilityIdentifier("save-interest-button")
                }
            }
            .onAppear {
                if let existing = existingInterest {
                    name = existing.name
                    selectedColorHex = existing.colorHex
                }
            }
        }
    }
}

private struct ColorCircleOption: View {
    let hex: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Circle()
            .fill(Color(hex: hex))
            .frame(width: 32, height: 32)
            .overlay(
                Circle()
                    .stroke(Color.primary, lineWidth: isSelected ? 2 : 0)
                    .padding(2)
            )
            .onTapGesture { onTap() }
    }
}



