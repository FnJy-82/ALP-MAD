//
//  WeeklyStreakBar.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct WeeklyStreakBar: View {
    // Kirim 7 nilai: true = selesai, false = tidak
    let days: [Bool]
    let accentColor: Color

    private let dayLabels = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<7, id: \.self) { index in
                VStack(spacing: 4) {
                    Circle()
                        .fill(index < days.count && days[index]
                              ? accentColor
                              : Color(.systemGray5))
                        .frame(width: 28, height: 28)
                        .overlay {
                            if index < days.count && days[index] {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }

                    Text(dayLabels[index])
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
