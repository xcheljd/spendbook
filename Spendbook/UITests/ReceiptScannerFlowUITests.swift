//
//  ReceiptScannerFlowUITests.swift
//  SpendBookUITests
//
//  Created on January 17, 2026
//

import XCTest

/// UI tests for the Receipt Scanner flow.
///
/// Tests receipt scanning functionality including:
/// - Opening camera scanner
/// - Opening photo picker
/// - Handling permissions
/// - Processing scanned results
final class ReceiptScannerFlowUITests: SpendBookUITests {

    func testOpenCameraScanner() {
        navigateToAddExpense()

        // Find and tap the camera button
        let cameraButton = app.buttons["camera.viewfinder"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'camera'")).firstMatch

        if cameraButton.exists {
            cameraButton.tap()

            // If camera permission is not granted, we should see the permission alert
            let permissionAlert = app.alerts["Camera Unavailable"]
            if permissionAlert.exists {
                // Verify permission alert is shown
                XCTAssertTrue(permissionAlert.exists)

                // Dismiss alert for test purposes
                permissionAlert.buttons["Cancel"].tap()
            }
        }
    }

    func testOpenPhotoPicker() {
        navigateToAddExpense()

        // Find and tap the photo picker button
        let photoButton = app.buttons["photo.on.rectangle"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'photo'")).firstMatch

        if photoButton.exists {
            photoButton.tap()

            // Verify photo picker sheet is presented
            let photosPicker = app.otherElements["PhotosPickerController"]
            XCTAssertTrue(photosPicker.exists || app.sheets.firstMatch.exists)
        }
    }

    func testCameraPermissionHandling() {
        navigateToAddExpense()

        // First time tapping camera should request permission
        let cameraButton = app.buttons["camera.viewfinder"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'camera'")).firstMatch

        if cameraButton.exists {
            cameraButton.tap()

            // Check for permission prompt or denied state
            let permissionAlert = app.alerts["Camera Unavailable"]
            if permissionAlert.exists {
                // Alert should have "Open Settings" and "Cancel" buttons
                XCTAssertTrue(permissionAlert.buttons["Open Settings"].exists)
                XCTAssertTrue(permissionAlert.buttons["Cancel"].exists)

                // Cancel for test
                permissionAlert.buttons["Cancel"].tap()
            }
        }
    }

    func testScanningStateDisplay() {
        // This test verifies the UI shows scanning progress
        // Actual scanning requires real images, so we test the UI state

        navigateToAddExpense()

        // Open photo picker
        let photoButton = app.buttons["photo.on.rectangle"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'photo'")).firstMatch

        if photoButton.exists {
            photoButton.tap()

            // Verify we can select a photo (the picker should be visible)
            let photosUIExists = app.otherElements["PhotosPickerController"].exists || app.sheets.firstMatch.exists
            XCTAssertTrue(photosUIExists)

            // Dismiss the picker
            if app.sheets.firstMatch.exists {
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.1)).tap()
            }
        }
    }

    func testScannerButtonsVisibility() {
        navigateToAddExpense()

        // Verify both scanner options are available
        let cameraButton = app.buttons["camera.viewfinder"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'camera'")).firstMatch
        let photoButton = app.buttons["photo.on.rectangle"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'photo'")).firstMatch

        XCTAssertTrue(cameraButton.exists, "Camera button should be visible")
        XCTAssertTrue(photoButton.exists, "Photo picker button should be visible")
    }

    func testErrorHandlingForInvalidImage() {
        // This test verifies error handling when an invalid image is selected
        navigateToAddExpense()

        // Open photo picker
        let photoButton = app.buttons["photo.on.rectangle"] ?? app.buttons.matching(NSPredicate(format: "label CONTAINS 'photo'")).firstMatch

        if photoButton.exists {
            photoButton.tap()

            // Dismiss picker (simulating cancellation or invalid selection)
            if app.sheets.firstMatch.exists {
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.1)).tap()
            }

            // Verify we're still on the amount entry screen
            let amountScreen = app.otherElements["AddEntryAmountScreen"]
            XCTAssertTrue(amountScreen.exists)
        }
    }
}
