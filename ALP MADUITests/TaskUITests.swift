//
//  TaskUITests.swift
//  ALP MADUITests
//
//  Created by Emma Puspa Sari on 04/06/26.
//

import XCTest

final class TaskUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()

        // navigasi ke tab Kategori
        app.tabBars.buttons["Kategori"].tap()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Interest Tests

    @MainActor
    func testKategoriTabIsAccessible() throws {
        let addButton = app.buttons["add-interest-button"]
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 2),
            "Tombol + harus ada di tab Kategori"
        )
    }

    @MainActor
    func testAddInterestButtonOpensEditor() throws {
        app.buttons["add-interest-button"].tap()

        let nameField = app.textFields["interest-name-field"]
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 2),
            "InterestEditorForm harus muncul setelah tap +"
        )
    }

    @MainActor
    func testSaveInterestDisabledWhenNameEmpty() throws {
        app.buttons["add-interest-button"].tap()

        let saveButton = app.buttons["save-interest-button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        XCTAssertFalse(
            saveButton.isEnabled,
            "Tombol Simpan harus disabled saat nama kosong"
        )
    }

    @MainActor
    func testSaveInterestEnabledAfterTypingName() throws {
        app.buttons["add-interest-button"].tap()

        let nameField = app.textFields["interest-name-field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Kuliah")

        let saveButton = app.buttons["save-interest-button"]
        XCTAssertTrue(
            saveButton.isEnabled,
            "Tombol Simpan harus enabled setelah nama diisi"
        )
    }

    @MainActor
    func testCancelInterestEditorDismisses() throws {
        app.buttons["add-interest-button"].tap()

        let cancelButton = app.buttons["cancel-interest-button"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 2))
        cancelButton.tap()

        XCTAssertFalse(
            app.textFields["interest-name-field"].waitForExistence(timeout: 1),
            "Editor harus tertutup setelah tap Batal"
        )
    }

    @MainActor
    func testAddInterestHappyPath() throws {
        app.buttons["add-interest-button"].tap()

        let nameField = app.textFields["interest-name-field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Gaming")

        app.buttons["save-interest-button"].tap()

        // editor tertutup
        XCTAssertFalse(
            app.textFields["interest-name-field"].waitForExistence(timeout: 2),
            "Editor harus tertutup setelah simpan berhasil"
        )

        // kategori muncul di list
        let gamingRow = app.staticTexts["Gaming"]
        XCTAssertTrue(
            gamingRow.waitForExistence(timeout: 2),
            "Kategori Gaming harus muncul di list setelah ditambah"
        )
    }

    // MARK: - Task Tests

    @MainActor
    func testNavigateIntoInterest() throws {
        // seed data sudah ada "Kuliah" dari ALP_MADApp seedUITestData
        let kuliah = app.staticTexts["Kuliah"]
        XCTAssertTrue(
            kuliah.waitForExistence(timeout: 2),
            "Kategori Kuliah dari seed data harus ada"
        )
        kuliah.tap()

        let addTaskButton = app.buttons["add-task-button"]
        XCTAssertTrue(
            addTaskButton.waitForExistence(timeout: 2),
            "Tombol + tugas harus ada setelah masuk kategori"
        )
    }

    @MainActor
    func testAddTaskButtonOpensEditor() throws {
        app.staticTexts["Kuliah"].tap()

        app.buttons["add-task-button"].tap()

        let titleField = app.textFields["task-title-field"]
        XCTAssertTrue(
            titleField.waitForExistence(timeout: 2),
            "TaskEditorForm harus muncul setelah tap +"
        )
    }

    @MainActor
    func testSaveTaskDisabledWhenTitleEmpty() throws {
        app.staticTexts["Kuliah"].tap()
        app.buttons["add-task-button"].tap()

        let saveButton = app.buttons["save-task-button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        XCTAssertFalse(
            saveButton.isEnabled,
            "Tombol Simpan harus disabled saat judul kosong"
        )
    }

    @MainActor
    func testSaveTaskEnabledAfterTypingTitle() throws {
        app.staticTexts["Kuliah"].tap()
        app.buttons["add-task-button"].tap()

        let titleField = app.textFields["task-title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Buat laporan")

        let saveButton = app.buttons["save-task-button"]
        XCTAssertTrue(
            saveButton.isEnabled,
            "Tombol Simpan harus enabled setelah judul diisi"
        )
    }

    @MainActor
    func testCancelTaskEditorDismisses() throws {
        app.staticTexts["Kuliah"].tap()
        app.buttons["add-task-button"].tap()

        let cancelButton = app.buttons["cancel-task-button"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 2))
        cancelButton.tap()

        XCTAssertFalse(
            app.textFields["task-title-field"].waitForExistence(timeout: 1),
            "Editor harus tertutup setelah tap Batal"
        )
    }

    @MainActor
    func testAddTaskHappyPath() throws {
        app.staticTexts["Kuliah"].tap()
        app.buttons["add-task-button"].tap()

        let titleField = app.textFields["task-title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Buat laporan")

        app.buttons["save-task-button"].tap()

        // editor tertutup
        XCTAssertFalse(
            app.textFields["task-title-field"].waitForExistence(timeout: 2),
            "Editor harus tertutup setelah simpan"
        )

        // tugas muncul di list
        let taskRow = app.staticTexts["Buat laporan"]
        XCTAssertTrue(
            taskRow.waitForExistence(timeout: 2),
            "Tugas harus muncul di list setelah ditambah"
        )
    }

    @MainActor
    func testToggleTaskDone() throws {
        app.staticTexts["Kuliah"].tap()
        app.buttons["add-task-button"].tap()

        let titleField = app.textFields["task-title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        titleField.tap()
        titleField.typeText("Tugas Toggle")
        app.buttons["save-task-button"].tap()

        let taskText = app.staticTexts["Tugas Toggle"]
        XCTAssertTrue(taskText.waitForExistence(timeout: 3))

        // tap toggle mark done
        let toggleButton = app.buttons["Mark done"]
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 2))
        toggleButton.tap()

        // tunggu UI settle setelah toggle
        sleep(1)

        // tap tombol mata by identifier
        let eyeButton = app.buttons["toggle-completed-button"]
        XCTAssertTrue(
            eyeButton.waitForExistence(timeout: 2),
            "Tombol toggle visibility harus ada"
        )
        eyeButton.tap()

        // tunggu section muncul
        let selesaiSection = app.staticTexts["Selesai (1)"]
        XCTAssertTrue(
            selesaiSection.waitForExistence(timeout: 3),
            "Section Selesai harus muncul setelah task di-complete dan visibility di-toggle"
        )
    }



    
    @MainActor
    func testDeleteInterestBySwipe() throws {
        // tambah interest dulu supaya ada yang bisa dihapus
        app.buttons["add-interest-button"].tap()
        let nameField = app.textFields["interest-name-field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Sementara")
        app.buttons["save-interest-button"].tap()

        // tunggu muncul di list
        let row = app.staticTexts["Sementara"]
        XCTAssertTrue(row.waitForExistence(timeout: 2))

        // swipe to delete
        row.swipeLeft()
        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2))
        deleteButton.tap()

        // row tidak ada lagi
        XCTAssertFalse(
            app.staticTexts["Sementara"].waitForExistence(timeout: 2),
            "Kategori harus hilang setelah dihapus"
        )
    }
}


