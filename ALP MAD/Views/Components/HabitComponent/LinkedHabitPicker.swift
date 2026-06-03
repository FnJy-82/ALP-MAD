//
//  LinkedHabitPicker.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 04/06/26.
//

import SwiftUI

struct LinkedHabitPicker: View {
    let habits: [HabitModel]
    let linkedHabitId: UUID?
    let onSelect: (HabitModel?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sesi ini untuk kebiasaan:")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chipButton(
                        label: "Tanpa kategori",
                        colorHex: nil,
                        isSelected: linkedHabitId == nil
                    ) {
                        onSelect(nil)
                    }

                    ForEach(habits) { habit in
                        chipButton(
                            label: habit.name,
                            colorHex: habit.colorHex,
                            isSelected: linkedHabitId == habit.id
                        ) {
                            onSelect(habit)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func chipButton(
        label: String,
        colorHex: String?,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let color: Color = colorHex.map { Color(hex: $0) } ?? .accentColor
        return Button(action: action) {
            HStack(spacing: 6) {
                if let hex = colorHex {
                    CategoryColorDot(colorHex: hex, size: 8)
                }
                Text(label)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? color.opacity(0.15) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 1.5)
            )
            .foregroundStyle(isSelected ? color : .secondary)
        }
        .buttonStyle(.plain)
    }
}


