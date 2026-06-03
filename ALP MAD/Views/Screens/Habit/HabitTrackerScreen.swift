//
//  HabitTrackerScreen.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI
import SwiftData

struct HabitTrackerScreen: View {
    @Environment(\.modelContext) private var modelContext

    @State private var habitVM: HabitViewModel
    @State private var pomodoroVM: PomodoroViewModel = PomodoroViewModel()

    @State private var showHabitEditor: Bool = false
    @State private var selectedHabit: HabitModel?      // untuk edit
    @State private var showDurationPicker: Bool = false

    // Durasi custom (minutes)
    @State private var customFocusMinutes: Int = 25
    @State private var customBreakMinutes: Int = 5

    init(modelContext: ModelContext) {
        _habitVM = State(initialValue: HabitViewModel(modelContext: modelContext))
    }

    // Warna aksen ring dari habit yang di-link ke pomodoro
    private var ringColor: Color {
        guard let habit = pomodoroVM.linkedHabit else {
            return .accentColor
        }
        return Color(hex: habit.colorHex)
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    pomodoroSection
                    Divider().padding(.vertical, 8)
                    habitListSection
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
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
            .sheet(isPresented: $showHabitEditor, onDismiss: {
                habitVM.fetchHabits()
                habitVM.fetchLogs(for: .now)
                habitVM.errorMessage = nil
                selectedHabit = nil
            }) {
                HabitEditorForm(vm: habitVM, existingHabit: selectedHabit)
            }
            .sheet(isPresented: $showDurationPicker) {
                durationPickerSheet
            }
            .onAppear {
                habitVM.fetchHabits()
                habitVM.fetchLogs(for: .now)
                NotificationService.shared.requestPermission()
            }
        }
    }

    // MARK: - Pomodoro Section

    private var pomodoroSection: some View {
        VStack(spacing: 20) {

            // Ring timer
            PomodoroRingView(
                timeRemaining: pomodoroVM.timeRemaining,
                totalDuration: pomodoroVM.session.currentDuration,
                accentColor: ringColor,
                state: pomodoroVM.session.state
            )
            .padding(.top, 16)

            // Sesi counter
            if pomodoroVM.session.completedCycles > 0 {
                Label(
                    "\(pomodoroVM.session.completedCycles) sesi selesai hari ini",
                    systemImage: "checkmark.seal.fill"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            // Durasi picker (tap untuk customize)
            Button {
                showDurationPicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                    Text("Fokus \(customFocusMinutes)m · Istirahat \(customBreakMinutes)m")
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                )
            }
            .buttonStyle(.plain)
            .disabled(pomodoroVM.session.state == .running || pomodoroVM.session.state == .onBreak)

            // Link habit ke sesi pomodoro
            if !habitVM.habits.isEmpty {
                linkedHabitPicker
            }

            // Control buttons
            PomodoroControlButtons(
                state: pomodoroVM.session.state,
                onStart:     {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    pomodoroVM.start()
                },
                onPause:     {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    pomodoroVM.pause()
                },
                onReset:     { pomodoroVM.reset() },
                onSkipBreak: { pomodoroVM.skipBreak() }
            )
        }
        .padding(.horizontal, 16)
    }

    // Picker untuk link habit ke pomodoro
    private var linkedHabitPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "Tanpa habit" chip
                Button {
                    pomodoroVM.linkHabit(nil)
                } label: {
                    Text("Tanpa kategori")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(pomodoroVM.linkedHabit == nil
                                      ? Color.accentColor.opacity(0.15)
                                      : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(pomodoroVM.linkedHabit == nil
                                        ? Color.accentColor
                                        : Color.clear,
                                        lineWidth: 1.5)
                        )
                        .foregroundStyle(pomodoroVM.linkedHabit == nil ? .accentColor : .secondary)
                }
                .buttonStyle(.plain)

                ForEach(habitVM.habits) { habit in
                    Button {
                        pomodoroVM.linkHabit(habit)
                    } label: {
                        HStack(spacing: 6) {
                            CategoryColorDot(colorHex: habit.colorHex, size: 8)
                            Text(habit.name)
                                .font(.subheadline)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(pomodoroVM.linkedHabit?.id == habit.id
                                      ? Color(hex: habit.colorHex).opacity(0.15)
                                      : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    pomodoroVM.linkedHabit?.id == habit.id
                                    ? Color(hex: habit.colorHex)
                                    : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                        .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Habit List Section

    private var habitListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack {
                Text("Kebiasaan Hari Ini")
                    .font(.headline)
                Spacer()
                let doneCount = habitVM.habits.filter {
                    habitVM.isCompleted(habit: $0)
                }.count
                Text("\(doneCount)/\(habitVM.habits.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            if habitVM.habits.isEmpty {
                EmptyStateView(
                    icon: "checkmark.circle",
                    title: "Belum ada kebiasaan",
                    subtitle: "Tap + untuk menambahkan kebiasaan pertamamu"
                )
                .frame(minHeight: 200)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(habitVM.habits) { habit in
                        VStack(spacing: 0) {
                            HabitRowCard(
                                habit: habit,
                                isCompleted: habitVM.isCompleted(habit: habit),
                                onToggle: {
                                    habitVM.markComplete(habit: habit)
                                },
                                onEdit: {
                                    selectedHabit = habit
                                    showHabitEditor = true
                                },
                                onDelete: {
                                    habitVM.deleteHabit(habit)
                                }
                            )
                            .padding(.horizontal, 16)

                            Divider()
                                .padding(.leading, 16 + 4 + 12 + 10 + 8) // indent setelah accent bar
                        }
                    }
                }

                // Weekly streak summary untuk tiap habit (collapsible, simple)
                weeklySection
            }
        }
    }

    // Weekly streak cards per habit
    private var weeklySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progres Mingguan")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.top, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(habitVM.habits) { habit in
                        weeklyHabitCard(habit: habit)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func weeklyHabitCard(habit: HabitModel) -> some View {
        let color = Color(hex: habit.colorHex)

        // Bangun 7 bool dari logs minggu ini
        let calendar = Calendar.current
        let today = Date.now
        let weekDays: [Bool] = (0..<7).map { offset in
            guard let day = calendar.date(
                byAdding: .day,
                value: offset - (calendar.component(.weekday, from: today) - 2),
                to: today
            ) else { return false }

            let start = DateHelper.startOfDay(day)
            let end   = DateHelper.endOfDay(day)
            return habitVM.logs.contains {
                guard let lh = $0.habit else { return false }
                return lh.id == habit.id
                    && $0.isCompleted
                    && $0.date >= start
                    && $0.date <= end
            }
        }

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }

            WeeklyStreakBar(days: weekDays, accentColor: color)

            HStack {
                Text("🔥 \(habit.streakCount) hari")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
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

    // MARK: - Duration Picker Sheet

    private var durationPickerSheet: some View {
        NavigationStack {
            Form {
                Section("Durasi Fokus") {
                    Stepper("\(customFocusMinutes) menit", value: $customFocusMinutes, in: 5...90, step: 5)
                }
                Section("Durasi Istirahat") {
                    Stepper("\(customBreakMinutes) menit", value: $customBreakMinutes, in: 1...30, step: 1)
                }
            }
            .navigationTitle("Atur Durasi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Selesai") {
                        pomodoroVM.setFocusDuration(minutes: customFocusMinutes)
                        pomodoroVM.setBreakDuration(minutes: customBreakMinutes)
                        showDurationPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
