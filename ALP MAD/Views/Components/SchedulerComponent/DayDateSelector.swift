//
//  DayDateSelector.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct DayDateSelectorView: View {
    @Binding var selectedDate: Date
    private let days: [Date] = Self.generateWeekDays()

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(days, id: \.self) { day in
                        DayCell(
                            date: day,
                            isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate),
                            isToday: Calendar.current.isDateInToday(day)
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedDate = day
                            }
                        }
                        .id(day)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .accessibilityIdentifier("date-selector-scroll")
            .onAppear {
                proxy.scrollTo(
                    days.first { Calendar.current.isDateInToday($0) },
                    anchor: .center
                )
            }
        }
    }

    private static func generateWeekDays() -> [Date] {
        let calendar = Calendar.current
        let today = Date.now
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return []
        }
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: weekInterval.start)
        }
    }
}

private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: date).prefix(3).uppercased().description
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(dayName)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white : .secondary)

            Text(dayNumber)
                .font(.callout)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)

            //dot untuk hari ini
            Circle()
                .fill(isToday && !isSelected ? Color.accentColor : Color.clear)
                .frame(width: 4, height: 4)
        }
        .frame(width: 40, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.accentColor : Color.clear)
        )
    }
}

//#Preview {
//    DayDateSelector()
//}
