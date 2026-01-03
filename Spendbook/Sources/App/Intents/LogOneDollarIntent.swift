import AppIntents
import SwiftData
import WidgetKit

struct LogOneDollarIntent: AppIntent {
    static var title: LocalizedStringResource = "Log $1.00"
    static var description = IntentDescription("Quickly log a $1.00 expense.")

    @MainActor
    func perform() async throws -> some IntentResult {
        let groupID = "group.com.spendbook.data"
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?
            .appendingPathComponent("Spendbook.sqlite")
        
        guard let url else { return .result() }
        
        let config = ModelConfiguration(url: url)
        let container = try ModelContainer(for: Expense.self, Tag.self, BudgetGoal.self, configurations: config)
        let context = container.mainContext
        
        // Find or create a "Quick Log" tag
        let tagName = "Quick Log"
        let tagFetch = FetchDescriptor<Tag>(predicate: #Predicate { $0.name == tagName })
        let tags = (try? context.fetch(tagFetch)) ?? []
        let tag = tags.first ?? Tag(name: tagName, colorHex: "#89b4fa")
        
        if tags.isEmpty {
            context.insert(tag)
        }
        
        let expense = Expense(amount: 1.00, date: Date(), note: "Quick Widget Log", tags: [tag])
        context.insert(expense)
        
        try? context.save()
        
        // Reload widgets to reflect new spend and streaks
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}
