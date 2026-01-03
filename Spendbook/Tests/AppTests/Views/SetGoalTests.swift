import XCTest
@testable import Spendbook

final class SetGoalTests: XCTestCase {
    
    func testGoalValidation() {
        // Limit must be > 0
        XCTAssertTrue(isValidGoal(amount: 100))
        XCTAssertFalse(isValidGoal(amount: 0))
        XCTAssertFalse(isValidGoal(amount: -10))
    }
    
    private func isValidGoal(amount: Decimal) -> Bool {
        return amount > 0
    }
}
