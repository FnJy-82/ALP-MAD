//
//  SchedulerScreen.swift
//  ALP MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI
import SwiftData

struct SchedulerScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var interests: [InterestModel]

    @State private var vm: SchedulerViewModel
    @State private var showEditor: Bool = false
    @State private var selectedBlock: TimeBlockModel?
    @State private var showWeekView: Bool = false

    init(modelContext: ModelContext) {
        _vm = State(initialValue: SchedulerViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DayDateSelectorView(selectedDate: $vm.selectedDate)
                    .onChange(of: vm.selectedDate) { _, newDate in
                        vm.fetchBlocks(for: newDate)
                    }

                Divider()

                if vm.timeBlocks.isEmpty {
                    EmptyStateView(
                        icon: "calendar.badge.plus",
                        title: "Belum ada jadwal",
                        subtitle: vm.canCreateBlock(on: vm.selectedDate)
                            ? "Tap + untuk menambahkan blok waktu pertamamu"
                            : "Hari ini sudah lewat — tidak bisa menambah jadwal baru"
                    )
                } else {
                    TimelineView(
                        timeBlocks: vm.timeBlocks,
                        interests: interests,
                        onTapBlock: { block in
                            selectedBlock = block
                            showEditor = true
                        },
                        onDeleteBlock: { block in
                            vm.deleteBlock(id: block.id)
                        }
                    )
                }
            }
            .navigationTitle("Jadwal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showWeekView.toggle()
                    } label: {
                        Image(systemName: showWeekView ? "calendar" : "calendar.badge.clock")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedBlock = nil
                        showEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(!vm.canCreateBlock(on: vm.selectedDate))   // hari lewat: tidak bisa tambah
                    .accessibilityIdentifier("add-block-button")
                }
            }
            .sheet(isPresented: $showEditor, onDismiss: {
                vm.fetchBlocks(for: vm.selectedDate)
                vm.errorMessage = nil
                selectedBlock = nil
            }) {
                TimeBlockEditorForm(
                    vm: vm,
                    interests: interests,
                    existingBlock: selectedBlock,
                    selectedDate: vm.selectedDate
                )
            }
            .navigationDestination(isPresented: $showWeekView) {
                WeekCalendarScreen(vm: vm, interests: interests)
            }
            .onAppear {
                vm.fetchBlocks(for: vm.selectedDate)
            }
        }
    }
}

//#Preview {
//    SchedulerScreen()
//}
