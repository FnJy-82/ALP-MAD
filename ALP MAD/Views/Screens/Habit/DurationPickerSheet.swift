//
//  DurationPickerSheet.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 04/06/26.
//

import SwiftUI

struct DurationPickerSheet: View {
    @Binding var focusMinutes: Int
    @Binding var breakMinutes: Int
    let onConfirm: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Durasi Fokus") {
                    Stepper("\(focusMinutes) menit", value: $focusMinutes, in: 5...90, step: 5)
                }
                Section("Durasi Istirahat") {
                    Stepper("\(breakMinutes) menit", value: $breakMinutes, in: 1...30, step: 1)
                }
            }
            .navigationTitle("Atur Durasi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Selesai", action: onConfirm)
                }
            }
        }
        .presentationDetents([.medium])
    }
}


