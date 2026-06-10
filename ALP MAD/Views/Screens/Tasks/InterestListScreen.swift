//
//  InterestListScreen.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI
import SwiftData

struct InterestListScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query (sort: \InterestModel.createdAt) private var interests: [InterestModel]

    @State private var vm: TaskViewModel
    @State private var showInterestEditor = false
    @State private var selectedInterest: InterestModel? = nil

    init(modelContext: ModelContext) {
        _vm = State(initialValue: TaskViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            Group {
                if interests.isEmpty {
                    EmptyStateView(
                        icon: "tag.slash",
                        title: "Belum ada kategori",
                        subtitle: "Tap + untuk membuat kategori interest pertamamu"
                    )
                } else {
                    interestList
                }
            }
            .navigationTitle("Kategori")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedInterest = nil
                        showInterestEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("add-interest-button")
                }
            }
            .sheet(isPresented: $showInterestEditor, onDismiss: {
                vm.fetchInterests()
                vm.errorMessage = nil
                selectedInterest = nil
            }) {
                InterestEditorForm(vm: vm, existingInterest: selectedInterest)
            }
            .navigationDestination(for: InterestModel.self) { (interest: InterestModel) in
                TaskListScreen(interest: interest, modelContext: modelContext)
            }
            .onAppear {
                vm.fetchInterests()
            }
        }
    }

    private var interestList: some View {
        List {
            ForEach(interests) { interest in
                NavigationLink(value: interest) {
                    InterestListRow(interest: interest)
                }
                .accessibilityIdentifier("interest-row-\(interest.id)")
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        vm.deleteInterest(interest)
                    } label: {
                        Label("Hapus", systemImage: "trash")
                    }
                    Button {
                        selectedInterest = interest
                        showInterestEditor = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct InterestListRow: View {
    let interest: InterestModel

    private var completedCount: Int {
        interest.tasks.filter { $0.isDone }.count
    }

    private var totalCount: Int {
        interest.tasks.count
    }

    // Hijau hanya jika ada tugas DAN semuanya selesai (kategori kosong tidak hijau).
    private var allDone: Bool {
        totalCount > 0 && completedCount == totalCount
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: interest.colorHex))
                .frame(width: 16, height: 16)

            Text(interest.name)
                .font(.body)

            Spacer()

            // completed/total → angka naik saat tugas diselesaikan
            Text("\(completedCount)/\(totalCount) tugas")
                .font(.caption)
                .foregroundStyle(allDone ? .green : .secondary)
        }
        .padding(.vertical, 4)
    }
}
