//
//  TimeBlockCard.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct TimeBlockCard: View {
    let block: TimeBlockModel
    let interests: [InterestModel]
    let hourHeight: CGFloat
    let onTap: (TimeBlockModel) -> Void
    let onDelete: (TimeBlockModel) -> Void

    private var interest: InterestModel? {
        interests.first { $0.id == block.interestId }
    }

    private var blockColor: Color {
        Color(hex: interest?.colorHex ?? "#A0A0A0")
    }

    private var cardHeight: CGFloat {
        let minutes = block.duration / 60
        return CGFloat(minutes) * (hourHeight / 60)
    }

    private var topOffset: CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: block.startTime)
        let minute = calendar.component(.minute, from: block.startTime)
        return CGFloat(hour * 60 + minute) * (hourHeight / 60)
    }

    var body: some View {
        HStack(spacing: 0) {
            //color accent bar di kiri
            Rectangle()
                .fill(blockColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(block.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(blockColor.isLight ? .black : .white)
                    .lineLimit(1)

                Text("\(DateHelper.formattedTime(block.startTime)) – \(DateHelper.formattedTime(block.endTime))")
                    .font(.caption)
                    .foregroundStyle(
                        (blockColor.isLight ? Color.black : Color.white)
                            .opacity(0.7)
                    )
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)

            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: max(cardHeight, 28))
        .background(blockColor.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(blockColor.opacity(0.4), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { onTap(block) }
        .contextMenu {
            Button {
                onTap(block)
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                onDelete(block)
            } label: {
                Label("Hapus", systemImage: "trash")
            }
        }
        .accessibilityIdentifier("time-block-card-\(block.id)")
    }
}

//#Preview {
//    TimeBlockCard()
//}
