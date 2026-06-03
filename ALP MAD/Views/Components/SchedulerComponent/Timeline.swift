//
//  Timeline.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct TimelineView: View {
    let timeBlocks: [TimeBlockModel]
    let interests: [InterestModel]
    let hourHeight: CGFloat = 60
    let onTapBlock: (TimeBlockModel) -> Void
    let onDeleteBlock: (TimeBlockModel) -> Void

    private let hours = Array(0..<24)

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                //grid jam
                VStack(spacing: 0) {
                    ForEach(hours, id: \.self) { hour in
                        HourRow(hour: hour, height: hourHeight)
                    }
                }

                //time block cards
                ForEach(timeBlocks) { block in
                    TimeBlockCard(
                        block: block,
                        interests: interests,
                        hourHeight: hourHeight,
                        onTap: onTapBlock,
                        onDelete: onDeleteBlock
                    )
                    .padding(.leading, 56) //offset setelah label jam
                    .padding(.trailing, 8)
                    .offset(y: topOffset(for: block))
                    .frame(height: cardHeight(for: block))
                }
            }
        }
        .accessibilityIdentifier("daily-timeline")
    }

    private func topOffset(for block: TimeBlockModel) -> CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: block.startTime)
        let minute = calendar.component(.minute, from: block.startTime)
        return CGFloat(hour * 60 + minute) * (hourHeight / 60)
    }

    private func cardHeight(for block: TimeBlockModel) -> CGFloat {
        let minutes = block.duration / 60
        return max(CGFloat(minutes) * (hourHeight / 60), 28)
    }
}

private struct HourRow: View {
    let hour: Int
    let height: CGFloat

    private var label: String {
        String(format: "%02d:00", hour)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .trailing)
                .offset(y: -8)

            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
        }
        .frame(height: height)
        .padding(.leading, 4)
    }
}


//#Preview {
//    Timeline()
//}
