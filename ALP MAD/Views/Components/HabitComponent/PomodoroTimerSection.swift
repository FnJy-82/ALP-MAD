//
//  PomodoroTimerSection.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 04/06/26.
//

import SwiftUI

struct PomodoroTimerSection: View {
    let pomodoroVM: PomodoroViewModel
    let habits: [HabitModel]
    let onShowDurationPicker: () -> Void

    // Binding dari parent supaya customFocusMinutes & customBreakMinutes
    // tetap sync dengan sheet picker
    let customFocusMinutes: Int
    let customBreakMinutes: Int

    private var ringColor: Color {
        guard let habit = pomodoroVM.linkedHabit else { return .accentColor }
        return Color(hex: habit.colorHex)
    }

    private var isIdle: Bool { pomodoroVM.session.state == .idle }
    private var isRunningOrBreak: Bool {
        pomodoroVM.session.state == .running || pomodoroVM.session.state == .onBreak
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {

                // Ring timer
                PomodoroRingView(
                    timeRemaining: pomodoroVM.timeRemaining,
                    totalDuration: pomodoroVM.session.currentDuration,
                    accentColor: ringColor,
                    state: pomodoroVM.session.state
                )
                .padding(.top, 20)

                // Sesi counter
                if pomodoroVM.session.completedCycles > 0 {
                    Label(
                        "\(pomodoroVM.session.completedCycles) sesi selesai",
                        systemImage: "checkmark.seal.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                // Durasi — hanya saat idle
                if isIdle {
                    Button(action: onShowDurationPicker) {
                        HStack(spacing: 6) {
                            Image(systemName: "timer")
                            Text("Fokus \(customFocusMinutes)m · Istirahat \(customBreakMinutes)m")
                            Image(systemName: "chevron.right").font(.caption2)
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
                }

                // Linked habit picker — hanya saat idle atau paused
                if !habits.isEmpty && !isRunningOrBreak {
                    LinkedHabitPicker(
                        habits: habits,
                        linkedHabitId: pomodoroVM.linkedHabit?.id,
                        onSelect: { pomodoroVM.linkHabit($0) }
                    )
                }

                // Info habit yang sedang aktif saat running/break
                if isRunningOrBreak, let linked = pomodoroVM.linkedHabit {
                    HStack(spacing: 6) {
                        CategoryColorDot(colorHex: linked.colorHex, size: 8)
                        Text("Sesi untuk: \(linked.name)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: linked.colorHex).opacity(0.1))
                    )
                }

                // Controls
                pomodoroControls

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: Controls

    private var pomodoroControls: some View {
        HStack(spacing: 12) {
            if pomodoroVM.session.state != .idle {
                Button(action: { pomodoroVM.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.body)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
                .accessibilityIdentifier("pomodoro-reset-button")
                .transition(.scale.combined(with: .opacity))
            }

            mainActionButton
        }
        .animation(.spring(duration: 0.3), value: pomodoroVM.session.state)
    }

    @ViewBuilder
    private var mainActionButton: some View {
        switch pomodoroVM.session.state {
        case .idle:
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                pomodoroVM.start()
            }) {
                Label("Mulai", systemImage: "play.fill")
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("pomodoro-start-button")

        case .running:
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                pomodoroVM.pause()
            }) {
                Label("Jeda", systemImage: "pause.fill")
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("pomodoro-pause-button")

        case .paused:
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                pomodoroVM.start()
            }) {
                Label("Lanjut", systemImage: "play.fill")
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("pomodoro-resume-button")

        case .onBreak:
            Button(action: { pomodoroVM.skipBreak() }) {
                Label("Lewati Istirahat", systemImage: "forward.fill")
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .accessibilityIdentifier("pomodoro-skip-button")

        case .completed:
            Button(action: { pomodoroVM.reset() }) {
                Label("Mulai Lagi", systemImage: "arrow.counterclockwise")
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("pomodoro-restart-button")
        }
    }
}


