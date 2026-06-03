//
//  PrimaryButton.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDestructive: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isDestructive ? Color.red : Color.accentColor)
                )
        }
    }
}
