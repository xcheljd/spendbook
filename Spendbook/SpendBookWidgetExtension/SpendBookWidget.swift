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
    let loggingStreak: Int
    let noSpendStreak: Int
    let averageDailySpend: Decimal

    init(
        date: Date,
        todaySpending: Decimal,
        monthlySpending: Decimal,
        monthlyBudget: Decimal?,
        configuration: SpendBookWidgetIntent,
        loggingStreak: Int = 0,
        noSpendStreak: Int = 0,
        averageDailySpend: Decimal = 0
    ) {
        self.date = date
        self.todaySpending = todaySpending
        self.monthlySpending = monthlySpending
        self.monthlyBudget = monthlyBudget
        self.configuration = configuration
        self.loggingStreak = loggingStreak
        self.noSpendStreak = noSpendStreak
        self.averageDailySpend = averageDailySpend
    }
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
            configuration: SpendBookWidgetIntent(),
            loggingStreak: 0,
            noSpendStreak: 0,
            averageDailySpend: 0
        )
    }

    func snapshot(for configuration: SpendBookWidgetIntent, in context: Context) async -> SpendBookEntry {
        if context.isPreview {
            return SpendBookEntry(
                date: Date(),
                todaySpending: 45.50,
                monthlySpending: 1234.56,
                monthlyBudget: 2000.00,
                configuration: configuration,
                loggingStreak: 7,
                noSpendStreak: 2,
                averageDailySpend: 58.25
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
        // Note: Can't use enum comparison in #Predicate, so we fetch all and filter
        let budgetDescriptor = FetchDescriptor<BudgetGoal>()

        // Fetch last 30 days for streak calculation
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
        let recentDescriptor = FetchDescriptor<Expense>(
            predicate: #Predicate<Expense> { expense in
                expense.date >= thirtyDaysAgo
            }
        )

        do {
            let todayExpenses = try context.fetch(todayDescriptor)
            let monthExpenses = try context.fetch(monthDescriptor)
            let budgetGoals = try context.fetch(budgetDescriptor)
            let recentExpenses = try context.fetch(recentDescriptor)

            let todayTotal = todayExpenses.reduce(Decimal(0)) { $0 + $1.amount }
            let monthTotal = monthExpenses.reduce(Decimal(0)) { $0 + $1.amount }

            // Filter for monthly total budget in-memory (SwiftData can't filter enums in predicates)
            let monthlyTotalBudget = budgetGoals.first { $0.type == .total && $0.period == .monthly }
            let monthlyBudget = (configuration.showBudget ?? true) ? monthlyTotalBudget?.limitAmount : nil

            // Calculate streaks
            let (loggingStreak, noSpendStreak) = calculateStreaks(expenses: recentExpenses, calendar: calendar, now: now)

            // Calculate average daily spend (last 30 days)
            let totalRecent = recentExpenses.reduce(Decimal(0)) { $0 + $1.amount }
            let daysWithData = Set(recentExpenses.map { calendar.startOfDay(for: $0.date) }).count
            let averageDailySpend = daysWithData > 0 ? totalRecent / Decimal(daysWithData) : 0

            return SpendBookEntry(
                date: now,
                todaySpending: todayTotal,
                monthlySpending: monthTotal,
                monthlyBudget: monthlyBudget,
                configuration: configuration,
                loggingStreak: loggingStreak,
                noSpendStreak: noSpendStreak,
                averageDailySpend: averageDailySpend
            )
        } catch {
            print("Widget fetch error: \(error)")
            return SpendBookEntry(
                date: now,
                todaySpending: 0,
                monthlySpending: 0,
                monthlyBudget: nil,
                configuration: configuration,
                loggingStreak: 0,
                noSpendStreak: 0,
                averageDailySpend: 0
            )
        }
    }

    private func calculateStreaks(expenses: [Expense], calendar: Calendar, now: Date) -> (logging: Int, noSpend: Int) {
        // If there are no expenses at all, both streaks should be 0
        guard !expenses.isEmpty else {
            return (0, 0)
        }
        
        // Group expenses by day
        var expensesByDay: [Date: [Expense]] = [:]
        for expense in expenses {
            let day = calendar.startOfDay(for: expense.date)
            expensesByDay[day, default: []].append(expense)
        }

        // Calculate logging streak (consecutive days with logged expenses)
        var loggingStreak = 0
        var checkDate = calendar.startOfDay(for: now)

        // Include today if there are expenses
        if expensesByDay[checkDate] != nil {
            loggingStreak = 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        while let _ = expensesByDay[checkDate] {
            loggingStreak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        // Calculate no-spend streak (consecutive days with $0 spending)
        // Key insight: You can only have a no-spend day if:
        // 1. Today has no expenses AND
        // 2. Yesterday had expenses (so you know you're actively tracking)
        var noSpendStreak = 0
        checkDate = calendar.startOfDay(for: now)
        
        // First, check if today is a no-spend day
        let todayHasNoExpenses = expensesByDay[checkDate] == nil || expensesByDay[checkDate]!.isEmpty
        
        guard todayHasNoExpenses else {
            // If today has expenses, no-spend streak is 0
            return (loggingStreak, 0)
        }
        
        // Today has no expenses. Now find when we last logged an expense
        var foundLastExpenseDay = false
        var tempCheckDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        
        // Look back to find the most recent day with expenses
        for _ in 0..<30 {
            if expensesByDay[tempCheckDate] != nil && !expensesByDay[tempCheckDate]!.isEmpty {
                foundLastExpenseDay = true
                break
            }
            tempCheckDate = calendar.date(byAdding: .day, value: -1, to: tempCheckDate)!
        }
        
        // If we never found a day with expenses, there's no tracking happening
        // so no-spend streak should be 0
        guard foundLastExpenseDay else {
            return (loggingStreak, 0)
        }
        
        // Now count consecutive no-spend days from today backwards
        // until we hit a day with expenses
        checkDate = calendar.startOfDay(for: now)
        while expensesByDay[checkDate] == nil || expensesByDay[checkDate]!.isEmpty {
            noSpendStreak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            
            // Cap at 30 days to prevent infinite loop
            if noSpendStreak >= 30 { break }
        }

        return (loggingStreak, noSpendStreak)
    }
}

// MARK: - Widget Views
struct SpendBookWidgetSmallView: View {
    let entry: SpendBookEntry
    private let currencyService = CurrencyService.shared

    var budgetProgress: Double {
        guard let budget = entry.monthlyBudget, budget > 0 else { return 0 }
        return min(Double(truncating: entry.monthlySpending as NSNumber) / Double(truncating: budget as NSNumber), 1.2)
    }

    var heroColor: Color {
        if entry.monthlyBudget == nil { return Color.Catppuccin.text }
        if budgetProgress < 0.8 { return Color.Catppuccin.green }
        else if budgetProgress < 1.0 { return Color.Catppuccin.peach }
        else { return Color.Catppuccin.red }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top section - Today's spending
            VStack(alignment: .leading, spacing: 4) {
                Text("TODAY")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .foregroundStyle(Color.Catppuccin.subtext0)

                Text(currencyService.format(entry.todaySpending))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(heroColor)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Bottom section - Arc progress + status
            if entry.monthlyBudget != nil {
                VStack(spacing: 6) {
                    ArcProgressView(progress: min(budgetProgress, 1.0), lineWidth: 5, size: 100)
                        .frame(height: 28)

                    Text("\(Int(budgetProgress * 100))% of budget")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.Catppuccin.subtext0)
                }
            } else {
                // No budget set - show date
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 9))
                    Text(entry.date, format: .dateTime.month(.abbreviated).day())
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(Color.Catppuccin.subtext0)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SpendBookWidgetMediumView: View {
    let entry: SpendBookEntry
    private let currencyService = CurrencyService.shared

    var budgetProgress: Double {
        guard let budget = entry.monthlyBudget, budget > 0 else { return 0 }
        return min(Double(truncating: entry.monthlySpending as NSNumber) / Double(truncating: budget as NSNumber), 1.2)
    }

    var remainingBudget: Decimal {
        guard let budget = entry.monthlyBudget else { return 0 }
        return max(budget - entry.monthlySpending, 0)
    }

    var daysLeftInMonth: Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: entry.date)!
        let currentDay = calendar.component(.day, from: entry.date)
        return range.count - currentDay
    }

    var comparisonToAverage: Decimal {
        guard entry.averageDailySpend > 0 else { return 0 }
        return entry.todaySpending - entry.averageDailySpend
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main content row
            HStack(spacing: 14) {
                // Left column - Today's spending
                VStack(alignment: .leading, spacing: 4) {
                    Text("TODAY")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(0.5)
                        .foregroundStyle(Color.Catppuccin.subtext0)

                    Text(currencyService.format(entry.todaySpending))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.Catppuccin.text)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)

                    // Comparison to average
                    if entry.averageDailySpend > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: comparisonToAverage >= 0 ? "arrow.up" : "arrow.down")
                                .font(.system(size: 8, weight: .bold))
                            Text(currencyService.format(abs(comparisonToAverage)) + " vs avg")
                                .font(.system(size: 9, weight: .medium))
                        }
                        .foregroundStyle(comparisonToAverage > 0 ? Color.Catppuccin.peach : Color.Catppuccin.green)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Divider
                Rectangle()
                    .fill(Color.Catppuccin.overlay0.opacity(0.4))
                    .frame(width: 1)
                    .padding(.vertical, 8)

                // Right column - Monthly spending + budget
                VStack(alignment: .leading, spacing: 4) {
                    Text("THIS MONTH")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(0.5)
                        .foregroundStyle(Color.Catppuccin.subtext0)

                    Text(currencyService.format(entry.monthlySpending))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.Catppuccin.text)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)

                    if entry.monthlyBudget != nil {
                        // Progress bar with marker
                        HStack(spacing: 6) {
                            HorizontalProgressBar(progress: min(budgetProgress, 1.0))
                                .frame(height: 5)

                            Text("\(Int(min(budgetProgress, 1.0) * 100))%")
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.Catppuccin.subtext0)
                        }

                        Text("\(currencyService.format(remainingBudget)) left · \(daysLeftInMonth)d")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color.Catppuccin.subtext0)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: .infinity)

            // Bottom streak badge (if logging streak exists)
            if entry.loggingStreak > 0 {
                HStack {
                    StreakBadge(
                        emoji: "🔥",
                        value: entry.loggingStreak,
                        label: entry.loggingStreak == 1 ? "day" : "days",
                        accentColor: Color.Catppuccin.peach
                    )
                    Spacer()
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SpendBookWidgetLargeView: View {
    let entry: SpendBookEntry
    private let currencyService = CurrencyService.shared

    var budgetProgress: Double {
        guard let budget = entry.monthlyBudget, budget > 0 else { return 0 }
        return min(Double(truncating: entry.monthlySpending as NSNumber) / Double(truncating: budget as NSNumber), 1.2)
    }

    var remainingBudget: Decimal {
        guard let budget = entry.monthlyBudget else { return 0 }
        return max(budget - entry.monthlySpending, 0)
    }

    var daysLeftInMonth: Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: entry.date)!
        let currentDay = calendar.component(.day, from: entry.date)
        return range.count - currentDay
    }

    var encouragingCopy: String {
        EncouragingCopy.forBudgetProgress(budgetProgress)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("SPENDBOOK")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(Color.Catppuccin.subtext0)

                Spacer()

                Text(entry.date, format: .dateTime.month(.abbreviated).day().year())
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.Catppuccin.subtext0)
            }

            // Central Ring Progress with Today's Spending
            ZStack {
                if entry.monthlyBudget != nil {
                    RingProgressView(progress: min(budgetProgress, 1.0), lineWidth: 10, size: 100)
                } else {
                    // Decorative ring when no budget
                    Circle()
                        .stroke(Color.Catppuccin.overlay0.opacity(0.2), lineWidth: 10)
                        .frame(width: 100, height: 100)
                }

                VStack(spacing: 2) {
                    Text(currencyService.format(entry.todaySpending))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.Catppuccin.text)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)

                    Text("today")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.Catppuccin.subtext0)
                }
            }
            .frame(height: 110)

            // Stat Cards Row
            HStack(spacing: 10) {
                StatCard(
                    title: "This Month",
                    value: currencyService.format(entry.monthlySpending),
                    progress: entry.monthlyBudget != nil ? min(budgetProgress, 1.0) : nil
                )

                if let budget = entry.monthlyBudget {
                    StatCard(
                        title: "Budget",
                        value: currencyService.format(budget),
                        subtitle: "\(currencyService.format(remainingBudget)) left"
                    )
                } else {
                    StatCard(
                        title: "Days Left",
                        value: "\(daysLeftInMonth)",
                        subtitle: "this month"
                    )
                }
            }

            Spacer(minLength: 0)

            // Achievement Strip
            HStack(spacing: 8) {
                if entry.loggingStreak > 0 {
                    StreakBadge(
                        emoji: "🔥",
                        value: entry.loggingStreak,
                        label: entry.loggingStreak == 1 ? "day" : "days",
                        accentColor: Color.Catppuccin.peach
                    )
                }

                if entry.noSpendStreak > 0 {
                    StreakBadge(
                        emoji: "🛡️",
                        value: entry.noSpendStreak,
                        label: "no-spend",
                        accentColor: Color.Catppuccin.lavender
                    )
                }

                if entry.monthlyBudget != nil {
                    StreakBadge(
                        emoji: budgetProgress < 0.8 ? "✨" : budgetProgress < 1.0 ? "👀" : "💪",
                        text: encouragingCopy,
                        accentColor: budgetProgress < 0.8 ? Color.Catppuccin.green :
                                    budgetProgress < 1.0 ? Color.Catppuccin.yellow : Color.Catppuccin.peach
                    )
                }

                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        configuration: SpendBookWidgetIntent(),
        loggingStreak: 7,
        noSpendStreak: 0,
        averageDailySpend: 58.25
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
        configuration: SpendBookWidgetIntent(),
        loggingStreak: 7,
        noSpendStreak: 0,
        averageDailySpend: 58.25
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
        configuration: SpendBookWidgetIntent(),
        loggingStreak: 7,
        noSpendStreak: 2,
        averageDailySpend: 58.25
    )
}

#Preview("Large - Over Budget", as: .systemLarge) {
    SpendBookWidget()
} timeline: {
    SpendBookEntry(
        date: Date(),
        todaySpending: 125.00,
        monthlySpending: 2150.00,
        monthlyBudget: 2000.00,
        configuration: SpendBookWidgetIntent(),
        loggingStreak: 14,
        noSpendStreak: 0,
        averageDailySpend: 72.50
    )
}

#Preview("Small - No Budget", as: .systemSmall) {
    SpendBookWidget()
} timeline: {
    SpendBookEntry(
        date: Date(),
        todaySpending: 32.00,
        monthlySpending: 890.00,
        monthlyBudget: nil,
        configuration: SpendBookWidgetIntent(),
        loggingStreak: 3,
        noSpendStreak: 0,
        averageDailySpend: 45.00
    )
}
