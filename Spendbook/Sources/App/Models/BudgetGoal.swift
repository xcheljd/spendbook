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
    var type: BudgetGoalType
    var period: BudgetPeriod
    var limitAmount: Decimal
    var createdAt: Date
    
    @Relationship
    var tag: Tag?

    init(type: BudgetGoalType, period: BudgetPeriod, limitAmount: Decimal, tag: Tag? = nil) {
        self.type = type
        self.period = period
        self.limitAmount = limitAmount
        self.tag = tag
        self.createdAt = Date()
    }
}
