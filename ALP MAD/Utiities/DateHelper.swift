//
//  DateHelpers.swift
//  ALP MAD
//
//  Created by student on 28/05/26.
//

import Foundation

enum DateHelper {

    static func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    static func endOfDay(_ date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay(date)) ?? date
    }

    static func weekRange(containing date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date)
        else {
            return (date, date)
        }
        let end = weekInterval.end.addingTimeInterval(-1)
        return (weekInterval.start, end)
    }

    static func isSameDay(_ a: Date, _ b: Date) -> Bool {
        Calendar.current.isDate(a, inSameDayAs: b)
    }

    static func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: date)
    }
}
