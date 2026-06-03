//
//  PomodoroControlButtons.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct PomodoroControlButtons: View {
    let state: PomodoroState
    let onStart:     () -> Void
    let onPause:     () -> Void
    let onReset:     () -> Void
    let onSkipBreak: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            switch state {
            case .idle:
                // Reset (disabled saat idle) + Start
                Button(action: onReset) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                        .frame(width: 48, height: 48)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
                .disabled(true)

                Button(action: onStart) {
                    Label("Mulai", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("pomodoro-start-button")

            case .running:
                Button(action: onReset) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                        .frame(width: 48, height: 48)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
                .accessibilityIdentifier("pomodoro-reset-button")

                Button(action: onPause) {
                    Label("Jeda", systemImage: "pause.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("pomodoro-pause-button")

            case .paused:
                Button(action: onReset) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                        .frame(width: 48, height: 48)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
                .accessibilityIdentifier("pomodoro-reset-button")

                Button(action: onStart) {
                    Label("Lanjut", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("pomodoro-resume-button")

            case .onBreak:
                Button(action: onSkipBreak) {
                    Label("Lewati Istirahat", systemImage: "forward.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.orange)
                .accessibilityIdentifier("pomodoro-skip-button")

            case .completed:
                Button(action: onReset) {
                    Label("Mulai Lagi", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("pomodoro-restart-button")
            }
        }
        .padding(.horizontal, 24)
    }
}
