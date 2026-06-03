//
//  InterestBadge.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct InterestBadge: View {
    let interest: InterestModel  
    var isSelected: Bool = false
    var size: BadgeSize = .medium

    enum BadgeSize {
        case small, medium, large

        var font: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .callout
            }
        }

        var dotSize: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 8
            case .large: return 10
            }
        }

        var padding: EdgeInsets {
            switch self {
            case .small: return .init(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .medium: return .init(top: 6, leading: 12, bottom: 6, trailing: 12)
            case .large: return .init(top: 8, leading: 16, bottom: 8, trailing: 16)
            }
        }
    }

    private var badgeColor: Color {
        Color(hex: interest.colorHex)
    }

    var body: some View {
        HStack(spacing: 6) {
            CategoryColorDot(colorHex: interest.colorHex, size: size.dotSize)
            Text(interest.name)
                .font(size.font)
                .foregroundStyle(isSelected ? badgeColor : .primary)
        }
        .padding(size.padding)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? badgeColor.opacity(0.15) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? badgeColor : Color.clear, lineWidth: 1.5)
        )
    }
}


