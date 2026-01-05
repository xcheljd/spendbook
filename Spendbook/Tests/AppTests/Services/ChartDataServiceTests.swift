import XCTest
import SwiftData
@testable import SpendBook

@MainActor
final class ChartDataServiceTests: XCTestCase {
    
    // Helper to create date
    func date(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
    
    func testAggregateByDay() {
        let service = ChartDataService()
        let day1 = date(year: 2025, month: 1, day: 1)
        let day2 = date(year: 2025, month: 1, day: 2)
        let day3 = date(year: 2025, month: 1, day: 3)
        
        // Expense 1: Day 1, $10
        // Expense 2: Day 1, $20
        // Expense 3: Day 3, $50
        // Day 2 is empty
        
        let expenses = [
            Expense(amount: 10, date: day1),
            Expense(amount: 20, date: day1),
            Expense(amount: 50, date: day3)
        ]
        
        // We define the range explicitly to force zero-filling
        let result = service.aggregateExpensesByDay(expenses, in: day1...day3)
        
        XCTAssertEqual(result.count, 3)
        
        // Sort by date to verify
        let sorted = result.sorted { $0.date < $1.date }
        
        XCTAssertEqual(sorted[0].totalAmount, 30)
        XCTAssertEqual(sorted[1].totalAmount, 0) // Day 2 filled
        XCTAssertEqual(sorted[2].totalAmount, 50)
    }
    
    func testAggregateByTag() {
        let service = ChartDataService()
        let now = Date()
        
        let tag1 = Tag(name: "Food", colorHex: "#FF0000")
        let tag2 = Tag(name: "Transport", colorHex: "#00FF00")
        
        let expenses = [
            Expense(amount: 10, date: now, tags: [tag1]),
            Expense(amount: 20, date: now, tags: [tag1]),
            Expense(amount: 50, date: now, tags: [tag2]),
            Expense(amount: 5, date: now, tags: []) // Uncategorized
        ]
        
        let result = service.aggregateExpensesByCategory(expenses)
        
        // Expect: Food (30), Transport (50), Uncategorized (5)
        XCTAssertEqual(result.count, 3)
        
        let food = result.first { $0.tagName == "Food" }
        XCTAssertEqual(food?.totalAmount, 30)
        
        let transport = result.first { $0.tagName == "Transport" }
        XCTAssertEqual(transport?.totalAmount, 50)
        
        let uncategorized = result.first { $0.tagName == "Uncategorized" }
        XCTAssertEqual(uncategorized?.totalAmount, 5)
    }
}
