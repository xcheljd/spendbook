import Foundation
import SwiftData

enum RecurringFrequency: String, Codable, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var id: String { rawValue }
}

@Model
final class RecurringExpense {
    var name: String
    var amount: Decimal
    var frequency: RecurringFrequency
    var startDate: Date
    var nextDueDate: Date
    
    @Relationship
    var tag: Tag?

    init(name: String, amount: Decimal, frequency: RecurringFrequency, startDate: Date = Date(), tag: Tag? = nil) {
        self.name = name
        self.amount = amount
        self.frequency = frequency
        self.startDate = startDate
        self.nextDueDate = startDate
        self.tag = tag
    }
}
