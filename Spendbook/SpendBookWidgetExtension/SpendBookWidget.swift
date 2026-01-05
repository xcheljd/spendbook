import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// MARK: - Widget Entry
struct SpendBookEntry: TimelineEntry {
    let date: Date
    let todaySpending: Decimal
    let monthlySpending: Decimal
    let monthlyBudget: Decimal?
    let configuration: SpendBookWidgetIntent
}

// MARK: - App Intent for Widget Configuration
struct SpendBookWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Spending Widget"
    static let description = IntentDescription("View your spending summary")
    
    @Parameter(title: "Show Budget", default: true)
    var showBudget: Bool?
    
    init(showBudget: Bool?) {
        self.showBudget = showBudget
    }
    
    init() {
        self.showBudget = true
    }
}

// MARK: - Timeline Provider
struct SpendBookWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = SpendBookEntry
    typealias Intent = SpendBookWidgetIntent
    
    // Create the model container for widget access
    private var modelContainer: ModelContainer = {
        let schema = Schema([
            Expense.self,
            Tag.self,
            BudgetGoal.self,
        ])
        
        let url = URL.documentsDirectory.appendingPathComponent("Spendbook.sqlite")
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: url,
            cloudKitDatabase: .none
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer for widget: \(error)")
        }
    }()
    
    func placeholder(in context: Context) -> SpendBookEntry {
        SpendBookEntry(
            date: Date(),
            todaySpending: 0,
            monthlySpending: 0,
            monthlyBudget: nil,
            configuration: SpendBookWidgetIntent()
        )
    }
    
    func snapshot(for configuration: SpendBookWidgetIntent, in context: Context) async -> SpendBookEntry {
        if context.isPreview {
            return SpendBookEntry(
                date: Date(),
                todaySpending: 45.50,
                monthlySpending: 1234.56,
                monthlyBudget: 2000.00,
                configuration: configuration
            )
        }
        
        return await fetchEntry(for: configuration)
    }
    
    func timeline(for configuration: SpendBookWidgetIntent, in context: Context) async -> Timeline<SpendBookEntry> {
        let entry = await fetchEntry(for: configuration)
        
        // Update at midnight to show new day
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        
        return Timeline(entries: [entry], policy: .after(midnight))
    }
    
    private func fetchEntry(for configuration: SpendBookWidgetIntent) async -> SpendBookEntry {
        let context = ModelContext(modelContainer)
        
        let calendar = Calendar.current
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        // Fetch today's expenses
        let todayDescriptor = FetchDescriptor<Expense>(
            predicate: #Predicate<Expense> { expense in
                expense.date >= todayStart
            }
        )
        
        // Fetch this month's expenses
        let monthDescriptor = FetchDescriptor<Expense>(
            predicate: #Predicate<Expense> { expense in
                expense.date >= monthStart
            }
        )
        
        // Fetch monthly budget goal
        let budgetDescriptor = FetchDescriptor<BudgetGoal>(
            predicate: #Predicate<BudgetGoal> { goal in
                goal.type.rawValue == "total" && goal.period.rawValue == "monthly"
            }
        )
        
        do {
            let todayExpenses = try context.fetch(todayDescriptor)
            let monthExpenses = try context.fetch(monthDescriptor)
            let budgetGoals = try context.fetch(budgetDescriptor)
            
            let todayTotal = todayExpenses.reduce(Decimal.zero) { $0 + $1.amount }
            let monthTotal = monthExpenses.reduce(Decimal.zero) { $0 + $1.amount }
            let monthlyBudget = (configuration.showBudget ?? true) ? budgetGoals.first?.limitAmount : nil
            
            return SpendBookEntry(
                date: now,
                todaySpending: todayTotal,
                monthlySpending: monthTotal,
                monthlyBudget: monthlyBudget,
                configuration: configuration
            )
        } catch {
            print("Widget fetch error: \(error)")
            return SpendBookEntry(
                date: now,
                todaySpending: 0,
                monthlySpending: 0,
                monthlyBudget: nil,
                configuration: configuration
            )
        }
    }
}

// MARK: - Widget Views
struct SpendBookWidgetSmallView: View {
    let entry: SpendBookEntry
    private let currencyService = CurrencyService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.caption)
                .foregroundColor(Color.Catppuccin.subtext0)
            
            Text(currencyService.format(entry.todaySpending))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.Catppuccin.text)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            
            Spacer()
            
            HStack {
                Image(systemName: "calendar")
                    .font(.caption2)
                Text(entry.date, style: .date)
                    .font(.caption2)
            }
            .foregroundColor(Color.Catppuccin.subtext0)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.Catppuccin.base)
    }
}

struct SpendBookWidgetMediumView: View {
    let entry: SpendBookEntry
    private let currencyService = CurrencyService.shared
    
    var budgetProgress: Double {
        guard let budget = entry.monthlyBudget, budget > 0 else { return 0 }
        return min(Double(truncating: entry.monthlySpending as NSNumber) / Double(truncating: budget as NSNumber), 1.0)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Today's spending
            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.caption)
                    .foregroundColor(Color.Catppuccin.subtext0)
                
                Text(currencyService.format(entry.todaySpending))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.Catppuccin.text)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .background(Color.Catppuccin.overlay0)
            
            // Monthly spending
            VStack(alignment: .leading, spacing: 4) {
                Text("This Month")
                    .font(.caption)
                    .foregroundColor(Color.Catppuccin.subtext0)
                
                Text(currencyService.format(entry.monthlySpending))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.Catppuccin.text)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                
                if entry.monthlyBudget != nil {
                    HStack(spacing: 4) {
                        ProgressView(value: budgetProgress)
                            .tint(budgetProgress < 0.8 ? Color.Catppuccin.green : 
                                  budgetProgress < 1.0 ? Color.Catppuccin.yellow : Color.Catppuccin.red)
                        
                        Text("\(Int(budgetProgress * 100))%")
                            .font(.caption2)
                            .foregroundColor(Color.Catppuccin.subtext0)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Catppuccin.base)
    }
}

struct SpendBookWidgetLargeView: View {
    let entry: SpendBookEntry
    private let currencyService = CurrencyService.shared
    
    var budgetProgress: Double {
        guard let budget = entry.monthlyBudget, budget > 0 else { return 0 }
        return min(Double(truncating: entry.monthlySpending as NSNumber) / Double(truncating: budget as NSNumber), 1.0)
    }
    
    var remainingBudget: Decimal {
        guard let budget = entry.monthlyBudget else { return 0 }
        return max(budget - entry.monthlySpending, 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Spending")
                        .font(.headline)
                        .foregroundColor(Color.Catppuccin.text)
                    Text(entry.date, style: .date)
                        .font(.caption)
                        .foregroundColor(Color.Catppuccin.subtext0)
                }
                
                Spacer()
                
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color.Catppuccin.blue)
            }
            
            // Today's spending
            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.subheadline)
                    .foregroundColor(Color.Catppuccin.subtext0)
                
                Text(currencyService.format(entry.todaySpending))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.Catppuccin.text)
            }
            
            Divider()
                .background(Color.Catppuccin.overlay0)
            
            // Monthly spending with budget
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("This Month")
                        .font(.subheadline)
                        .foregroundColor(Color.Catppuccin.subtext0)
                    
                    Spacer()
                    
                    Text(currencyService.format(entry.monthlySpending))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.Catppuccin.text)
                }
                
                if let budget = entry.monthlyBudget {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Budget")
                                .font(.caption)
                                .foregroundColor(Color.Catppuccin.subtext0)
                            Spacer()
                            Text(currencyService.format(budget))
                                .font(.caption)
                                .foregroundColor(Color.Catppuccin.subtext0)
                        }
                        
                        ProgressView(value: budgetProgress)
                            .tint(budgetProgress < 0.8 ? Color.Catppuccin.green : 
                                  budgetProgress < 1.0 ? Color.Catppuccin.yellow : Color.Catppuccin.red)
                        
                        HStack {
                            Text(budgetProgress >= 1.0 ? "Over Budget" : "Remaining")
                                .font(.caption2)
                                .foregroundColor(Color.Catppuccin.subtext0)
                            Spacer()
                            Text(currencyService.format(remainingBudget))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(budgetProgress < 0.8 ? Color.Catppuccin.green : 
                                              budgetProgress < 1.0 ? Color.Catppuccin.yellow : Color.Catppuccin.red)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.Catppuccin.base)
    }
}

// MARK: - Widget Configuration
struct SpendBookWidget: Widget {
    let kind: String = "SpendBookWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SpendBookWidgetIntent.self, provider: SpendBookWidgetProvider()) { entry in
            SpendBookWidgetEntryView(entry: entry)
                .containerBackground(Color.Catppuccin.base, for: .widget)
        }
        .configurationDisplayName("Spending Summary")
        .description("Track your daily and monthly spending at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct SpendBookWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: SpendBookEntry
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SpendBookWidgetSmallView(entry: entry)
            case .systemMedium:
                SpendBookWidgetMediumView(entry: entry)
            case .systemLarge:
                SpendBookWidgetLargeView(entry: entry)
            default:
                SpendBookWidgetSmallView(entry: entry)
            }
        }
        .widgetURL(URL(string: "spendbook://home"))
    }
}

// MARK: - Widget Bundle
@main
struct SpendBookWidgets: WidgetBundle {
    var body: some Widget {
        SpendBookWidget()
        QuickAddWidget()
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    SpendBookWidget()
} timeline: {
    SpendBookEntry(
        date: Date(),
        todaySpending: 45.50,
        monthlySpending: 1234.56,
        monthlyBudget: 2000.00,
        configuration: SpendBookWidgetIntent()
    )
}

#Preview(as: .systemMedium) {
    SpendBookWidget()
} timeline: {
    SpendBookEntry(
        date: Date(),
        todaySpending: 45.50,
        monthlySpending: 1234.56,
        monthlyBudget: 2000.00,
        configuration: SpendBookWidgetIntent()
    )
}

#Preview(as: .systemLarge) {
    SpendBookWidget()
} timeline: {
    SpendBookEntry(
        date: Date(),
        todaySpending: 45.50,
        monthlySpending: 1834.23,
        monthlyBudget: 2000.00,
        configuration: SpendBookWidgetIntent()
    )
}
