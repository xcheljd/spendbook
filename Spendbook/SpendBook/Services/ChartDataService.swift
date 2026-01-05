import Foundation
import SwiftData

struct DaySpending: Identifiable {
    let id = UUID()
    let date: Date
    let totalAmount: Decimal
}

struct CategorySpending: Identifiable {
    let id = UUID()
    let tagName: String
    let colorHex: String
    let totalAmount: Decimal
}

struct ChartDataService {
    private let calendar = Calendar.current
    
    /// Aggregates expenses by day within a specific date range.
    /// Fills missing days with 0.00.
    func aggregateExpensesByDay(_ expenses: [Expense], in range: ClosedRange<Date>) -> [DaySpending] {
        // 1. Group existing expenses by day
        let grouped = Dictionary(grouping: expenses) { expense in
            calendar.startOfDay(for: expense.date)
        }
        
        var result: [DaySpending] = []
        
        // 2. Iterate through every day in the range
        var currentDate = calendar.startOfDay(for: range.lowerBound)
        let endDate = calendar.startOfDay(for: range.upperBound)
        
        while currentDate <= endDate {
            let dayExpenses = grouped[currentDate] ?? []
            let total = dayExpenses.reduce(Decimal(0)) { $0 + $1.amount }
            
            result.append(DaySpending(date: currentDate, totalAmount: total))
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return result
    }
    
    /// Aggregates expenses by their primary (first) tag.
    func aggregateExpensesByCategory(_ expenses: [Expense]) -> [CategorySpending] {
        var categoryMap: [String: (color: String, total: Decimal)] = [:]
        var uncategorizedTotal: Decimal = 0
        
        for expense in expenses {
            if let firstTag = expense.tags?.first {
                let current = categoryMap[firstTag.name] ?? (color: firstTag.colorHex, total: 0)
                categoryMap[firstTag.name] = (color: current.color, total: current.total + expense.amount)
            } else {
                uncategorizedTotal += expense.amount
            }
        }
        
        var result = categoryMap.map { name, info in
            CategorySpending(tagName: name, colorHex: info.color, totalAmount: info.total)
        }
        
        if uncategorizedTotal > 0 {
            result.append(CategorySpending(
                tagName: "Uncategorized",
                colorHex: "#9399b2", // Default overlay0 color from Catppuccin
                totalAmount: uncategorizedTotal
            ))
        }
        
        // Sort by amount descending
        return result.sorted { $0.totalAmount > $1.totalAmount }
    }
}
