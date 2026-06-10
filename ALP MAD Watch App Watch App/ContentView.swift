//
//  ContentView.swift
//  ALP MAD Watch App Watch App
//
//  Created by Emma Puspa Sari on 11/06/26.
//

import SwiftUI
import Combine
import WatchConnectivity

// MARK: - Lightweight models (di-decode dari payload yang dikirim iPhone)

struct WatchTimeBlock: Identifiable {
    let id: String
    let title: String
    let start: Date
    let end: Date
}

struct WatchHabit: Identifiable {
    let id: String
    let name: String
    let colorHex: String
    let streak: Int
}

// MARK: - Penerima data dari iPhone (WatchConnectivity)

final class WatchConnectivityProvider: NSObject, ObservableObject, WCSessionDelegate {
    @Published var timeBlocks: [WatchTimeBlock] = []
    @Published var habits: [WatchHabit] = []

    override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func apply(_ data: [String: Any]) {
        if data["timeBlocks"] != nil {
            timeBlocks = Self.parseTimeBlocks(data)
        }
        if data["habits"] != nil {
            habits = Self.parseHabits(data)
        }
    }

    // Fungsi parsing MURNI (static) — bisa di-unit-test tanpa WCSession/instance.
    static func parseTimeBlocks(_ data: [String: Any]) -> [WatchTimeBlock] {
        guard let raw = data["timeBlocks"] as? [[String: Any]] else { return [] }
        let parsed = raw.compactMap { d -> WatchTimeBlock? in
            guard
                let id = d["id"] as? String,
                let title = d["title"] as? String,
                let start = d["startTime"] as? TimeInterval,
                let end = d["endTime"] as? TimeInterval
            else { return nil }
            return WatchTimeBlock(
                id: id,
                title: title,
                start: Date(timeIntervalSince1970: start),
                end: Date(timeIntervalSince1970: end)
            )
        }
        return parsed.sorted { $0.start < $1.start }
    }

    static func parseHabits(_ data: [String: Any]) -> [WatchHabit] {
        guard let raw = data["habits"] as? [[String: Any]] else { return [] }
        return raw.compactMap { d -> WatchHabit? in
            guard
                let id = d["id"] as? String,
                let name = d["name"] as? String
            else { return nil }
            return WatchHabit(
                id: id,
                name: name,
                colorHex: d["colorHex"] as? String ?? "#A0A0A0",
                streak: d["streakCount"] as? Int ?? 0
            )
        }
    }

    // MARK: WCSessionDelegate
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        // Saat aktif, langsung ambil state terakhir yang sudah tersimpan
        let ctx = session.receivedApplicationContext
        if !ctx.isEmpty {
            DispatchQueue.main.async { self.apply(ctx) }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async { self.apply(applicationContext) }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async { self.apply(message) }
    }
}

// MARK: - Tampilan

struct ContentView: View {
    @StateObject private var provider = WatchConnectivityProvider()

    private var todayBlocks: [WatchTimeBlock] {
        provider.timeBlocks.filter { Calendar.current.isDateInToday($0.start) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Jadwal Hari Ini") {
                    if todayBlocks.isEmpty {
                        Text("Tidak ada jadwal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(todayBlocks) { block in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(block.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text("\(timeString(block.start)) – \(timeString(block.end))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Kebiasaan") {
                    if provider.habits.isEmpty {
                        Text("Belum ada habit")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(provider.habits) { habit in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(hex: habit.colorHex))
                                    .frame(width: 8, height: 8)
                                Text(habit.name)
                                    .font(.body)
                                    .lineLimit(1)
                                Spacer()
                                if habit.streak > 0 {
                                    Text("🔥\(habit.streak)")
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("ProduktifIn")
        }
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}

// MARK: - Helper warna (versi SwiftUI murni, watchOS-safe)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b) = (160, 160, 160)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

#Preview {
    ContentView()
}
