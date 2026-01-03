import XCTest
import SwiftData
@testable import Spendbook

@MainActor
final class DataManagerTests: XCTestCase {
    var modelContainer: ModelContainer!
    var dataManager: DataManager!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Expense.self, Tag.self, configurations: config)
        dataManager = DataManager(modelContext: modelContainer.mainContext)
    }

    func testSaveExpense() throws {
        let expense = Expense(amount: 50.00, date: Date())
        try dataManager.addExpense(expense)
        
        let fetchDescriptor = FetchDescriptor<Expense>()
        let expenses = try modelContainer.mainContext.fetch(fetchDescriptor)
        
        XCTAssertEqual(expenses.count, 1)
        XCTAssertEqual(expenses.first?.amount, 50.00)
    }
    
    func testDeleteExpense() throws {
        let expense = Expense(amount: 10.00, date: Date())
        try dataManager.addExpense(expense)
        try dataManager.deleteExpense(expense)
        
        let fetchDescriptor = FetchDescriptor<Expense>()
        let expenses = try modelContainer.mainContext.fetch(fetchDescriptor)
        
        XCTAssertTrue(expenses.isEmpty)
    }
}
