//
//  TaskRow.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct TaskRow: View {
    let task: TaskModel
    let interest: InterestModel?
    let onToggle: (TaskModel) -> Void
    let onDelete: (TaskModel) -> Void

    var body: some View {
        HStack(spacing: 12) {
            // checkbox
            Button {
                onToggle(task)
            } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(
                        task.isDone
                        ? Color(hex: interest?.colorHex ?? "#A0A0A0")
                        : Color.secondary
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isDone ? "Mark undone" : "Mark done")  
            .accessibilityIdentifier("task-toggle-\(task.id)")

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isDone, color: .secondary)
                    .foregroundStyle(task.isDone ? .secondary : .primary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    // priority badge
                    PriorityBadge(priority: task.priority)

                    // deadline
                    if let deadline = task.deadline {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(DateHelper.formattedDate(deadline))
                                .font(.caption)
                        }
                        .foregroundStyle(task.isOverdue ? .red : .secondary)
                    }
                }
            }

            Spacer()

            // interest dot
            if let interest {
                CategoryColorDot(colorHex: interest.colorHex, size: 8)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete(task)
            } label: {
                Label("Hapus", systemImage: "trash")
            }
        }
        .accessibilityIdentifier("task-row-\(task.id)")
    }
}

private struct PriorityBadge: View {
    let priority: Priority

    private var color: Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }

    private var label: String {
        switch priority {
        case .low: return "Rendah"
        case .medium: return "Sedang"
        case .high: return "Tinggi"
        }
    }

    var body: some View {
        Text(label)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.15))
            )
    }
}


