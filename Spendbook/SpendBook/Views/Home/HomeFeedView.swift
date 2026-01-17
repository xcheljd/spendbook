import SwiftUI
import SwiftData

struct HomeFeedView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query private var goals: [BudgetGoal]
    @Query(sort: \RecurringExpense.nextDueDate) private var recurringExpenses: [RecurringExpense]

    @State private var showingAddEntry = false
    @State private var showingGoals = false
    @State private var showingFilterSheet = false
    @State private var showingSettings = false
    @State private var showingInsights = false

    @StateObject private var streakService = StreakService()
    @State private var currencyService = CurrencyService.shared

    @State private var searchText = ""
    @State private var filterSettings = FilterSettings()

    private var theme: Theme { Theme(colorScheme) }
    
    private let accountabilityService = AccountabilityService()
    private let recurringService = RecurringExpenseService()
    
    var dueRecurringExpenses: [RecurringExpense] {
        let today = Calendar.current.startOfDay(for: Date())
        return recurringExpenses.filter { $0.nextDueDate <= today }
    }
    
    var totalSpentThisMonth: Decimal {
        let calendar = Calendar.current
        return expenses.filter { 
            calendar.isDate($0.date, equalTo: Date(), toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
    }
    
    var safeToSpend: Decimal {
        guard let totalGoal = goals.first(where: { $0.type == .total && $0.period == .monthly }) else {
            return 0
        }
        
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: Date())!
        let dayOfMonth = calendar.component(.day, from: Date())
        let daysRemaining = range.count - dayOfMonth + 1
        
        return accountabilityService.calculateDailySafeToSpend(
            totalBudget: totalGoal.limitAmount,
            currentSpend: totalSpentThisMonth,
            daysRemaining: daysRemaining
        )
    }
    
    var currentStreak: Int {
        accountabilityService.calculateStreak(from: expenses.map { $0.date })
    }
    
    var noSpendStreak: Int {
        accountabilityService.calculateNoSpendStreak(from: expenses)
    }
    
    var daysPassed: Int {
        Calendar.current.component(.day, from: Date())
    }
    
    var totalDaysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
    }
    
    var projectedSpend: Decimal {
        accountabilityService.calculateProjectedMonthlySpend(
            currentSpend: totalSpentThisMonth,
            daysPassed: daysPassed,
            totalDaysInMonth: totalDaysInMonth
        )
    }
    
    var currentGoal: Decimal {
        goals.first(where: { $0.type == .total && $0.period == .monthly })?.limitAmount ?? 0
    }
    
    var exhaustionDate: Date? {
        accountabilityService.calculateBudgetExhaustionDate(
            totalBudget: currentGoal,
            currentSpend: totalSpentThisMonth,
            daysPassed: daysPassed
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.base.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Enhanced Header Summary
                    // Always show summary based on global state, regardless of filters
                    VStack(spacing: 20) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Spent (Month)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(theme.subtext0)

                                Text(currencyService.format(totalSpentThisMonth))
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(theme.text)
                                    .contentTransition(.numericText())
                                    .animation(.spring, value: totalSpentThisMonth)
                            }

                            Spacer()

                            StreakSummaryCard(
                                loggingStreak: currentStreak,
                                noSpendStreak: noSpendStreak,
                                bestLogging: streakService.bestLoggingStreak,
                                bestNoSpend: streakService.bestNoSpendStreak
                            )
                            .frame(width: 180)
                        }

                        // Safe-to-Spend Card
                        SafeToSpendCard(amount: safeToSpend, currencyService: currencyService)

                        // Forecasting View
                        if currentGoal > 0 {
                            ForecastingView(
                                projectedSpend: projectedSpend,
                                goal: currentGoal,
                                exhaustionDate: exhaustionDate
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                    .background(theme.mantle)
                    .cornerRadius(32, corners: [.bottomLeft, .bottomRight])
                    
                    // Recurring Items
                    if !dueRecurringExpenses.isEmpty && searchText.isEmpty && !filterSettings.hasActiveFilters {
                        VStack(spacing: 12) {
                            ForEach(dueRecurringExpenses) { recurring in
                                RecurringDueCard(recurring: recurring) {
                                    logRecurring(recurring)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }
                    
                    // Active Filters
                    if filterSettings.hasActiveFilters {
                        ActiveFiltersView(filterSettings: filterSettings)
                            .padding(.top, 8)
                    }
                    
                    // Transactions List or Filtered View
                    if expenses.isEmpty && searchText.isEmpty && !filterSettings.hasActiveFilters {
                        EmptyStateView()
                    } else {
                        // Use FilteredExpenseList to handle all list rendering, 
                        // as it now supports dynamic predicates.
                        FilteredExpenseList(filterSettings: filterSettings, searchText: searchText)
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddEntry = true }) {
                            Image(systemName: "plus")
                                .font(.title.bold())
                                .foregroundStyle(theme.base)
                                .padding()
                                .background(theme.blue)
                                .clipShape(Circle())
                                .shadow(color: theme.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Spendbook")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 16) {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape")
                                .foregroundStyle(theme.blue)
                        }

                        Button(action: { showingInsights = true }) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundStyle(theme.blue)
                        }

                        Button(action: { showingGoals = true }) {
                            Image(systemName: "target")
                                .foregroundStyle(theme.blue)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button(action: { showingFilterSheet = true }) {
                            Image(systemName: filterSettings.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .foregroundStyle(theme.blue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddEntryAmountScreen()
            }
            .sheet(isPresented: $showingGoals) {
                GoalsDashboardView()
            }
            .sheet(isPresented: $showingFilterSheet) {
                FilterSheetView(filterSettings: filterSettings)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingInsights) {
                InsightsView()
            }
        }
        .onOpenURL { url in
            if url.scheme == "spendbook" && url.host == "add" {
                showingAddEntry = true
            }
        }
        .onAppear {
            streakService.updateBestStreaks(currentLogging: currentStreak, currentNoSpend: noSpendStreak)

            // Schedule weekly status notifications if enabled and goal exists
            if currentGoal > 0 {
                NotificationService.shared.scheduleWeeklyStatusReport(
                    projectedSpend: projectedSpend,
                    goal: currentGoal
                )
            }
        }
    }
    
    private func logRecurring(_ recurring: RecurringExpense) {
        let expense = recurringService.createExpense(from: recurring)
        modelContext.insert(expense)
        try? modelContext.save()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
