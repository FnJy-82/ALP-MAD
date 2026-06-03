//
//  SchedulerUITests.swift
//  ALP MADUITests
//
//  Created by student on 03/06/26.
//

import XCTest

final class SchedulerUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"] 
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    //Navigation
    @MainActor
    func testSchedulerTabIsFirstTab() throws {
        //Scheduler tab harus langsung visible saat app dibuka
        let timeline = app.scrollViews["daily-timeline"]
        let emptyState = app.staticTexts["Belum ada jadwal"]

        XCTAssertTrue(
            timeline.exists || emptyState.exists,
            "Scheduler screen harus tampil saat app pertama dibuka"
        )
    }

    @MainActor
    func testDateSelectorIsVisible() throws {
        let dateSelector = app.scrollViews["date-selector-scroll"]
        XCTAssertTrue(dateSelector.exists, "Date selector harus tampil di SchedulerScreen")
    }

    @MainActor
    func testAddBlockButtonIsVisible() throws {
        let addButton = app.buttons["add-block-button"]
        XCTAssertTrue(addButton.exists, "Tombol + harus tampil di toolbar")
    }

    //Add Block Flow
    @MainActor
    func testTapAddButtonOpensEditor() throws {
        let addButton = app.buttons["add-block-button"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()

        let titleField = app.textFields["block-title-field"]
        XCTAssertTrue(
            titleField.waitForExistence(timeout: 2),
            "TimeBlockEditorForm harus muncul setelah tap +"
        )
    }

    @MainActor
    func testSaveButtonDisabledWhenTitleEmpty() throws {
        app.buttons["add-block-button"].tap()

        let saveButton = app.buttons["save-block-button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        XCTAssertFalse(saveButton.isEnabled, "Tombol Simpan harus disabled saat judul kosong")
    }

    @MainActor
    func testSaveButtonEnabledAfterTypingTitle() throws {
        app.buttons["add-block-button"].tap()

        // isi judul
        let titleField = app.textFields["block-title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Belajar SwiftUI")

        // pilih interest dari seed data
        let interestChip = app.staticTexts["Kuliah"]
        if interestChip.waitForExistence(timeout: 2) {
            interestChip.tap()
        }

        // baru cek tombol enabled
        let saveButton = app.buttons["save-block-button"]
        XCTAssertTrue(
            saveButton.waitForExistence(timeout: 2)
        )
        XCTAssertTrue(
            saveButton.isEnabled,
            "Tombol Simpan harus enabled setelah judul diisi dan interest dipilih"
        )
    }

    @MainActor
    func testCancelButtonDismissesEditor() throws {
        app.buttons["add-block-button"].tap()

        let cancelButton = app.buttons["cancel-block-button"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 2))
        cancelButton.tap()

        //setelah dismiss, sheet tidak ada lagi
        let titleField = app.textFields["block-title-field"]
        XCTAssertFalse(
            titleField.waitForExistence(timeout: 1),
            "Editor harus tertutup setelah tap Batal"
        )
    }

    @MainActor
    func testAddBlockHappyPath() throws {
        app.buttons["add-block-button"].tap()

        // isi judul
        let titleField = app.textFields["block-title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        titleField.tap()
        titleField.typeText("Olahraga Pagi")

        // pilih interest — "Kuliah" sudah ada dari seed data
        let interestChip = app.staticTexts["Kuliah"]
        if interestChip.waitForExistence(timeout: 2) {
            interestChip.tap()
        }

        // simpan
        let saveButton = app.buttons["save-block-button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        // editor tertutup
        let dismissed = app.textFields["block-title-field"].waitForExistence(timeout: 3)
        XCTAssertFalse(dismissed, "Editor harus tertutup setelah simpan berhasil")
    }

    //Timeline
    @MainActor
    func testTimelineExistsAfterAddingBlock() throws {
        // tambah block dengan interest
        app.buttons["add-block-button"].tap()

        let titleField = app.textFields["block-title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        titleField.tap()
        titleField.typeText("Kuliah Pagi")

        let interestChip = app.staticTexts["Kuliah"]
        if interestChip.waitForExistence(timeout: 2) {
            interestChip.tap()
        }

        app.buttons["save-block-button"].tap()

        // tunggu sheet dismiss
        _ = app.textFields["block-title-field"].waitForExistence(timeout: 2)

        // timeline harus muncul
        let timeline = app.scrollViews["daily-timeline"]
        XCTAssertTrue(
            timeline.waitForExistence(timeout: 3),
            "Timeline harus tampil setelah ada time block"
        )
    }

    //Week View
    @MainActor
    func testWeekViewButtonExists() throws {
        //tombol toggle week view ada di toolbar kiri
        //icon calendar atau calendar.badge.clock
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(navBar.exists)

        //cek ada minimal 2 button di navbar (week toggle + add)
        let buttons = navBar.buttons
        XCTAssertGreaterThanOrEqual(
            buttons.count, 2,
            "Navbar harus punya minimal 2 tombol"
        )
    }
}
