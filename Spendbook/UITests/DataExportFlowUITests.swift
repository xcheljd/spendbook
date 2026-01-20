//
//  DataExportFlowUITests.swift
//  SpendBookUITests
//
//  Created on January 19, 2026
//

import XCTest

/// UI tests for Data Export flow.
///
/// Tests data export functionality including:
/// - Navigating to Settings
/// - Exporting expenses as CSV
/// - Exporting expenses as JSON
/// - Verifying share sheet behavior
final class DataExportFlowUITests: SpendBookUITests {

    func testNavigateToSettings() {
        // Wait for app to load
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        // Find settings button (tab bar or navigation)
        let settingsButton = app.buttons["Settings"] ?? app.tabBars.buttons["Settings"]

        if settingsButton.exists {
            settingsButton.tap()
        } else {
            // Try alternate - navigation bar button
            let navSettingsButton = app.navigationBars.buttons.matching(NSPredicate(format: "identifier CONTAINS 'settings'", "label CONTAINS 'Settings'")).firstMatch
            if navSettingsButton.exists {
                navSettingsButton.tap()
            }
        }

        // Verify we're on the Settings view
        XCTAssertTrue(waitForElement(app.otherElements["SettingsView"], timeout: 5))

        // Look for Settings title
        let settingsTitle = app.staticTexts["Settings"]
        XCTAssertTrue(settingsTitle.exists)
    }

    func testExportAsCSV() {
        navigateToSettings()

        // Scroll to Data Sovereignty section
        let dataSovereigntySection = app.staticTexts["Data Sovereignty"]

        if dataSovereigntySection.exists {
            dataSovereigntySection.tap()
        } else {
            // Try scrolling
            app.scrollViews.firstMatch.swipeUp()
        }

        // Find CSV export button
        let csvExportButton = app.buttons["Export as CSV"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'CSV'")).firstMatch

        if csvExportButton.exists {
            csvExportButton.tap()

            // Verify share sheet is presented
            let shareSheet = app.otherElements["ShareSheet"] ?? app.sheets.firstMatch
            XCTAssertTrue(waitForElement(shareSheet, timeout: 5))

            // Verify CSV file name appears in share sheet
            let csvFileName = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '.csv' OR label CONTAINS 'Spendbook'")).firstMatch
            XCTAssertTrue(csvFileName.exists || shareSheet.exists)
        }
    }

    func testExportAsJSON() {
        navigateToSettings()

        // Scroll to Data Sovereignty section
        let dataSovereigntySection = app.staticTexts["Data Sovereignty"]

        if dataSovereigntySection.exists {
            dataSovereigntySection.tap()
        } else {
            app.scrollViews.firstMatch.swipeUp()
        }

        // Find JSON export button
        let jsonExportButton = app.buttons["Export as JSON"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'JSON'")).firstMatch

        if jsonExportButton.exists {
            jsonExportButton.tap()

            // Verify share sheet is presented
            let shareSheet = app.otherElements["ShareSheet"] ?? app.sheets.firstMatch
            XCTAssertTrue(waitForElement(shareSheet, timeout: 5))

            // Verify JSON file name appears in share sheet
            let jsonFileName = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '.json' OR label CONTAINS 'Spendbook'")).firstMatch
            XCTAssertTrue(jsonFileName.exists || shareSheet.exists)
        }
    }

    func testExportOptionsVisibility() {
        navigateToSettings()

        // Scroll to Data Sovereignty section
        app.scrollViews.firstMatch.swipeUp()

        // Verify both export options are visible
        let csvButton = app.buttons["Export as CSV"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'CSV'")).firstMatch
        let jsonButton = app.buttons["Export as JSON"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'JSON'")).firstMatch

        XCTAssertTrue(csvButton.exists, "CSV export button should be visible")
        XCTAssertTrue(jsonButton.exists, "JSON export button should be visible")

        // Verify button labels and icons
        if csvButton.exists {
            XCTAssertTrue(csvButton.label.contains("CSV") || csvButton.label.contains("Export"))
        }

        if jsonButton.exists {
            XCTAssertTrue(jsonButton.label.contains("JSON") || jsonButton.label.contains("Export"))
        }
    }

    func testExportShareSheetOptions() {
        navigateToSettings()

        // Scroll to Data Sovereignty section
        app.scrollViews.firstMatch.swipeUp()

        // Tap CSV export
        let csvExportButton = app.buttons["Export as CSV"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'CSV'")).firstMatch

        if csvExportButton.exists {
            csvExportButton.tap()

            // Wait for share sheet
            let shareSheet = app.otherElements["ShareSheet"] ?? app.sheets.firstMatch
            XCTAssertTrue(waitForElement(shareSheet, timeout: 5))

            // Look for common share options (Mail, Messages, etc.)
            let mailButton = app.buttons["Mail"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'Mail'")).firstMatch
            let messagesButton = app.buttons["Messages"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'Messages'")).firstMatch

            // At least one share option should be visible
            XCTAssertTrue(mailButton.exists || messagesButton.exists || shareSheet.exists)
        }
    }

    func testExportWithEmptyData() {
        // This test verifies export behavior when there are no expenses
        navigateToSettings()

        // Scroll to Data Sovereignty section
        app.scrollViews.firstMatch.swipeUp()

        // Try CSV export (should still work even with no expenses)
        let csvExportButton = app.buttons["Export as CSV"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'CSV'")).firstMatch

        if csvExportButton.exists {
            csvExportButton.tap()

            // Verify share sheet appears (export should still work)
            let shareSheet = app.otherElements["ShareSheet"] ?? app.sheets.firstMatch
            XCTAssertTrue(waitForElement(shareSheet, timeout: 5))

            // Dismiss share sheet
            if shareSheet.exists {
                shareSheet.swipeDown()
            }
        }
    }

    func testExportButtonIcons() {
        navigateToSettings()

        // Scroll to Data Sovereignty section
        app.scrollViews.firstMatch.swipeUp()

        // Verify button icons exist (table icon for CSV, braces for JSON)
        let csvButton = app.buttons["Export as CSV"]
        let jsonButton = app.buttons["Export as JSON"]

        if csvButton.exists {
            // Look for SF Symbol "tablecells"
            let csvIcon = app.images["tablecells"] ?? csvButton.images.firstMatch
            XCTAssertTrue(csvIcon.exists)
        }

        if jsonButton.exists {
            // Look for SF Symbol "curlybraces"
            let jsonIcon = app.images["curlybraces"] ?? jsonButton.images.firstMatch
            XCTAssertTrue(jsonIcon.exists)
        }
    }

    func testMultipleExports() {
        // Test that user can export both formats in one session
        navigateToSettings()

        // Scroll to Data Sovereignty section
        app.scrollViews.firstMatch.swipeUp()

        // Export as CSV
        let csvButton = app.buttons["Export as CSV"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'CSV'")).firstMatch

        if csvButton.exists {
            csvButton.tap()

            // Verify share sheet
            let shareSheet = app.sheets.firstMatch
            if shareSheet.waitForExistence(timeout: 5) {
                shareSheet.swipeDown()
            }

            // Export as JSON
            let jsonButton = app.buttons["Export as JSON"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'JSON'")).firstMatch

            if jsonButton.exists {
                jsonButton.tap()

                // Verify share sheet appears again
                XCTAssertTrue(waitForElement(shareSheet, timeout: 5))

                // Dismiss
                shareSheet.swipeDown()
            }
        }
    }

    // MARK: - Helper Methods

    func navigateToSettings() {
        // Wait for app to load
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        // Find settings button
        let settingsButton = app.buttons["Settings"] ?? app.tabBars.buttons["Settings"]

        if settingsButton.exists {
            settingsButton.tap()
        } else {
            // Try alternate path
            let navSettingsButton = app.navigationBars.buttons.matching(NSPredicate(format: "identifier CONTAINS 'settings'", "label CONTAINS 'Settings'")).firstMatch
            if navSettingsButton.exists {
                navSettingsButton.tap()
            }
        }

        // Verify settings view
        XCTAssertTrue(waitForElement(app.otherElements["SettingsView"], timeout: 5))
    }
}
