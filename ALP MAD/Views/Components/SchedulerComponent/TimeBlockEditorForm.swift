//
//  TimeBlockEditorForm.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct TimeBlockEditorForm: View {
    @Environment(\.dismiss) private var dismiss

    let vm: SchedulerViewModel
    let interests: [InterestModel]
    let existingBlock: TimeBlockModel?
    let selectedDate: Date

    @State private var title: String = ""
    @State private var selectedInterestId: UUID?
    @State private var startTime: Date = .now
    @State private var endTime: Date = Date.now.addingTimeInterval(3600)
    @State private var notifyOnStart: Bool = true

    @FocusState private var titleFocused: Bool

    private var isEditing: Bool { existingBlock != nil }
    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty || selectedInterestId == nil
    }

    // Clamp agar lowerBound tidak pernah melewati upperBound (mencegah crash ClosedRange
    // saat startTime mendekati tengah malam).
    private var endTimeRange: ClosedRange<Date> {
        let upper = DateHelper.endOfDay(selectedDate)
        let lower = min(startTime.addingTimeInterval(15 * 60), upper)
        return lower...upper
    }

    var body: some View {
        NavigationStack {
            Form {
                //Judul
                Section("Kegiatan") {
                    TextField("Nama kegiatan", text: $title)
                        .focused($titleFocused)
                        .accessibilityIdentifier("block-title-field")
                }

                //Kategori
                Section("Kategori") {
                    if interests.isEmpty {
                        Text("Buat kategori dulu di tab Tasks")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(interests) { interest in
                                    InterestChip(
                                        interest: interest,
                                        isSelected: selectedInterestId == interest.id
                                    )
                                    .onTapGesture {
                                        selectedInterestId = interest.id
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                //Waktu
                Section("Waktu") {
                    DatePicker(
                        "Mulai",
                        selection: $startTime,
                        in: DateHelper.startOfDay(selectedDate)...DateHelper.endOfDay(selectedDate),
                        displayedComponents: .hourAndMinute
                    )
                    .accessibilityIdentifier("block-start-picker")
                    .onChange(of: startTime) { _, newValue in
                        if endTime <= newValue {
                            endTime = newValue.addingTimeInterval(15 * 60)
                        }
                    }

                    DatePicker(
                        "Selesai",
                        selection: $endTime,
                        in: endTimeRange,
                        displayedComponents: .hourAndMinute
                    )
                    .accessibilityIdentifier("block-end-picker")
                }

                //Notifikasi
                Section("Pengingat") {
                    Toggle("Ingatkan saat mulai", isOn: $notifyOnStart)
                }

                //Error
                if let error = vm.errorMessage {
                    Section {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Blok" : "Blok Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        dismiss()
                    }
                    .accessibilityIdentifier("cancel-block-button")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        saveBlock()
                    }
                    .disabled(isSaveDisabled)
                    .accessibilityIdentifier("save-block-button")
                }
            }
            .onAppear {
                titleFocused = true
                if existingBlock != nil {
                    prefillIfEditing()
                } else {
                    startTime = combineDateWithTime(date: selectedDate, hour: 9, minute: 0)
                    endTime = combineDateWithTime(date: selectedDate, hour: 10, minute: 0)
                }
            }
        }
    }

    //Private
    private func prefillIfEditing() {
        guard let block = existingBlock else { return }
        title = block.title
        selectedInterestId = block.interestId
        startTime = block.startTime
        endTime = block.endTime
        notifyOnStart = block.notifyOnStart
    }

    private func saveBlock() {
        guard let interestId = selectedInterestId else { return }

        if let existing = existingBlock {
            existing.title = title
            existing.startTime = startTime
            existing.endTime = endTime
            existing.interestId = interestId
            existing.notifyOnStart = notifyOnStart
            vm.updateBlock(existing)
        } else {
            let block = TimeBlockModel(
                title: title,
                startTime: startTime,
                endTime: endTime,
                interestId: interestId,
                notifyOnStart: notifyOnStart
            )
            vm.addBlock(block)
        }

        if vm.errorMessage == nil {
            dismiss()
        }
    }
}

private func combineDateWithTime(date: Date, hour: Int, minute: Int) -> Date {
    var components = Calendar.current.dateComponents(
        [.year, .month, .day],
        from: date
    )
    components.hour = hour
    components.minute = minute
    return Calendar.current.date(from: components) ?? date
}

private struct InterestChip: View {
    let interest: InterestModel
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            CategoryColorDot(colorHex: interest.colorHex, size: 8)
            Text(interest.name)
                .font(.subheadline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color(hex: interest.colorHex).opacity(0.2) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isSelected ? Color(hex: interest.colorHex) : Color.clear,
                    lineWidth: 1.5
                )
        )
    }
}

//#Preview {
//    TimeBlockEditorForm()
//}
