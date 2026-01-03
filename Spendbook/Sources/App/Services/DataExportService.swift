import Foundation
import SwiftData

struct ExportableExpense: Codable {
    let date: Date
    let amount: Decimal
    let note: String?
    let tags: [String]
}

struct DataExportService {
    func generateCSV(from expenses: [Expense]) -> String {
        var csv = "Date,Amount,Note,Tags\n"
        let formatter = ISO8601DateFormatter()
        
        for expense in expenses {
            let dateString = formatter.string(from: expense.date)
            // Use standard number formatting to ensure consistent CSV output (no currency symbols ideally)
            // Using .number ensures we get just the value.
            let amountString = NSDecimalNumber(decimal: expense.amount).stringValue
            
            // Escape note for CSV (quotes)
            let rawNote = expense.note ?? ""
            let escapedNote = rawNote.replacingOccurrences(of: "\"", with: "\"\"")
            
            let tagsString = (expense.tags ?? []).map { $0.name }.joined(separator: ";")
            
            let line = "\(dateString),\(amountString),\"\(escapedNote)\",\"\(tagsString)\"\n"
            csv.append(line)
        }
        return csv
    }
    
    func generateJSON(from expenses: [Expense]) throws -> Data {
        let exportableItems = expenses.map {
            ExportableExpense(
                date: expense.date,
                amount: expense.amount,
                note: expense.note,
                tags: (expense.tags ?? []).map { $0.name }
            )
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(exportableItems)
    }
}