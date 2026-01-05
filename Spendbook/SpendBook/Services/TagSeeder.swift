import Foundation
import SwiftData

@MainActor
struct TagSeeder {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func seedDefaultTags() {
        let descriptor = FetchDescriptor<Tag>()
        let existingTags = (try? modelContext.fetchCount(descriptor)) ?? 0
        
        guard existingTags == 0 else { return }
        
        createAllTags()
    }
    
    func seedDefaultTagsWithoutDuplicates() {
        let descriptor = FetchDescriptor<Tag>()
        let existingTags: [Tag] = (try? modelContext.fetch(descriptor)) ?? []
        let existingNames = Set(existingTags.map { $0.name.lowercased() })
        
        let allTags = createAllTags()
        for tag in allTags {
            if !existingNames.contains(tag.name.lowercased()) {
                modelContext.insert(tag)
            }
        }
        
        try? modelContext.save()
    }
    
    @discardableResult
    private func createAllTags() -> [Tag] {
        let food = createTagInMemory(name: "Food", colorHex: "#F9E2AF")
        let transport = createTagInMemory(name: "Transport", colorHex: "#89B4FA")
        let entertainment = createTagInMemory(name: "Entertainment", colorHex: "#CBA6F7")
        let shopping = createTagInMemory(name: "Shopping", colorHex: "#FAB387")
        let utilities = createTagInMemory(name: "Utilities", colorHex: "#74C7EC")
        let healthcare = createTagInMemory(name: "Healthcare", colorHex: "#A6E3A1")
        let income = createTagInMemory(name: "Income", colorHex: "#A6E3A1")
        
        let diningOut = createTagInMemory(name: "Dining Out", colorHex: "#F9E2AF", parent: food)
        let groceries = createTagInMemory(name: "Groceries", colorHex: "#F9E2AF", parent: food)
        let coffee = createTagInMemory(name: "Coffee", colorHex: "#F9E2AF", parent: food)
        
        let publicTransit = createTagInMemory(name: "Public Transit", colorHex: "#89B4FA", parent: transport)
        let rideshare = createTagInMemory(name: "Rideshare", colorHex: "#89B4FA", parent: transport)
        let gas = createTagInMemory(name: "Gas", colorHex: "#89B4FA", parent: transport)
        
        let movies = createTagInMemory(name: "Movies", colorHex: "#CBA6F7", parent: entertainment)
        let music = createTagInMemory(name: "Music", colorHex: "#CBA6F7", parent: entertainment)
        let games = createTagInMemory(name: "Games", colorHex: "#CBA6F7", parent: entertainment)
        
        let clothing = createTagInMemory(name: "Clothing", colorHex: "#FAB387", parent: shopping)
        let electronics = createTagInMemory(name: "Electronics", colorHex: "#FAB387", parent: shopping)
        let gifts = createTagInMemory(name: "Gifts", colorHex: "#FAB387", parent: shopping)
        
        let electricity = createTagInMemory(name: "Electricity", colorHex: "#74C7EC", parent: utilities)
        let internet = createTagInMemory(name: "Internet", colorHex: "#74C7EC", parent: utilities)
        let phone = createTagInMemory(name: "Phone", colorHex: "#74C7EC", parent: utilities)
        
        let pharmacy = createTagInMemory(name: "Pharmacy", colorHex: "#A6E3A1", parent: healthcare)
        let doctor = createTagInMemory(name: "Doctor", colorHex: "#A6E3A1", parent: healthcare)
        let insurance = createTagInMemory(name: "Insurance", colorHex: "#A6E3A1", parent: healthcare)
        
        let salary = createTagInMemory(name: "Salary", colorHex: "#A6E3A1", parent: income)
        let freelance = createTagInMemory(name: "Freelance", colorHex: "#A6E3A1", parent: income)
        
        try? modelContext.save()
        
        return [food, transport, entertainment, shopping, utilities, healthcare, income,
                diningOut, groceries, coffee, publicTransit, rideshare, gas,
                movies, music, games, clothing, electronics, gifts,
                electricity, internet, phone, pharmacy, doctor, insurance,
                salary, freelance]
    }
    
    private func createTagInMemory(name: String, colorHex: String, parent: Tag? = nil) -> Tag {
        let tag = Tag(name: name, colorHex: colorHex, parent: parent)
        return tag
    }
}
