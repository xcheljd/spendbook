//
//  SpendBookUITests.swift
//  SpendBookUITests
//
//  Created on January 17, 2026
//

import XCTest

/// Base UI test class for SpendBook app.
///
/// Provides common test setup, teardown, and helper methods
/// for testing the user interface interactions.
final class SpendBookUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helper Methods

    /// Navigate to the Add Expense screen
    func navigateToAddExpense() {
        // Tap the add button (usually a plus icon)
        let addButton = app.buttons["Add Expense"]
        if addButton.exists {
            addButton.tap()
        } else {
            // Try alternate button identifier
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }

    /// Wait for an element to appear with a timeout
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5.0) -> Bool {
        let predicate = NSPredicate(format: "exists == 1")
        let expectation = expectation(for: predicate, evaluatedWith: element, handler: nil)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }

    /// Tap on a button with the given text
    func tapButton(text: String) {
        let button = app.buttons[text]
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Button '\(text)' not found")
        button.tap()
    }

    /// Type text into a text field
    func typeText(_ text: String, into textField: XCUIElement) {
        XCTAssertTrue(textField.waitForExistence(timeout: 5), "Text field not found")
        textField.tap()
        textField.typeText(text)
    }
}
