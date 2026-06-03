//
//  HabitTrackerScreen.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 04/06/26.
//

import SwiftUI
import SwiftData

struct HabitTrackerScreen: View {
    @Environment(\.modelContext) private var modelContext

    @State private var habitVM: HabitViewModel
    @State private var pomodoroVM: PomodoroViewModel = PomodoroViewModel()
    @State private var selectedTab: HabitTab = .timer
    @State private var showHabitEditor: Bool = false
    @State private var selectedHabit: HabitModel?
    @State private var showDurationPicker: Bool = false
    @State private var customFocusMinutes: Int = 25
    @State private var customBreakMinutes: Int = 5

    enum HabitTab: String, CaseIterable {
        case timer     = "Timer"
        case kebiasaan = "Kebiasaan"
        var icon: String {
            switch self {
            case .timer:     return "timer"
            case .kebiasaan: return "checkmark.circle"
            }
        }
    }

    init(modelContext: ModelContext) {
        _habitVM = State(initialValue: HabitViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Tab", selection: $selectedTab) {
                    ForEach(HabitTab.allCases, id: \.self) { tab in
                        Label(tab.rawValue, systemImage: tab.icon).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                Divider()

                switch selectedTab {
                case .timer:
                    PomodoroTimerSection(
                        pomodoroVM: pomodoroVM,
                        habits: habitVM.habits,
                        onShowDurationPicker: { showDurationPicker = true },
                        customFocusMinutes: customFocusMinutes,
                        customBreakMinutes: customBreakMinutes
                    )
                case .kebiasaan:
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            HabitListSection(
                                habitVM: habitVM,
                                onEdit: { habit in
                                    selectedHabit = habit
                                    showHabitEditor = true
                                }
                            )
                            Divider().padding(.vertical, 8)
                            WeeklyProgressSection(
                                habits: habitVM.habits,
                                logs: habitVM.logs
                            )
                            .padding(.bottom, 32)
                        }
                    }
                }
            }
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if selectedTab == .kebiasaan {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            selectedHabit = nil
                            showHabitEditor = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityIdentifier("add-habit-button")
                    }
                }
            }
            .sheet(isPresented: $showHabitEditor, onDismiss: {
                habitVM.fetchHabits()
                habitVM.fetchLogs(for: .now)
                habitVM.errorMessage = nil
                selectedHabit = nil
            }) {
                HabitEditorForm(vm: habitVM, existingHabit: selectedHabit)
            }
            .sheet(isPresented: $showDurationPicker) {
                DurationPickerSheet(
                    focusMinutes: $customFocusMinutes,
                    breakMinutes: $customBreakMinutes,
                    onConfirm: {
                        pomodoroVM.setFocusDuration(minutes: customFocusMinutes)
                        pomodoroVM.setBreakDuration(minutes: customBreakMinutes)
                        showDurationPicker = false
                    }
                )
            }
            .onAppear {
                NotificationService.shared.requestPermission()
                habitVM.fetchHabits()
                habitVM.fetchLogs(for: .now)
                pomodoroVM.setupBackgroundObservers()      
                pomodoroVM.onFocusSessionCompleted = {
                    if let habit = pomodoroVM.linkedHabit {
                        habitVM.markComplete(habit: habit)
                    }
                }
            }
            .onDisappear {
                pomodoroVM.removeBackgroundObservers()
            }
        }
    }
}

