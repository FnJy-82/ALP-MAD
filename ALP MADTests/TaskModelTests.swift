import Testing
import Foundation
import SwiftData
@testable import ALP_MAD

@Suite("Task Model Tests")
struct TaskModelTests {

    private func makeTask(
        title: String = "Kerjain tugas",
        priority: Priority = .medium,
        deadline: Date? = nil,
        isDone: Bool = false
    ) -> Task {
        Task(title: title, priority: priority, deadline: deadline, isDone: isDone)
    }

    @Test("isValid true untuk judul yang benar")
    func validTask() {
        let task = makeTask()
        #expect(task.isValid == true)
    }

    @Test("isValid false untuk judul kosong")
    func emptyTitleTask() {
        let task = makeTask(title: "")
        #expect(task.isValid == false)
    }

    @Test("isValid false untuk judul spasi")
    func whitespaceTitleTask() {
        let task = makeTask(title: "   ")
        #expect(task.isValid == false)
    }

    @Test("isOverdue false jika tidak ada deadline")
    func noDeadlineNotOverdue() {
        let task = makeTask()
        #expect(task.isOverdue == false)
    }

    @Test("isOverdue false jika sudah selesai meski deadline lewat")
    func doneTaskNotOverdue() {
        let past = Date.now.addingTimeInterval(-86400)
        let task = makeTask(deadline: past, isDone: true)
        #expect(task.isOverdue == false)
    }

    @Test("isOverdue true jika deadline lewat dan belum selesai")
    func overdueTask() {
        let past = Date.now.addingTimeInterval(-86400)
        let task = makeTask(deadline: past, isDone: false)
        #expect(task.isOverdue == true)
    }

    @Test("id unik untuk setiap task")
    func uniqueIds() {
        let a = makeTask()
        let b = makeTask()
        #expect(a.id != b.id)
    }

    @Test("priority default adalah medium")
    func defaultPriority() {
        let task = makeTask()
        #expect(task.priority == .medium)
    }
}



