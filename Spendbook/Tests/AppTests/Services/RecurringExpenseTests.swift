import XCTest
@testable import Spendbook

final class RecurringExpenseTests: XCTestCase {
    let calendar = Calendar.current
    
    func testNextDueDateCalculation() {
        let service = RecurringExpenseService()
        let start = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        
        // Weekly
        let nextWeekly = service.calculateNextDueDate(after: start, frequency: .weekly)
        XCTAssertEqual(calendar.component(.day, from: nextWeekly), 8)
        
        // Monthly
        let nextMonthly = service.calculateNextDueDate(after: start, frequency: .monthly)
        XCTAssertEqual(calendar.component(.month, from: nextMonthly), 2)
        
        // Yearly
        let nextYearly = service.calculateNextDueDate(after: start, frequency: .yearly)
        XCTAssertEqual(calendar.component(.year, from: nextYearly), 2026)
    }
    
    func testCreateExpenseFromRecurring() {
        let service = RecurringExpenseService()
        let start = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let recurring = RecurringExpense(name: "Rent", amount: 1000, frequency: .monthly, startDate: start)
        
        let expense = service.createExpense(from: recurring)
        
        XCTAssertEqual(expense.amount, 1000)
        XCTAssertEqual(expense.note, "Recurring: Rent")
        
        // Verify next due date updated
        XCTAssertEqual(calendar.component(.month, from: recurring.nextDueDate), 2)
    }
}
