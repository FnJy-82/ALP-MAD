//
//  WeeklyProgressSection.swift
//  ALP MAD
//
//  Created by student on 04/06/26.
//

import SwiftUI

struct WeeklyProgressSection: View {
    let habits: [HabitModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progres Mingguan")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            if habits.isEmpty {
                Text("Tambah kebiasaan untuk melihat progres")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
            } else {
                // Layout vertikal: satu baris penuh per habit, semua habit langsung terlihat.
                VStack(spacing: 12) {
                    ForEach(habits) { habit in
                        WeeklyHabitRow(habit: habit)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct WeeklyHabitRow: View {
    let habit: HabitModel

    private var color: Color { Color(hex: habit.colorHex) }

    private var weekDays: [Bool] {
        let calendar = Calendar.current
        let today = Date.now
        let todayWeekday = calendar.component(.weekday, from: today)
        let offsetFromMonday = (todayWeekday + 5) % 7

        return (0..<7).map { index in
            guard let day = calendar.date(
                byAdding: .day,
                value: index - offsetFromMonday,
                to: today
            ) else { return false }
            let start = DateHelper.startOfDay(day)
            let end   = DateHelper.endOfDay(day)
            // Baca dari relasi habit.logs (semua log habit ini), bukan log satu hari.
            return habit.logs.contains {
                $0.isCompleted && $0.date >= start && $0.date <= end
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Circle().fill(color).frame(width: 10, height: 10)
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Spacer()
                Text("🔥 \(habit.currentStreak) hari")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            WeeklyStreakBar(days: weekDays, accentColor: color)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
    }
}
