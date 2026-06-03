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
            }) {
                InterestEditorForm(vm: vm)
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
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    vm.deleteInterest(interests[index])
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct InterestListRow: View {
    let interest: InterestModel

    private var pendingCount: Int {
        interest.tasks.filter { !$0.isDone }.count
    }

    private var totalCount: Int {
        interest.tasks.count
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: interest.colorHex))
                .frame(width: 16, height: 16)

            Text(interest.name)
                .font(.body)

            Spacer()

            Text("\(pendingCount)/\(totalCount) tugas")
                .font(.caption)
                .foregroundStyle(pendingCount == 0 ? .green : .secondary)
        }
        .padding(.vertical, 4)
    }
}
