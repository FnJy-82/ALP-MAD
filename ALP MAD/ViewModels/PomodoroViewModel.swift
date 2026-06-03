//
//  PomodoroViewModel.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 28/05/26.
//

import Foundation
import Observation
import UIKit                                   // ← tambah ini

@MainActor
@Observable
final class PomodoroViewModel {

    private let notificationService: NotificationService

    var session: PomodoroSessionModel
    var timeRemaining: Int
    var linkedHabit: HabitModel?
    var onFocusSessionCompleted: (() -> Void)?

    private var timer: Timer?
    private var backgroundedAt: Date?

    init(notificationService: NotificationService = .shared) {
        self.notificationService = notificationService
        let newSession = PomodoroSessionModel()
        self.session = newSession
        self.timeRemaining = newSession.focusDuration
    }

    // Dipanggil dari View lewat .task atau .onAppear
    // supaya setup observer terjadi di MainActor context
    func setupBackgroundObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    func removeBackgroundObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    // MARK: - Controls

    func start() {
        guard session.state == .idle || session.state == .paused else { return }
        session.state = .running
        startTimer()
    }

    func pause() {
        guard session.state == .running else { return }
        session.state = .paused
        stopTimer()
    }

    func reset() {
        stopTimer()
        session.state = .idle
        session.completedCycles = 0
        timeRemaining = session.focusDuration
    }

    func skipBreak() {
        guard session.state == .onBreak else { return }
        stopTimer()
        session.state = .idle
        timeRemaining = session.focusDuration
    }

    func setFocusDuration(minutes: Int) {
        guard session.state == .idle else { return }
        session.focusDuration = minutes * 60
        timeRemaining = session.focusDuration
    }

    func setBreakDuration(minutes: Int) {
        guard session.state == .idle else { return }
        session.breakDuration = minutes * 60
    }

    func linkHabit(_ habit: HabitModel?) {
        linkedHabit = habit
        session.linkedHabitId = habit?.id
    }

    // MARK: - Background Handling

    @objc private func handleDidEnterBackground() {
        guard session.state == .running || session.state == .onBreak else { return }
        backgroundedAt = Date.now
        stopTimer()
    }

    @objc private func handleWillEnterForeground() {
        guard
            let backgroundedAt,
            session.state == .running || session.state == .onBreak
        else {
            self.backgroundedAt = nil
            return
        }

        let elapsed = Int(Date.now.timeIntervalSince(backgroundedAt))
        self.backgroundedAt = nil

        let remaining = timeRemaining - elapsed

        if remaining > 0 {
            timeRemaining = remaining
            startTimer()
        } else {
            timeRemaining = 0
            handleTimerEnd()
        }
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard timeRemaining > 0 else {
            handleTimerEnd()
            return
        }
        timeRemaining -= 1
    }

    private func handleTimerEnd() {
        stopTimer()

        if session.state == .running {
            session.completedCycles += 1
            session.state = .onBreak
            timeRemaining = session.breakDuration

            onFocusSessionCompleted?()

            notificationService.scheduleImmediateNotification(
                title: "Sesi fokus selesai! 🎉",
                body: "Istirahat \(session.breakDuration / 60) menit dulu ya."
            )

            startTimer()

        } else if session.state == .onBreak {
            session.state = .idle
            timeRemaining = session.focusDuration

            notificationService.scheduleImmediateNotification(
                title: "Istirahat selesai! ⚡",
                body: "Siap untuk sesi fokus berikutnya?"
            )
        }
    }
}
