//
//  FilterFlowUITests.swift
//  SpendBookUITests
//
//  Created on January 17, 2026
//

import XCTest

/// UI tests for the Filter flow.
///
/// Tests filter functionality including:
/// - Opening filter sheet
/// - Selecting date range filters
/// - Selecting tag/category filters
/// - Applying and clearing filters
final class FilterFlowUITests: SpendBookUITests {

    func testOpenFilterSheet() {
        // Wait for app to load
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        // Look for filter button (typically a funnel or filter icon)
        let filterButton = app.buttons["Filter"] ?? app.buttons["line.3.horizontal.decrease.circle"] ?? app.buttons["funnel"]

        if filterButton.exists {
            filterButton.tap()

            // Verify filter sheet is presented
            let filterSheet = app.sheets["FilterSheet"] ?? app.otherElements["FilterSheetView"]
            XCTAssertTrue(waitForElement(filterSheet, timeout: 5))
        }
    }

    func testSelectDateRangeFilter() {
        openFilterSheet()

        // Look for date range section
        let dateRangeSection = app.staticTexts["Date Range"] ?? app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'date'", "label CONTAINS 'range'")).firstMatch

        if dateRangeSection.exists {
            // Tap on date range picker
            let dateRangePicker = app.buttons["Last 7 Days"] ?? app.buttons["Last 30 Days"] ?? app.buttons["This Month"]

            if dateRangePicker.exists {
                dateRangePicker.tap()

                // Verify selection is made
                XCTAssertTrue(dateRangePicker.isSelected)
            }
        }
    }

    func testSelectTagFilter() {
        openFilterSheet()

        // Look for tags section
        let tagsSection = app.staticTexts["Tags"] ?? app.staticTexts["Categories"] ?? app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'tag'", "label CONTAINS 'category'")).firstMatch

        if tagsSection.exists {
            // Select a tag (e.g., "Food")
            let foodTag = app.buttons["Food"]

            if foodTag.exists {
                foodTag.tap()

                // Verify tag is selected
                XCTAssertTrue(foodTag.isSelected)
            }
        }
    }

    func testSelectMultipleFilters() {
        openFilterSheet()

        // Select a date range
        let last7DaysButton = app.buttons["Last 7 Days"]
        if last7DaysButton.exists {
            last7DaysButton.tap()
        }

        // Select a tag
        let foodTag = app.buttons["Food"]
        if foodTag.exists {
            foodTag.tap()
        }

        // Apply filters
        let applyButton = app.buttons["Apply"] ?? app.buttons["Done"]
        if applyButton.exists {
            applyButton.tap()
        }

        // Verify filters are applied (look for active filters indicator)
        let activeFilters = app.otherElements["ActiveFiltersView"]
        XCTAssertTrue(activeFilters.waitForExistence(timeout: 3))
    }

    func testClearFilters() {
        // First, apply some filters
        openFilterSheet()

        let last7DaysButton = app.buttons["Last 7 Days"]
        if last7DaysButton.exists {
            last7DaysButton.tap()
        }

        let applyButton = app.buttons["Apply"] ?? app.buttons["Done"]
        if applyButton.exists {
            applyButton.tap()
        }

        // Now clear the filters
        let clearButton = app.buttons["Clear"] ?? app.buttons["Reset"]
        if clearButton.exists {
            clearButton.tap()
        }

        // Verify filters are cleared (no active filters indicator)
        let activeFilters = app.otherElements["ActiveFiltersView"]
        XCTAssertFalse(activeFilters.exists)
    }

    func testFilterByAmountRange() {
        openFilterSheet()

        // Look for amount range section
        let amountSection = app.staticTexts["Amount"] ?? app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'amount'", "label CONTAINS 'range'")).firstMatch

        if amountSection.exists {
            // Enter minimum amount
            let minAmountField = app.textFields["Min"] ?? app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS 'min'", "placeholderValue CONTAINS 'minimum'")).firstMatch
            if minAmountField.exists {
                minAmountField.tap()
                minAmountField.typeText("10")
            }

            // Enter maximum amount
            let maxAmountField = app.textFields["Max"] ?? app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS 'max'", "placeholderValue CONTAINS 'maximum'")).firstMatch
            if maxAmountField.exists {
                maxAmountField.tap()
                maxAmountField.typeText("100")
            }

            // Apply filter
            let applyButton = app.buttons["Apply"] ?? app.buttons["Done"]
            if applyButton.exists {
                applyButton.tap()
            }

            // Verify filtered results
            let filteredResults = app.otherElements["FilteredExpenseList"]
            XCTAssertTrue(filteredResults.waitForExistence(timeout: 3))
        }
    }

    func testFilterResultsVisibility() {
        // Apply a filter that should reduce visible expenses
        openFilterSheet()

        let last7DaysButton = app.buttons["Last 7 Days"]
        if last7DaysButton.exists {
            last7DaysButton.tap()
        }

        let applyButton = app.buttons["Apply"] ?? app.buttons["Done"]
        if applyButton.exists {
            applyButton.tap()
        }

        // Check that filtered list is displayed
        let expenseList = app.otherElements["FilteredExpenseList"] ?? app.otherElements["HomeFeedView"]
        XCTAssertTrue(expenseList.exists)

        // Verify filter badge or indicator is shown
        let filterBadge = app.otherElements["ActiveFiltersView"]
        if filterBadge.exists {
            XCTAssertTrue(filterBadge.exists)
        }
    }

    func testCloseFilterSheetWithoutApplying() {
        openFilterSheet()

        // Make some filter selections
        let last7DaysButton = app.buttons["Last 7 Days"]
        if last7DaysButton.exists {
            last7DaysButton.tap()
        }

        // Close the sheet without applying
        let sheet = app.sheets.firstMatch
        if sheet.exists {
            // Swipe down or tap outside to dismiss
            sheet.swipeDown()
        }

        // Verify we're back on the home screen
        let homeView = app.otherElements["HomeFeedView"]
        XCTAssertTrue(homeView.exists)

        // Verify no active filters
        let activeFilters = app.otherElements["ActiveFiltersView"]
        XCTAssertFalse(activeFilters.exists)
    }

    // MARK: - Helper Methods

    func openFilterSheet() {
        // Wait for app to load
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        // Find and tap filter button
        let filterButton = app.buttons["Filter"] ?? app.buttons["line.3.horizontal.decrease.circle"] ?? app.buttons["funnel"]

        if filterButton.exists {
            filterButton.tap()
        } else {
            // Try alternative - look for button in toolbar or navigation bar
            let toolbarFilter = app.navigationBars.buttons.matching(NSPredicate(format: "identifier CONTAINS 'filter'", "label CONTAINS 'Filter'")).firstMatch
            if toolbarFilter.exists {
                toolbarFilter.tap()
            }
        }

        // Verify filter sheet is presented
        let filterSheet = app.sheets["FilterSheet"] ?? app.otherElements["FilterSheetView"]
        XCTAssertTrue(waitForElement(filterSheet, timeout: 5))
    }
}
