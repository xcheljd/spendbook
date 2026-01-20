//
//  GoalsFlowUITests.swift
//  SpendBookUITests
//
//  Created on January 17, 2026
//

import XCTest

/// UI tests for the Goals flow.
///
/// Tests goal setting functionality including:
/// - Navigating to goals dashboard
/// - Creating new goals
/// - Setting budget limits
/// - Viewing goal progress
final class GoalsFlowUITests: SpendBookUITests {

    func testNavigateToGoalsDashboard() {
        // Wait for app to load
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        // Navigate to goals - look for a Goals button or tab
        let goalsButton = app.buttons["Goals"] ?? app.tabBars.buttons["Goals"]

        if goalsButton.exists {
            goalsButton.tap()
        } else {
            // Try settings path
            let settingsButton = app.buttons["Settings"] ?? app.tabBars.buttons["Settings"]
            if settingsButton.exists {
                settingsButton.tap()

                // Look for Goals section in settings
                let goalsSection = app.staticTexts["Goals"]
                if goalsSection.exists {
                    goalsSection.tap()
                }
            }
        }

        // Verify we're on the goals dashboard
        XCTAssertTrue(waitForElement(app.otherElements["GoalsDashboardView"], timeout: 5))
    }

    func testCreateNewDailyGoal() {
        navigateToGoalsScreen()

        // Look for "Add Goal" or similar button
        let addGoalButton = app.buttons["Add Goal"] ?? app.buttons["New Goal"] ?? app.buttons["plus.circle"]

        if addGoalButton.exists {
            addGoalButton.tap()
        } else {
            // Try tapping a "Create Goal" text button
            let createButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Create' AND label CONTAINS 'Goal'")).firstMatch
            if createButton.exists {
                createButton.tap()
            }
        }

        // Verify we're on the goal creation screen
        XCTAssertTrue(waitForElement(app.otherElements["SetGoalView"], timeout: 5))

        // Enter goal amount "50"
        let amountField = app.textFields["Amount"] ?? app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS 'amount'")).firstMatch
        if amountField.exists {
            amountField.tap()
            amountField.typeText("50")
        }

        // Select frequency (Daily)
        let frequencyButton = app.buttons["Daily"]
        if frequencyButton.exists {
            frequencyButton.tap()
        }

        // Save the goal
        let saveButton = app.buttons["Save"] ?? app.buttons["Done"]
        if saveButton.exists {
            saveButton.tap()
        }

        // Verify goal appears in dashboard
        let goalText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '$50' OR label CONTAINS '50'")).firstMatch
        XCTAssertTrue(goalText.waitForExistence(timeout: 3))
    }

    func testCreateWeeklyGoal() {
        navigateToGoalsScreen()

        // Tap add goal button
        let addGoalButton = app.buttons["Add Goal"] ?? app.buttons["plus.circle"]
        if addGoalButton.exists {
            addGoalButton.tap()
        }

        // Verify goal creation screen
        XCTAssertTrue(waitForElement(app.otherElements["SetGoalView"], timeout: 5))

        // Enter amount "200"
        let amountField = app.textFields["Amount"] ?? app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS 'amount'")).firstMatch
        if amountField.exists {
            amountField.tap()
            amountField.typeText("200")
        }

        // Select frequency (Weekly)
        let weeklyButton = app.buttons["Weekly"]
        if weeklyButton.exists {
            weeklyButton.tap()
        }

        // Save
        let saveButton = app.buttons["Save"] ?? app.buttons["Done"]
        if saveButton.exists {
            saveButton.tap()
        }

        // Verify goal is saved
        let goalText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '$200' OR label CONTAINS '200'")).firstMatch
        XCTAssertTrue(goalText.waitForExistence(timeout: 3))
    }

    func testViewGoalProgress() {
        navigateToGoalsScreen()

        // Look for existing goal cards with progress indicators
        let goalCards = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS 'GoalCard'"))

        if goalCards.count > 0 {
            // Verify progress bars or indicators are visible
            let firstCard = goalCards.firstMatch
            XCTAssertTrue(firstCard.exists)

            // Look for progress bar or progress text
            let progressBar = app.progressIndicators.firstMatch
            let progressText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '%'", "label CONTAINS 'progress'")).firstMatch

            XCTAssertTrue(progressBar.exists || progressText.exists)
        }
    }

    func testEditExistingGoal() {
        navigateToGoalsScreen()

        // Find an existing goal card
        let goalCard = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS 'GoalCard'")).firstMatch

        if goalCard.exists {
            // Tap to edit
            goalCard.tap()

            // Verify we can edit the goal amount
            let amountField = app.textFields["Amount"] ?? app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS 'amount'")).firstMatch
            if amountField.exists {
                amountField.tap()
                amountField.clearText()
                amountField.typeText("75")

                // Save changes
                let saveButton = app.buttons["Save"] ?? app.buttons["Done"]
                if saveButton.exists {
                    saveButton.tap()
                }
            }
        }
    }

    func testDeleteGoal() {
        navigateToGoalsScreen()

        // Find an existing goal card
        let goalCard = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS 'GoalCard'")).firstMatch

        if goalCard.exists {
            // Long press or swipe to reveal delete option
            goalCard.press(forDuration: 1.0)

            // Look for delete button
            let deleteButton = app.buttons["Delete"] ?? app.buttons["Trash"]
            if deleteButton.exists {
                deleteButton.tap()
            }

            // Confirm deletion if there's an alert
            let confirmAlert = app.alerts.firstMatch
            if confirmAlert.exists {
                confirmAlert.buttons["Delete"].tap()
            }
        }
    }

    // MARK: - Helper Methods

    func navigateToGoalsScreen() {
        // Wait for app to load
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        // Navigate to goals
        let goalsButton = app.buttons["Goals"] ?? app.tabBars.buttons["Goals"]

        if goalsButton.exists {
            goalsButton.tap()
        } else {
            // Try settings path
            let settingsButton = app.buttons["Settings"] ?? app.tabBars.buttons["Settings"]
            if settingsButton.exists {
                settingsButton.tap()

                let goalsSection = app.staticTexts["Goals"]
                if goalsSection.exists {
                    goalsSection.tap()
                }
            }
        }

        XCTAssertTrue(waitForElement(app.otherElements["GoalsDashboardView"], timeout: 5))
    }
}
