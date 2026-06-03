//
//  ALP_MADApp.swift
//  ALP MAD
//
//  Created by Emma Puspa Sari on 28/05/26.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct ALP_MADApp: App {

    let container: ModelContainer

    init() {
        UNUserNotificationCenter.current().delegate = AppNotificationDelegate.shared
        do {
            let isUITesting = ProcessInfo.processInfo.arguments.contains("UI_TESTING")
            let config = ModelConfiguration(isStoredInMemoryOnly: isUITesting)
            container = try ModelContainer(
                for: TimeBlockModel.self, InterestModel.self, TaskModel.self, HabitModel.self, HabitLogModel.self,
                configurations: config
            )

            if isUITesting {
                seedUITestData(context: container.mainContext)
            }
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabScreen()
                .modelContainer(container)
        }
    }

    private func seedUITestData(context: ModelContext) {
        //seed interests supaya editor bisa langsung pilih
        let interests = [
            InterestModel(name: "Kuliah", colorHex: "#4A90D9"),
            InterestModel(name: "Olahraga", colorHex: "#27AE60"),
            InterestModel(name: "Hobi", colorHex: "#E67E22")
        ]
        interests.forEach { context.insert($0) }
        try? context.save()
    }
    
    final class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
        static let shared = AppNotificationDelegate()
        
        private override init() { super.init() }
        
        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            willPresent notification: UNNotification,
            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
        ) {
            completionHandler([.banner, .sound, .badge])
        }
    }
}


