//
//  WatchConnectivityService.swift
//  ALP MAD
//
//  Created by student on 28/05/26.
//
import Foundation
import WatchConnectivity

final class WatchConnectivityService: NSObject, WCSessionDelegate {

    static let shared = WatchConnectivityService()

    // State terakhir yang dikirim ke watch. Disimpan agar bisa di-push lewat
    // applicationContext, sehingga watch tetap menerima data terbaru walau baru
    // dibuka belakangan (bukan hanya saat reachable).
    private var latestTimeBlocks: [[String: Any]] = []
    private var latestHabits: [[String: Any]] = []

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func sendTimeBlocks(_ blocks: [TimeBlockModel]) {
        latestTimeBlocks = blocks.map { block in
            [
                "id": block.id.uuidString,
                "title": block.title,
                "startTime": block.startTime.timeIntervalSince1970,
                "endTime": block.endTime.timeIntervalSince1970,
                "interestId": block.interestId.uuidString
            ] as [String: Any]
        }
        pushContext()
        liveSend(["timeBlocks": latestTimeBlocks])
    }

    func sendHabits(_ habits: [HabitModel]) {
        latestHabits = habits.map { habit in
            [
                "id": habit.id.uuidString,
                "name": habit.name,
                "colorHex": habit.colorHex,
                "streakCount": habit.currentStreak   // pakai streak turunan yang akurat
            ] as [String: Any]
        }
        pushContext()
        liveSend(["habits": latestHabits])
    }

    // applicationContext = snapshot state terbaru; tersampaikan walau watch belum/baru terhubung.
    private func pushContext() {
        guard WCSession.default.activationState == .activated else { return }
        try? WCSession.default.updateApplicationContext([
            "timeBlocks": latestTimeBlocks,
            "habits": latestHabits
        ])
    }

    // live message untuk update instan saat watch sedang reachable (app watch terbuka).
    private func liveSend(_ message: [String: Any]) {
        guard WCSession.default.activationState == .activated,
              WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }

    // MARK: WCSessionDelegate
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        // begitu aktif, kirim state terakhir ke watch
        pushContext()
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        // re-activate agar koneksi tetap hidup (mis. setelah ganti watch)
        WCSession.default.activate()
    }
}
