import Foundation
import SwiftData

struct RecurringExpenseService {
    private let calendar = Calendar.current
    
    /// Increments the next due date based on the frequency.
    func calculateNextDueDate(after current: Date, frequency: RecurringFrequency) -> Date {
        switch frequency {
        case .weekly:
            return calendar.date(byAdding: .day, value: 7, to: current) ?? current
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: current) ?? current
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: current) ?? current
        }
    }
    
    /// Converts a recurring expense to a standard expense record.
    /// Note: This method modifies the recurring expense's nextDueDate.
    func createExpense(from recurring: RecurringExpense) -> Expense {
        let expense = Expense(
            amount: recurring.amount,
            date: Date(),
            note: "Recurring: \(recurring.name)",
            tags: recurring.tag != nil ? [recurring.tag!] : []
        )
        
        // Update the next due date
        recurring.nextDueDate = calculateNextDueDate(after: recurring.nextDueDate, frequency: recurring.frequency)
        
        return expense
    }
}
