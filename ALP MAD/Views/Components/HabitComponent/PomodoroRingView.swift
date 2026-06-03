//
//  PomodoroRingView.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct PomodoroRingView: View {
    let timeRemaining: Int
    let totalDuration: Int
    let accentColor: Color
    let state: PomodoroState

    private var progress: Double {
        guard totalDuration > 0 else { return 1.0 }
        return Double(timeRemaining) / Double(totalDuration)
    }

    private var minutes: Int { timeRemaining / 60 }
    private var seconds: Int { timeRemaining % 60 }

    private var stateLabel: String {
        switch state {
        case .idle:      return "Siap Fokus"
        case .running:   return "Sedang Fokus"
        case .paused:    return "Dijeda"
        case .onBreak:   return "Waktu Istirahat"
        case .completed: return "Selesai!"
        }
    }

    var body: some View {
        ZStack {
            // Track ring
            Circle()
                .stroke(accentColor.opacity(0.15), lineWidth: 16)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    accentColor,
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            // Center content
            VStack(spacing: 4) {
                Text(String(format: "%02d:%02d", minutes, seconds))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .monospacedDigit()

                Text(stateLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)
            }
        }
        .frame(width: 220, height: 220)
    }
}
