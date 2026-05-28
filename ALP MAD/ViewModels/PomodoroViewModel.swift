//
//  PomodoroViewModel.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 28/05/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class PomodoroViewModel {
    
    // MARK: - Dependencies
    private let notificationService: NotificationService
    
    // MARK: - State
    var session: PomodoroSession
    var timeRemaining: Int
    var linkedHabit: Habit?
    
    private var timer: Timer?
    
    init(notificationService: NotificationService = .shared) {
        self.notificationService = notificationService
        self.session = PomodoroSession()
        self.timeRemaining = session.focusDuration
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
    
    func linkHabit( habit: Habit?) {
        linkedHabit = habit
        session.linkedHabitId = habit?.id
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self]  in
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
            notifyBreak()
            startTimer()
        } else if session.state == .onBreak {
            session.state = .idle
            timeRemaining = session.focusDuration
            notifyFocusStart()
        }
    }
    
    // MARK: - Notifications
    
    private func notifyBreak() {
        notificationService.scheduleImmediateNotification(
            title: "Istirahat dulu!",
            body: "Sesi fokus selesai. Istirahat (session.breakDuration / 60) menit."
        )
    }
    
    private func notifyFocusStart() {
        notificationService.scheduleImmediateNotification(
            title: "Saatnya fokus!",
            body: "Istirahat selesai. Mulai sesi fokus berikutnya."
        )
    }
}
