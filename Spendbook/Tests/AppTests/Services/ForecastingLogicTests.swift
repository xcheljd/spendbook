import XCTest
@testable import SpendBook

@MainActor
final class ForecastingLogicTests: XCTestCase {
    let service = AccountabilityService()
    
    func testProjectedSpend() {
        // Spent $100 in 10 days of a 30-day month
        let projected = service.calculateProjectedMonthlySpend(currentSpend: 100, daysPassed: 10, totalDaysInMonth: 30)
        XCTAssertEqual(projected, 300)
    }
    
    func testBudgetExhaustionDate() {
        // Goal $1000, Spent $500 in 10 days ($50/day)
        // Remaining $500. $500 / $50 = 10 days left.
        let exhaustionDate = service.calculateBudgetExhaustionDate(totalBudget: 1000, currentSpend: 500, daysPassed: 10)
        XCTAssertNotNil(exhaustionDate)

        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: exhaustionDate!).day ?? 0
        // Allow ±1 day tolerance due to ceil() rounding and date boundary timing
        XCTAssertTrue((9...11).contains(daysUntil), "Expected ~10 days, got \(daysUntil)")
    }
}
