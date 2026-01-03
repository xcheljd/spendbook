import XCTest
import SwiftData
@testable import Spendbook

final class AccountabilityServiceTests: XCTestCase {
    
    // MARK: - Safe-to-Spend Tests
    
    func testSafeToSpendCalculation_Monthly() {
        let service = AccountabilityService()
        
        // Scenario: Monthly Budget $1000, Spent $200, Day 10 of 30
        let budget: Decimal = 1000
        let spent: Decimal = 200
        let daysRemaining = 20 // Approx
        
        let safe = service.calculateDailySafeToSpend(totalBudget: budget, currentSpend: spent, daysRemaining: daysRemaining)
        
        // (1000 - 200) / 20 = 40
        XCTAssertEqual(safe, 40)
    }
    
    func testSafeToSpend_OverBudget() {
        let service = AccountabilityService()
        
        let budget: Decimal = 500
        let spent: Decimal = 600
        let daysRemaining = 10
        
        let safe = service.calculateDailySafeToSpend(totalBudget: budget, currentSpend: spent, daysRemaining: daysRemaining)
        
        // Should be 0, not negative
        XCTAssertEqual(safe, 0)
    }
    
    // MARK: - Streak Tests
    
    func testStreakDetection_ConsecutiveDays() {
        let service = AccountabilityService()
        
        // Dates: Today, Yesterday, Day Before Yesterday
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let dayBefore = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        
        // Mock Expenses (Dates only matter)
        let dates = [today, yesterday, dayBefore]
        
        let streak = service.calculateStreak(from: dates)
        
        XCTAssertEqual(streak, 3)
    }
    
    func testStreakDetection_Gap() {
        let service = AccountabilityService()
        
        let today = Date()
        // Gap of one day
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        
        let dates = [today, threeDaysAgo]
        
        let streak = service.calculateStreak(from: dates)
        
        // Only today counts as streak 1 because series broke
        XCTAssertEqual(streak, 1)
    }
}
