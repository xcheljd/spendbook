import Foundation
import SwiftData

@Model
final class Tag {
    var name: String
    var colorHex: String
    var parent: Tag?
    @Relationship(deleteRule: .cascade, inverse: \Tag.parent)
    var children: [Tag]?
    
    @Relationship(inverse: \Expense.tags)
    var expenses: [Expense]?

    @Relationship(inverse: \BudgetGoal.tag)
    var budgetGoals: [BudgetGoal]?

    init(name: String, colorHex: String, parent: Tag? = nil) {
        self.name = name
        self.colorHex = colorHex
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
}
