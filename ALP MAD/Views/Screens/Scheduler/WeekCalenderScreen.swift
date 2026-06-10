//
//  WeekCalenderScreen.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI

struct WeekCalendarScreen: View {
    let vm: SchedulerViewModel
    let interests: [InterestModel]

    @State private var weekOffset: Int = 0

    private let hourHeight: CGFloat = 50
    private let hours = Array(0..<24)

    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = Date.now
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today),
            let baseDate = calendar.date(
                byAdding: .weekOfYear,
                value: weekOffset,
                to: weekInterval.start
            )
        else { return [] }

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: baseDate)
        }
    }

    private var weekRangeLabel: String {
        guard let first = weekDays.first, let last = weekDays.last else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "id_ID")
        return "\(formatter.string(from: first)) – \(formatter.string(from: last))"
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    //grid background
                    weekGrid

                    //blocks overlay
                    blocksOverlay
                }
            }
        }
        .navigationTitle("Mingguan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(weekRangeLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    withAnimation { weekOffset -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                }

                Button {
                    withAnimation { weekOffset += 1 }
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
        }
        // Catatan: blocksOverlay mengambil datanya sendiri lewat vm.blocksForWeek(containing:),
        // jadi tidak perlu fetchBlocks di onAppear (yang justru menimpa state harian vm.timeBlocks).
    }

    //Grid

    private var weekGrid: some View {
        HStack(alignment: .top, spacing: 0) {
            //kolom label jam
            VStack(spacing: 0) {
                //header kosong untuk alignment dengan kolom hari
                Color.clear.frame(height: 40)

                ForEach(hours, id: \.self) { hour in
                    Text(String(format: "%02d:00", hour))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: hourHeight, alignment: .topTrailing)
                        .padding(.trailing, 4)
                }
            }

            //kolom per hari
            ForEach(weekDays, id: \.self) { day in
                VStack(spacing: 0) {
                    //header hari
                    dayHeader(for: day)
                        .frame(height: 40)

                    //baris jam
                    ForEach(hours, id: \.self) { _ in
                        Rectangle()
                            .fill(Color(.separator).opacity(0.3))
                            .frame(width: 80, height: hourHeight)
                            .overlay(alignment: .top) {
                                Divider()
                            }
                    }
                }
            }
        }
    }

    private func dayHeader(for date: Date) -> some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d"
        formatter.locale = Locale(identifier: "id_ID")
        let isToday = Calendar.current.isDateInToday(date)

        return Text(formatter.string(from: date))
            .font(.caption)
            .fontWeight(isToday ? .bold : .regular)
            .foregroundStyle(isToday ? Color.accentColor : .primary)
            .frame(maxWidth: .infinity)
    }

    //Blocks Overlay
    private var blocksOverlay: some View {
        ForEach(Array(weekDays.enumerated()), id: \.element) { index, day in
            let dayBlocks = vm.blocksForWeek(containing: day).filter {
                Calendar.current.isDate($0.startTime, inSameDayAs: day)
            }

            ForEach(dayBlocks) { block in
                let interest = interests.first { $0.id == block.interestId }
                let color = Color(hex: interest?.colorHex ?? "#A0A0A0")
                let topOff = topOffset(for: block)
                let blockH = cardHeight(for: block)
                let leadingOff: CGFloat = 44 + CGFloat(index) * 80 + 2

                // Judul kegiatan DI DALAM blok, dibatasi & di-clip ke ukuran blok
                // supaya teks panjang tidak meluber keluar / menumpuk di dekat tanggal.
                Text(block.title)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(color.isLight ? .black : .white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 2)
                    .frame(width: 76, height: blockH, alignment: .topLeading)
                    .background(color.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .offset(x: leadingOff, y: 40 + topOff)
            }
        }
    }

    private func topOffset(for block: TimeBlockModel) -> CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: block.startTime)
        let minute = calendar.component(.minute, from: block.startTime)
        return CGFloat(hour * 60 + minute) * (hourHeight / 60)
    }

    private func cardHeight(for block: TimeBlockModel) -> CGFloat {
        let minutes = block.duration / 60
        return max(CGFloat(minutes) * (hourHeight / 60), 16)
    }
}

//#Preview {
//    WeekCalenderScreen()
//}
