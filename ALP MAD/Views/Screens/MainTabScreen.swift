//
//  ContentView.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 28/05/26.
//

import SwiftUI
import SwiftData

struct MainTabScreen: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            SchedulerScreen(modelContext: modelContext)
                .tabItem {
                    Label("Jadwal", systemImage: "calendar")
                }

            //placeholder untuk FJ dan Hans
            HabitTrackerScreen(modelContext: modelContext)
                .tabItem {
                    Label("Habits", systemImage: "flame")
                }

            Text("Tasks")
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet")
                }
        }
    }
}

