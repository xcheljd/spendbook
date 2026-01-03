import XCTest
@testable import Spendbook

final class GoalsDashboardTests: XCTestCase {
    
    func testProgressCalculation() {
        // Limit $100, Spent $25
        let limit: Decimal = 100
        let spent: Decimal = 25
        
        let progress = calculateProgress(spent: spent, limit: limit)
        XCTAssertEqual(progress, 0.25)
        
        // Limit $100, Spent $150 (Over budget)
        let overspent: Decimal = 150
        let overProgress = calculateProgress(spent: overspent, limit: limit)
        XCTAssertEqual(overProgress, 1.0) // Clamp to 1.0 for visual bar
    }
    
    private func calculateProgress(spent: Decimal, limit: Decimal) -> Double {
        let s = NSDecimalNumber(decimal: spent).doubleValue
        let l = NSDecimalNumber(decimal: limit).doubleValue
        return min(s / l, 1.0)
    }
}
