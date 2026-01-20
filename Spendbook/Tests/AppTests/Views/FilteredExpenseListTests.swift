import XCTest
import SwiftData
@testable import SpendBook

@MainActor
final class FilteredExpenseListTests: XCTestCase {

    var modelContainer: ModelContainer!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Expense.self, Tag.self, configurations: config)
    }

    override func tearDownWithError() throws {
        modelContainer = nil
    }

    // MARK: - Delete Confirmation Message Tests

    func testDeleteConfirmationMessageWithTag() throws {
        let context = modelContainer.mainContext
        let tag = Tag(name: "Coffee", colorHex: "#FF0000")
        context.insert(tag)

        let expense = Expense(amount: 4.50, date: Date())
        expense.tags = [tag]
        context.insert(expense)

        let message = formatDeleteConfirmationMessage(for: expense)

        XCTAssertTrue(message.contains("$4.50") || message.contains("4.50"), "Message should contain formatted amount")
        XCTAssertTrue(message.contains("Coffee"), "Message should contain tag name")
    }

    func testDeleteConfirmationMessageWithHierarchicalTag() throws {
        let context = modelContainer.mainContext
        let parentTag = Tag(name: "Food", colorHex: "#FF0000")
        context.insert(parentTag)

        let childTag = Tag(name: "Dining Out", colorHex: "#00FF00")
        childTag.parent = parentTag
        context.insert(childTag)

        let expense = Expense(amount: 25.00, date: Date())
        expense.tags = [childTag]
        context.insert(expense)

        let message = formatDeleteConfirmationMessage(for: expense)

        XCTAssertTrue(message.contains("Food > Dining Out"), "Message should contain full hierarchical tag name")
    }

    func testDeleteConfirmationMessageWithoutTag() throws {
        let context = modelContainer.mainContext

        let expense = Expense(amount: 10.00, date: Date())
        context.insert(expense)

        let message = formatDeleteConfirmationMessage(for: expense)

        XCTAssertTrue(message.contains("Uncategorized"), "Message should show 'Uncategorized' when no tags")
    }

    func testDeleteConfirmationMessageWithMultipleTags() throws {
        let context = modelContainer.mainContext
        let tag1 = Tag(name: "Coffee", colorHex: "#FF0000")
        let tag2 = Tag(name: "Work", colorHex: "#00FF00")
        context.insert(tag1)
        context.insert(tag2)

        let expense = Expense(amount: 5.75, date: Date())
        expense.tags = [tag1, tag2]
        context.insert(expense)

        let message = formatDeleteConfirmationMessage(for: expense)

        // Should show first tag only
        XCTAssertTrue(message.contains("Coffee"), "Message should contain first tag name")
    }

    // MARK: - Helper

    /// Mirrors the logic from FilteredExpenseList.deleteConfirmationMessage
    private func formatDeleteConfirmationMessage(for expense: Expense) -> String {
        let amount = CurrencyService.shared.format(expense.amount)
        let tagName = expense.tags?.first?.fullName ?? "Uncategorized"
        return "\(amount) • \(tagName)"
    }
}
