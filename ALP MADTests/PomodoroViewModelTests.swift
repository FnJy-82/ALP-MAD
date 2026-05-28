//
//  PomodoroViewModelTests.swift
//  ALP MADTests
//
//  Created by Emma Puspa Sari on 28/05/26.
//

import Testing
import Foundation
@testable import ALP_MAD

@Suite("PomodoroViewModel Tests")
@MainActor
struct PomodoroViewModelTests {
    
    @Test("State awal adalah idle")
    func initialStateIsIdle() {
        let vm = PomodoroViewModel()
        #expect(vm.session.state == .idle)
    }
    
    @Test("timeRemaining awal sama dengan focusDuration")
    func initialTimeRemaining() {
        let vm = PomodoroViewModel()
        #expect(vm.timeRemaining == vm.session.focusDuration)
    }
    
    @Test("start mengubah state menjadi running")
    func startChangesState() {
        let vm = PomodoroViewModel()
        vm.start()
        #expect(vm.session.state == .running)
    }
    
    @Test("pause mengubah state menjadi paused")
    func pauseChangesState() {
        let vm = PomodoroViewModel()
        vm.start()
        vm.pause()
        #expect(vm.session.state == .paused)
    }
    
    @Test("reset mengembalikan ke state idle")
    func resetRestoresIdle() {
        let vm = PomodoroViewModel()
        vm.start()
        vm.reset()
        #expect(vm.session.state == .idle)
        #expect(vm.session.completedCycles == 0)
        #expect(vm.timeRemaining == vm.session.focusDuration)
    }
    
    @Test("setFocusDuration mengubah durasi saat idle")
    func setFocusDuration() {
        let vm = PomodoroViewModel()
        vm.setFocusDuration(minutes: 30)
        #expect(vm.session.focusDuration == 30 * 60)
        #expect(vm.timeRemaining == 30 * 60)
    }
    
    @Test("setFocusDuration tidak berubah saat running")
    func setFocusDurationWhileRunning() {
        let vm = PomodoroViewModel()
        vm.start()
        vm.setFocusDuration(minutes: 30)
        #expect(vm.session.focusDuration == 25 * 60)
    }
    
    @Test("setBreakDuration mengubah durasi break saat idle")
    func setBreakDuration() {
        let vm = PomodoroViewModel()
        vm.setBreakDuration(minutes: 10)
        #expect(vm.session.breakDuration == 10 * 60)
    }
    
    @Test("skipBreak dari state onBreak kembali ke idle")
    func skipBreakFromOnBreak() {
        let vm = PomodoroViewModel()
        vm.session.state = .onBreak
        vm.skipBreak()
        #expect(vm.session.state == .idle)
        #expect(vm.timeRemaining == vm.session.focusDuration)
    }
    
    @Test("skipBreak tidak berefek saat running")
    func skipBreakWhileRunning() {
        let vm = PomodoroViewModel()
        vm.start()
        vm.skipBreak()
        #expect(vm.session.state == .running)
    }
    
    @Test("linkHabit menyimpan habit dan habitId")
    func linkHabit() {
        let vm = PomodoroViewModel()
        let habit = HabitModel(name: "Olahraga", colorHex: "#FF0000")
        vm.linkHabit(habit)
        #expect(vm.linkedHabit?.id == habit.id)
        #expect(vm.session.linkedHabitId == habit.id)
    }
    
    @Test("linkHabit nil menghapus habit")
    func unlinkHabit() {
        let vm = PomodoroViewModel()
        let habit = HabitModel(name: "Olahraga", colorHex: "#FF0000")
        vm.linkHabit(habit)
        vm.linkHabit(nil)
        #expect(vm.linkedHabit == nil)
        #expect(vm.session.linkedHabitId == nil)
    }
    
    @Test("isRunning true saat running")
    func isRunningWhenRunning() {
        let vm = PomodoroViewModel()
        vm.start()
        #expect(vm.session.isRunning == true)
    }
    
    @Test("isRunning true saat onBreak")
    func isRunningWhenOnBreak() {
        let vm = PomodoroViewModel()
        vm.session.state = .onBreak
        #expect(vm.session.isRunning == true)
    }
    
    @Test("isRunning false saat idle")
    func isRunningWhenIdle() {
        let vm = PomodoroViewModel()
        #expect(vm.session.isRunning == false)
    }
}

