import Foundation
import SwiftData

enum BudgetGoalType: String, Codable {
    case total
    case category
}

enum BudgetPeriod: String, Codable {
    case weekly
    case monthly
}

@Model
final class BudgetGoal {
    private var typeRawValue: String
    private var periodRawValue: String
    var limitAmount: Decimal
    var createdAt: Date
    
    @Relationship
    var tag: Tag?
    
    // Computed properties to access enums
    var type: BudgetGoalType {
        get { BudgetGoalType(rawValue: typeRawValue) ?? .total }
        set { typeRawValue = newValue.rawValue }
    }
    
    var period: BudgetPeriod {
        get { BudgetPeriod(rawValue: periodRawValue) ?? .monthly }
        set { periodRawValue = newValue.rawValue }
    }

    init(type: BudgetGoalType, period: BudgetPeriod, limitAmount: Decimal, tag: Tag? = nil) {
        self.typeRawValue = type.rawValue
        self.periodRawValue = period.rawValue
        self.limitAmount = limitAmount
        self.tag = tag
        self.createdAt = Date()
    }
}
