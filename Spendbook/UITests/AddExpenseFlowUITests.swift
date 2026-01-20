//
//  AddExpenseFlowUITests.swift
//  SpendBookUITests
//
//  Created on January 17, 2026
//

import XCTest

/// UI tests for the Add Expense flow.
///
/// Tests the complete expense entry workflow including:
/// - Navigation to the add expense screen
/// - Amount entry using the keypad
/// - Context screen navigation
/// - Saving an expense
final class AddExpenseFlowUITests: SpendBookUITests {

    func testNavigateToAddExpenseScreen() {
        // Wait for the app to fully load
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        // Tap the add button - look for a button with a plus icon or "Add" text
        let addButton = app.buttons["Add Expense"]
        let plusButton = app.buttons.matching(identifier: "addButton").firstMatch

        if addButton.exists {
            addButton.tap()
        } else if plusButton.exists {
            plusButton.tap()
        } else {
            // Try to find a button with a plus icon in the system
            let systemPlusButton = app.buttons["plus.circle"] ?? app.buttons["plus"]
            if systemPlusButton.exists {
                systemPlusButton.tap()
            }
        }

        // Verify we're on the amount entry screen
        XCTAssertTrue(waitForElement(app.otherElements["AddEntryAmountScreen"], timeout: 5))
    }

    func testEnterAmountUsingKeypad() {
        navigateToAddExpense()

        // Look for amount display
        let amountDisplay = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '$' OR label CONTAINS 'USD'")).firstMatch

        // Tap keypad buttons to enter "10.00"
        ["1", "0", ".", "0", "0"].forEach { digit in
            let button = app.buttons[digit]
            if button.exists {
                button.tap()
            } else {
                // Try alternate identifier
                app.buttons.matching(NSPredicate(format: "label CONTAINS '\(digit)'")).firstMatch.tap()
            }
        }

        // Verify amount is displayed
        XCTAssertTrue(amountDisplay.exists)
    }

    func testNavigateToContextScreen() {
        navigateToAddExpense()

        // Enter a valid amount
        ["1", "0"].forEach { digit in
            let button = app.buttons[digit]
            if button.exists {
                button.tap()
            } else {
                app.buttons.matching(NSPredicate(format: "label CONTAINS '\(digit)'")).firstMatch.tap()
            }
        }

        // Tap Next button
        let nextButton = app.buttons["Next"]
        if nextButton.exists {
            XCTAssertTrue(nextButton.isEnabled)
            nextButton.tap()
        }

        // Verify we're on the context screen
        XCTAssertTrue(waitForElement(app.otherElements["AddEntryContextScreen"], timeout: 5))
    }

    func testCompleteExpenseEntryFlow() {
        navigateToAddExpense()

        // Enter amount "25.50"
        ["2", "5", ".", "5", "0"].forEach { digit in
            let button = app.buttons[digit]
            if button.exists {
                button.tap()
            } else {
                app.buttons.matching(NSPredicate(format: "label CONTAINS '\(digit)'")).firstMatch.tap()
            }
        }

        // Tap Next
        app.buttons["Next"].tap()

        // Wait for context screen
        XCTAssertTrue(waitForElement(app.otherElements["AddEntryContextScreen"], timeout: 5))

        // Select a category/tag
        let tagButton = app.buttons["Tag"] ?? app.buttons["Category"]
        if tagButton.exists {
            tagButton.tap()

            // Select "Food" or first available tag
            let foodTag = app.buttons["Food"]
            if foodTag.exists {
                foodTag.tap()
            }
        }

        // Save the expense
        let saveButton = app.buttons["Save"]
        if saveButton.exists {
            saveButton.tap()
        }

        // Verify we're back on the home screen
        XCTAssertTrue(waitForElement(app.otherElements["HomeFeedView"], timeout: 5))

        // Verify the new expense appears in the list
        let newExpense = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '25.50' OR label CONTAINS '25,50'")).firstMatch
        XCTAssertTrue(newExpense.waitForExistence(timeout: 3))
    }
}
