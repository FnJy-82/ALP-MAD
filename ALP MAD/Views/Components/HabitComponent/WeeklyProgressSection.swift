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
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(habits) { habit in
                            WeeklyHabitCard(habit: habit)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                }
            }
        }
    }
}

// Extracted card supaya WeeklyProgressSection tetap pendek
private struct WeeklyHabitCard: View {
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
            // Baca dari relasi habit.logs (semua log habit ini), bukan habitVM.logs
            // yang hanya berisi log satu hari terakhir yang di-fetch.
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
            }
            WeeklyStreakBar(days: weekDays, accentColor: color)
            Text("🔥 \(habit.streakCount) hari beruntun")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(width: 220)
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


