//
//  HabitRowCard.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct HabitRowCard: View {
    let habit: HabitModel
    let isCompleted: Bool
    let onToggle: () -> Void
    let onEdit:   () -> Void
    let onDelete: () -> Void

    private var habitColor: Color {
        Color(hex: habit.colorHex)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Color accent bar kiri (konsisten sama TimeBlockCard)
            Rectangle()
                .fill(habitColor)
                .frame(width: 4)
                .clipShape(Capsule())

            // Color dot
            Circle()
                .fill(habitColor)
                .frame(width: 10, height: 10)

            // Nama habit
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(isCompleted ? .secondary : .primary)
                    .strikethrough(isCompleted, color: .secondary)
                    .lineLimit(1)

                // Streak badge (diturunkan dari logs, selalu konsisten)
                if habit.currentStreak > 0 {
                    HStack(spacing: 3) {
                        Text("🔥")
                            .font(.caption2)
                        Text("\(habit.currentStreak) hari")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Checkbox
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                onToggle()
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isCompleted ? habitColor : Color(.tertiaryLabel))
                    .animation(.spring(duration: 0.3), value: isCompleted)
            }
            .buttonStyle(.plain)
            .frame(width: 44, height: 44) // Apple HIG: min tap target
            .accessibilityLabel(isCompleted ? "Tandai belum selesai" : "Tandai selesai")
            .accessibilityIdentifier("habit-toggle-\(habit.id)")
        }
        .padding(.vertical, 10)
        .padding(.leading, 0)
        .padding(.trailing, 8)
        .frame(minHeight: 64)
        .opacity(isCompleted ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isCompleted)
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Hapus", systemImage: "trash")
            }
        }
        .accessibilityIdentifier("habit-row-\(habit.id)")
    }
}
