import Foundation
import SwiftData

@MainActor
class DataManager: ObservableObject {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func addExpense(_ expense: Expense) throws {
        modelContext.insert(expense)
        try modelContext.save()
    }
    
    func deleteExpense(_ expense: Expense) throws {
        modelContext.delete(expense)
        try modelContext.save()
    }
    
    func addTag(_ tag: Tag) throws {
        modelContext.insert(tag)
        try modelContext.save()
    }
    
    // Future expansion: Fetch methods usually happen via @Query in Views, 
    // but explicit fetches can be added here if needed for logic.
}
