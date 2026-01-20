import Foundation
import SwiftData

/// Service for calculating future instances of recurring expenses and converting them to standard records.
struct RecurringExpenseService {
    private let calendar = Calendar.current
    
    /// Projects the next occurrence of a recurring expense based on its frequency.
    /// - Parameters:
    ///   - current: The current due date.
    ///   - frequency: The repetition interval (weekly, monthly, yearly).
    /// - Returns: The date of the next occurrence.
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
    
    /// Realizes a recurring expense by creating a permanent expense record and advancing the recurrence schedule.
    /// - Parameter recurring: The recurring template to process.
    /// - Returns: A new `Expense` record populated with data from the recurring template.
    /// - Note: This method has the side effect of modifying the `recurring.nextDueDate` property.
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
