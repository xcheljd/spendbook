import XCTest
import SwiftData
@testable import Spendbook

final class BudgetGoalTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // Note: BudgetGoal doesn't exist yet, so this will fail to compile
        modelContainer = try ModelContainer(for: BudgetGoal.self, Tag.self, configurations: config)
        modelContext = modelContainer.mainContext
    }

    func testBudgetGoalInitialization() throws {
        let limit: Decimal = 500.0
        let goal = BudgetGoal(type: .total, period: .monthly, limitAmount: limit)
        modelContext.insert(goal)
        
        XCTAssertNotNil(goal.id)
        XCTAssertEqual(goal.limitAmount, limit)
        XCTAssertEqual(goal.type, .total)
        XCTAssertEqual(goal.period, .monthly)
    }

    func testBudgetGoalTagRelationship() throws {
        let tag = Tag(name: "Entertainment", colorHex: "#8800FF")
        let limit: Decimal = 100.0
        let goal = BudgetGoal(type: .category, period: .weekly, limitAmount: limit, tag: tag)
        
        modelContext.insert(tag)
        modelContext.insert(goal)
        
        XCTAssertEqual(goal.tag?.name, "Entertainment")
        XCTAssertEqual(tag.budgetGoals?.count, 1)
    }
}
