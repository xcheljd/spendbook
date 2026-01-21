import Foundation
import SwiftData

struct ExportableExpense: Codable {
    let date: Date
    let amount: Decimal
    let vendor: String
    let note: String?
    let paymentMethod: String?
    let tags: [String]
}

struct DataExportService {
    func generateCSV(from expenses: [Expense]) -> String {
        var csv = "Date,Amount,Vendor,Note,Payment Method,Tags\n"
        let formatter = ISO8601DateFormatter()

        for expense in expenses {
            let dateString = formatter.string(from: expense.date)
            let amountString = NSDecimalNumber(decimal: expense.amount).stringValue

            let rawVendor = expense.vendor
            let escapedVendor = rawVendor.replacingOccurrences(of: "\"", with: "\"\"")

            let rawNote = expense.note ?? ""
            let escapedNote = rawNote.replacingOccurrences(of: "\"", with: "\"\"")

            let paymentMethodName = expense.paymentMethod?.displayName ?? ""
            let escapedPaymentMethod = paymentMethodName.replacingOccurrences(of: "\"", with: "\"\"")

            let tagsString = (expense.tags ?? []).map { $0.name }.joined(separator: ";")

            let line = "\(dateString),\(amountString),\"\(escapedVendor)\",\"\(escapedNote)\",\"\(escapedPaymentMethod)\",\"\(tagsString)\"\n"
            csv.append(line)
        }
        return csv
    }

    func generateJSON(from expenses: [Expense]) throws -> Data {
        let exportableItems = expenses.map { expense in
            ExportableExpense(
                date: expense.date,
                amount: expense.amount,
                vendor: expense.vendor,
                note: expense.note,
                paymentMethod: expense.paymentMethod?.displayName,
                tags: (expense.tags ?? []).map { $0.name }
            )
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(exportableItems)
    }
}
