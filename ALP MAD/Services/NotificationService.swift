//
//  NotificationService.swift
//  ALP MAD
//
//  Created by student on 28/05/26.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationService {

    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleNotification(for block: TimeBlockModel) {
        scheduleAlert(
            id: "\(block.id)-start",
            title: "Waktunya mulai!",
            body: block.title,
            date: block.startTime
        )
        scheduleAlert(
            id: "\(block.id)-end",
            title: "Blok waktu selesai",
            body: "\(block.title) telah berakhir.",
            date: block.endTime
        )
    }

    func cancelNotification(id: UUID) {
        center.removePendingNotificationRequests(
            withIdentifiers: ["\(id)-start", "\(id)-end"]
        )
    }

    //Private
    private func scheduleAlert(id: String, title: String, body: String, date: Date) {
        guard date > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request)
    }
    
    func scheduleImmediateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        center.add(request)
    }
}


