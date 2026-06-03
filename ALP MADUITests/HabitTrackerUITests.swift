//
//  HabitTrackerUITests.swift
//  ALP MADUITests
//
//  Created by Emma Puspa Sari on 04/06/26.
//

import XCTest

final class HabitTrackerUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        // Navigasi ke tab Habits
        app.tabBars.buttons["Habits"].tap()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Navigation

    @MainActor
    func testHabitsTabIsReachable() throws {
        // Setelah tap tab Habits, segmented control Timer/Kebiasaan harus muncul
        let timerSegment = app.buttons["Timer"]
        XCTAssertTrue(
            timerSegment.waitForExistence(timeout: 2),
            "Segmented control harus tampil setelah masuk tab Habits"
        )
    }

    @MainActor
    func testTimerTabIsDefaultSelected() throws {
        // Tab Timer harus aktif by default
        let startButton = app.buttons["pomodoro-start-button"]
        XCTAssertTrue(
            startButton.waitForExistence(timeout: 2),
            "Tombol Mulai harus tampil saat pertama masuk tab Habits"
        )
    }

    @MainActor
    func testSwitchToKebiasaanTab() throws {
        app.buttons["Kebiasaan"].tap()
        // Setelah pindah ke tab Kebiasaan, tombol + harus muncul di toolbar
        let addButton = app.buttons["add-habit-button"]
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 2),
            "Tombol + harus tampil di tab Kebiasaan"
        )
    }

    @MainActor
    func testAddButtonNotVisibleOnTimerTab() throws {
        // Tombol + tidak boleh muncul di tab Timer
        let addButton = app.buttons["add-habit-button"]
        XCTAssertFalse(
            addButton.exists,
            "Tombol + tidak boleh tampil di tab Timer"
        )
    }

    // MARK: - Pomodoro Timer

    @MainActor
    func testStartButtonExistsOnTimerTab() throws {
        let startButton = app.buttons["pomodoro-start-button"]
        XCTAssertTrue(
            startButton.waitForExistence(timeout: 2),
            "Tombol Mulai harus tampil di tab Timer"
        )
    }

    @MainActor
    func testResetButtonHiddenWhenIdle() throws {
        // Reset button tidak boleh muncul saat state idle
        let resetButton = app.buttons["pomodoro-reset-button"]
        XCTAssertFalse(
            resetButton.exists,
            "Tombol Reset tidak boleh tampil saat timer belum dimulai"
        )
    }

    @MainActor
    func testTapStartChangeButtonToPause() throws {
        let startButton = app.buttons["pomodoro-start-button"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2))
        startButton.tap()

        let pauseButton = app.buttons["pomodoro-pause-button"]
        XCTAssertTrue(
            pauseButton.waitForExistence(timeout: 2),
            "Tombol Jeda harus muncul setelah timer dimulai"
        )
    }

    @MainActor
    func testResetButtonAppearsAfterStart() throws {
        app.buttons["pomodoro-start-button"].tap()

        let resetButton = app.buttons["pomodoro-reset-button"]
        XCTAssertTrue(
            resetButton.waitForExistence(timeout: 2),
            "Tombol Reset harus muncul setelah timer dimulai"
        )
    }

    @MainActor
    func testPauseAndResumeFlow() throws {
        // Start
        app.buttons["pomodoro-start-button"].tap()
        XCTAssertTrue(app.buttons["pomodoro-pause-button"].waitForExistence(timeout: 2))

        // Pause
        app.buttons["pomodoro-pause-button"].tap()
        let resumeButton = app.buttons["pomodoro-resume-button"]
        XCTAssertTrue(
            resumeButton.waitForExistence(timeout: 2),
            "Tombol Lanjut harus muncul setelah dijeda"
        )

        // Resume
        resumeButton.tap()
        XCTAssertTrue(
            app.buttons["pomodoro-pause-button"].waitForExistence(timeout: 2),
            "Tombol Jeda harus muncul kembali setelah dilanjutkan"
        )
    }

    @MainActor
    func testResetFromRunningReturnsToIdle() throws {
        app.buttons["pomodoro-start-button"].tap()
        XCTAssertTrue(app.buttons["pomodoro-reset-button"].waitForExistence(timeout: 2))

        app.buttons["pomodoro-reset-button"].tap()

        // Setelah reset, tombol Mulai harus muncul lagi
        XCTAssertTrue(
            app.buttons["pomodoro-start-button"].waitForExistence(timeout: 2),
            "Tombol Mulai harus muncul kembali setelah reset"
        )
        // Reset button harus hilang lagi
        XCTAssertFalse(
            app.buttons["pomodoro-reset-button"].exists,
            "Tombol Reset harus hilang setelah reset ke idle"
        )
    }

    @MainActor
    func testResetFromPausedReturnsToIdle() throws {
        app.buttons["pomodoro-start-button"].tap()
        app.buttons["pomodoro-pause-button"].tap()
        XCTAssertTrue(app.buttons["pomodoro-reset-button"].waitForExistence(timeout: 2))

        app.buttons["pomodoro-reset-button"].tap()

        XCTAssertTrue(
            app.buttons["pomodoro-start-button"].waitForExistence(timeout: 2),
            "Tombol Mulai harus muncul kembali setelah reset dari paused"
        )
    }

    @MainActor
    func testDurationPickerButtonVisibleWhenIdle() throws {
        // Tombol durasi (timer chip) hanya tampil saat idle
        let durationButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Fokus'")
        ).firstMatch
        XCTAssertTrue(
            durationButton.waitForExistence(timeout: 2),
            "Tombol atur durasi harus tampil saat idle"
        )
    }

    @MainActor
    func testDurationPickerButtonHiddenWhenRunning() throws {
        app.buttons["pomodoro-start-button"].tap()

        let durationButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Fokus'")
        ).firstMatch
        XCTAssertFalse(
            durationButton.exists,
            "Tombol atur durasi harus hilang saat timer berjalan"
        )
    }

    @MainActor
    func testDurationPickerOpens() throws {
        let durationButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Fokus'")
        ).firstMatch
        XCTAssertTrue(durationButton.waitForExistence(timeout: 2))
        durationButton.tap()

        // Sheet durasi harus muncul
        let sheetTitle = app.navigationBars["Atur Durasi"]
        XCTAssertTrue(
            sheetTitle.waitForExistence(timeout: 2),
            "Sheet Atur Durasi harus muncul"
        )
    }

    @MainActor
    func testDurationPickerDismissWithSelesai() throws {
        let durationButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Fokus'")
        ).firstMatch
        XCTAssertTrue(durationButton.waitForExistence(timeout: 2))
        durationButton.tap()

        XCTAssertTrue(app.navigationBars["Atur Durasi"].waitForExistence(timeout: 2))
        app.buttons["Selesai"].tap()

        // Sheet harus tertutup
        XCTAssertFalse(
            app.navigationBars["Atur Durasi"].waitForExistence(timeout: 2),
            "Sheet Atur Durasi harus tertutup setelah tap Selesai"
        )
    }

    // MARK: - Add Habit Flow

    @MainActor
    func testTapAddButtonOpensHabitEditor() throws {
        app.buttons["Kebiasaan"].tap()
        app.buttons["add-habit-button"].tap()

        let nameField = app.textFields["habit-name-field"]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 2),
            "HabitEditorForm harus muncul setelah tap +"
        )
    }

    @MainActor
    func testSaveButtonDisabledWhenNameEmpty() throws {
        app.buttons["Kebiasaan"].tap()
        app.buttons["add-habit-button"].tap()

        let saveButton = app.buttons["save-habit-button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        XCTAssertFalse(
            saveButton.isEnabled,
            "Tombol Simpan harus disabled saat nama kosong"
        )
    }

    @MainActor
    func testSaveButtonEnabledAfterTypingName() throws {
        app.buttons["Kebiasaan"].tap()
        app.buttons["add-habit-button"].tap()

        let nameField = app.textFields["habit-name-field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Olahraga pagi")

        let saveButton = app.buttons["save-habit-button"]
        XCTAssertTrue(
            saveButton.waitForExistence(timeout: 2)
        )
        XCTAssertTrue(
            saveButton.isEnabled,
            "Tombol Simpan harus enabled setelah nama diisi"
        )
    }

    @MainActor
    func testCancelButtonDismissesHabitEditor() throws {
        app.buttons["Kebiasaan"].tap()
        app.buttons["add-habit-button"].tap()

        let cancelButton = app.buttons["cancel-habit-button"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 2))
        cancelButton.tap()

        let nameField = app.textFields["habit-name-field"]
        XCTAssertFalse(
            nameField.waitForExistence(timeout: 1),
            "Editor harus tertutup setelah tap Batal"
        )
    }

    @MainActor
    func testAddHabitHappyPath() throws {
        app.buttons["Kebiasaan"].tap()
        app.buttons["add-habit-button"].tap()

        let nameField = app.textFields["habit-name-field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Meditasi")

        app.buttons["save-habit-button"].tap()

        // Editor tertutup
        XCTAssertFalse(
            app.textFields["habit-name-field"].waitForExistence(timeout: 2),
            "Editor harus tertutup setelah simpan berhasil"
        )

        // Habit baru muncul di list
        let habitRow = app.staticTexts["Meditasi"]
        XCTAssertTrue(
            habitRow.waitForExistence(timeout: 3),
            "Habit baru harus tampil di list setelah ditambahkan"
        )
    }

    // MARK: - Toggle Habit

    @MainActor
    func testToggleHabitComplete() throws {
        // Tambah habit dulu
        app.buttons["Kebiasaan"].tap()
        app.buttons["add-habit-button"].tap()
        let nameField = app.textFields["habit-name-field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Baca Buku")
        app.buttons["save-habit-button"].tap()

        // Tunggu editor dismiss
        XCTAssertFalse(app.textFields["habit-name-field"].waitForExistence(timeout: 3))

        // Cari toggle button — pakai label "circle" (SF Symbol unchecked state)
        // atau "checkmark.circle.fill" (checked state)
        // XCTest expose image button by their accessibility label
        let uncheckedButton = app.buttons.matching(
            NSPredicate(format: "label == 'Tandai selesai'")
        ).firstMatch
        XCTAssertTrue(
            uncheckedButton.waitForExistence(timeout: 3),
            "Toggle button harus tampil di habit row"
        )

        uncheckedButton.tap()

        // Setelah toggle, label berubah jadi "Tandai belum selesai"
        let checkedButton = app.buttons.matching(
            NSPredicate(format: "label == 'Tandai belum selesai'")
        ).firstMatch
        XCTAssertTrue(
            checkedButton.waitForExistence(timeout: 2),
            "Habit harus ter-mark complete setelah toggle"
        )
    }

    @MainActor
    func testDeleteHabitViaSwipe() throws {
        // Tambah habit
        app.buttons["Kebiasaan"].tap()
        app.buttons["add-habit-button"].tap()
        let nameField = app.textFields["habit-name-field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Habit Hapus")
        app.buttons["save-habit-button"].tap()

        // Tunggu editor dismiss dan habit muncul
        XCTAssertFalse(app.textFields["habit-name-field"].waitForExistence(timeout: 3))
        XCTAssertTrue(
            app.staticTexts["Habit Hapus"].waitForExistence(timeout: 3),
            "Habit harus muncul di list sebelum dihapus"
        )

        // Swipe pada List cell — lebih spesifik, tidak ambigu
        let cell = app.cells.containing(.staticText, identifier: "Habit Hapus").firstMatch
        XCTAssertTrue(
            cell.waitForExistence(timeout: 3),
            "Cell habit harus ada di List"
        )
        cell.swipeLeft()

        // Tap tombol Hapus
        let deleteButton = app.buttons["Hapus"]
        XCTAssertTrue(
            deleteButton.waitForExistence(timeout: 3),
            "Tombol Hapus harus muncul setelah swipe kiri"
        )
        deleteButton.tap()

        // Habit harus hilang dari list
        // Tunggu sebentar supaya SwiftData selesai delete
        let habitGone = app.cells.containing(.staticText, identifier: "Habit Hapus").firstMatch
        XCTAssertFalse(
            habitGone.waitForExistence(timeout: 3),
            "Habit harus hilang dari list setelah dihapus"
        )
    }

    // MARK: - Linked Habit + Pomodoro Integration

    @MainActor
    func testLinkedHabitChipAppearsAfterAddingHabit() throws {
        // Tambah habit dulu di tab Kebiasaan
        app.buttons["Kebiasaan"].tap()
        app.buttons["add-habit-button"].tap()
        let nameField = app.textFields["habit-name-field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Yoga")
        app.buttons["save-habit-button"].tap()
        _ = app.textFields["habit-name-field"].waitForExistence(timeout: 2)

        // Kembali ke tab Timer
        app.buttons["Timer"].tap()

        // Chip "Yoga" harus muncul di linked habit picker
        let yogaChip = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Yoga'")
        ).firstMatch
        XCTAssertTrue(
            yogaChip.waitForExistence(timeout: 2),
            "Chip habit harus muncul di linked habit picker tab Timer"
        )
    }

    @MainActor
    func testLinkedHabitPickerHiddenWhenRunning() throws {
        // Tambah habit dan link ke timer
        app.buttons["Kebiasaan"].tap()
        app.buttons["add-habit-button"].tap()
        let nameField = app.textFields["habit-name-field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Stretching")
        app.buttons["save-habit-button"].tap()
        _ = app.textFields["habit-name-field"].waitForExistence(timeout: 2)

        app.buttons["Timer"].tap()

        // Start timer
        app.buttons["pomodoro-start-button"].tap()
        XCTAssertTrue(app.buttons["pomodoro-pause-button"].waitForExistence(timeout: 2))

        // Chip picker tidak boleh tampil saat running
        let chip = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Stretching'")
        ).firstMatch
        XCTAssertFalse(
            chip.exists,
            "Linked habit picker harus hilang saat timer sedang berjalan"
        )
    }

    // MARK: - Empty State

    @MainActor
    func testEmptyStateVisibleWithNoHabits() throws {
        app.buttons["Kebiasaan"].tap()
        let emptyState = app.staticTexts["Belum ada kebiasaan"]
        XCTAssertTrue(
            emptyState.waitForExistence(timeout: 2),
            "Empty state harus tampil saat belum ada habit"
        )
    }

    @MainActor
    func testEmptyStateDisappearsAfterAddingHabit() throws {
        app.buttons["Kebiasaan"].tap()
        app.buttons["add-habit-button"].tap()
        let nameField = app.textFields["habit-name-field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Jurnal Harian")
        app.buttons["save-habit-button"].tap()
        _ = app.textFields["habit-name-field"].waitForExistence(timeout: 2)

        let emptyState = app.staticTexts["Belum ada kebiasaan"]
        XCTAssertFalse(
            emptyState.exists,
            "Empty state harus hilang setelah habit ditambahkan"
        )
    }
}


