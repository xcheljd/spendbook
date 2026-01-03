import XCTest
import SwiftData
@testable import Spendbook

final class ExpenseTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Expense.self, Tag.self, configurations: config)
        modelContext = modelContainer.mainContext
    }

    func testExpenseInitialization() throws {
        let expense = Expense(amount: 12.50, date: Date())
        modelContext.insert(expense)
        
        XCTAssertNotNil(expense.id)
        XCTAssertEqual(expense.amount, 12.50)
    }

    func testExpenseTagRelationship() throws {
        let tag = Tag(name: "Food", colorHex: "#FF0000")
        let expense = Expense(amount: 20.00, date: Date())
        
        modelContext.insert(tag)
        modelContext.insert(expense)
        
        expense.tags = [tag]
        
        XCTAssertEqual(expense.tags?.count, 1)
        XCTAssertEqual(expense.tags?.first?.name, "Food")
    }
}
