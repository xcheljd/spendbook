import Foundation
import SwiftData
import WidgetKit

struct WidgetEntry: TimelineEntry {
    let date: Date
    let safeToSpend: Decimal
    let loggingStreak: Int
    let noSpendStreak: Int
    let last7DaysSpending: [DaySpending]
}

struct WidgetDataProvider {
    static let shared = WidgetDataProvider()
    
    private let container: ModelContainer?
    
    init() {
        let groupID = "group.com.spendbook.data"
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?
            .appendingPathComponent("Spendbook.sqlite")
        
        if let url {
            let config = ModelConfiguration(url: url)
            // Note: We include all relevant models for the shared container
            container = try? ModelContainer(for: Expense.self, Tag.self, BudgetGoal.self, configurations: config)
        } else {
            container = nil
        }
    }
    
    @MainActor
    func fetchLatestData() -> WidgetEntry {
        guard let context = container?.mainContext else {
            return WidgetEntry(date: Date(), safeToSpend: 0, loggingStreak: 0, noSpendStreak: 0, last7DaysSpending: [])
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        // 1. Fetch Expenses
        let expenseDescriptor = FetchDescriptor<Expense>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let expenses = (try? context.fetch(expenseDescriptor)) ?? []
        
        // 2. Fetch Goals
        let goalDescriptor = FetchDescriptor<BudgetGoal>()
        let goals = (try? context.fetch(goalDescriptor)) ?? []
        
        let accountabilityService = AccountabilityService()
        
        // 3. Calculate Monthly Spend
        let totalSpentMonth = expenses.filter { 
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }.reduce(Decimal(0)) { $0 + $1.amount }
        
        // 4. Calculate Safe-to-Spend
        var safeToSpendValue: Decimal = 0
        if let totalGoal = goals.first(where: { $0.type == .total && $0.period == .monthly }) {
            let range = calendar.range(of: .day, in: .month, for: now)!
            let dayOfMonth = calendar.component(.day, from: now)
            let daysRemaining = range.count - dayOfMonth + 1
            
            safeToSpendValue = accountabilityService.calculateDailySafeToSpend(
                totalBudget: totalGoal.limitAmount,
                currentSpend: totalSpentMonth,
                daysRemaining: daysRemaining
            )
        }
        
        // 5. Calculate Streaks
        let loggingStreak = accountabilityService.calculateStreak(from: expenses.map { $0.date })
        let noSpendStreak = accountabilityService.calculateNoSpendStreak(from: expenses)
        
        // 6. Aggregate Last 7 Days for Mini Chart
        let chartService = ChartDataService()
        let sevenDaysAgo = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -6, to: now)!)
        let chartData = chartService.aggregateExpensesByDay(expenses, in: sevenDaysAgo...now)
        
        return WidgetEntry(
            date: now,
            safeToSpend: safeToSpendValue,
            loggingStreak: loggingStreak,
            noSpendStreak: noSpendStreak,
            last7DaysSpending: chartData
        )
    }
}
