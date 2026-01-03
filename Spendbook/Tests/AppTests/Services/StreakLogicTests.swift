import XCTest
@testable import Spendbook

final class StreakLogicTests: XCTestCase {
    let calendar = Calendar.current
    
    func date(daysAgo: Int) -> Date {
        calendar.startOfDay(for: calendar.date(byAdding: .day, value: -daysAgo, to: Date())!)
    }
    
    func testNoSpendStreak() {
        let service = AccountabilityService()
        
        // Scenario 1: Spent money today
        let expenses1 = [Expense(amount: 10, date: Date())]
        XCTAssertEqual(service.calculateNoSpendStreak(from: expenses1), 0)
        
        // Scenario 2: No spend today, spent yesterday
        let expenses2 = [Expense(amount: 10, date: date(daysAgo: 1))]
        XCTAssertEqual(service.calculateNoSpendStreak(from: expenses2), 1)
        
        // Scenario 3: No spend for 3 days, spent 3 days ago
        let expenses3 = [Expense(amount: 10, date: date(daysAgo: 3))]
        // Days ago: 0 (today), 1, 2 were no-spend.
        XCTAssertEqual(service.calculateNoSpendStreak(from: expenses3), 3)
    }
    
    func testLoggingStreakRefinement() {
        let service = AccountabilityService()
        
        // Scenario: Multiple entries same day should count as 1 day
        let d = Date()
        let expenses = [
            Expense(amount: 10, date: d),
            Expense(amount: 5, date: d),
            Expense(amount: 20, date: calendar.date(byAdding: .day, value: -1, to: d)!)
        ]
        XCTAssertEqual(service.calculateStreak(from: expenses.map { $0.date }), 2)
    }
}
