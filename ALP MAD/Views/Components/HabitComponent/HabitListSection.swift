//
//  HabitListSection.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 04/06/26.
//

import SwiftUI

struct HabitListSection: View {
    let habitVM: HabitViewModel
    let onEdit: (HabitModel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Kebiasaan Hari Ini")
                    .font(.headline)
                Spacer()
                let doneCount = habitVM.habits.filter {
                    habitVM.isCompleted(habit: $0)
                }.count
                Text("\(doneCount)/\(habitVM.habits.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            if habitVM.habits.isEmpty {
                EmptyStateView(
                    icon: "checkmark.circle",
                    title: "Belum ada kebiasaan",
                    subtitle: "Tap + di pojok kanan atas untuk menambahkan"
                )
                .frame(minHeight: 200)
            } else {
                // LazyVStack (bukan List) karena section ini berada di dalam ScrollView.
                // List-in-ScrollView dengan tinggi paksa membuat baris ke-clip/kepotong.
                LazyVStack(spacing: 0) {
                    ForEach(habitVM.habits) { habit in
                        HabitRowCard(
                            habit: habit,
                            isCompleted: habitVM.isCompleted(habit: habit),
                            onToggle: { habitVM.markComplete(habit: habit) },
                            onEdit: { onEdit(habit) },
                            onDelete: { habitVM.deleteHabit(habit) }
                        )
                        .padding(.horizontal, 16)

                        if habit.id != habitVM.habits.last?.id {
                            Divider().padding(.leading, 16)
                        }
                    }
                }
            }
        }
    }
}


