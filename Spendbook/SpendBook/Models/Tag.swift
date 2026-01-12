import Foundation
import SwiftData

@Model
final class Tag {
    var name: String
    var colorHex: String
    var isActive: Bool
    var parent: Tag?
    @Relationship(deleteRule: .cascade, inverse: \Tag.parent)
    var children: [Tag]?
    
    @Relationship(inverse: \Expense.tags)
    var expenses: [Expense]?

    @Relationship(inverse: \BudgetGoal.tag)
    var budgetGoals: [BudgetGoal]?

    init(name: String, colorHex: String, parent: Tag? = nil, isActive: Bool = true) {
        self.name = name
        self.colorHex = colorHex
        self.isActive = isActive
        self.parent = parent
        self.children = []
        self.expenses = []
    }
    
    var fullName: String {
        if let parent = parent {
            return "\(parent.fullName) > \(name)"
        }
        return name
    }
    
    var expenseCount: Int {
        expenses?.count ?? 0
    }
    
    var hasExpenses: Bool {
        expenseCount > 0
    }
}
