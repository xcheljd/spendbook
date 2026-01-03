import SwiftUI
import SwiftData

struct HomeFeedView: View {
    @Environment(\.modelContext) private var modelContext
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
                Color.Catppuccin.base.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced Header Summary
                    // Always show summary based on global state, regardless of filters
                    VStack(spacing: 20) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Spent (Month)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.Catppuccin.subtext0)
                                
                                Text(currencyService.format(totalSpentThisMonth))
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.Catppuccin.text)
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
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Safe to Spend Today")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.Catppuccin.base)
                                
                                Text(currencyService.format(safeToSpend))
                                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                                    .foregroundColor(Color.Catppuccin.base)
                                    .contentTransition(.numericText())
                                    .animation(.spring, value: safeToSpend)
                            }
                            Spacer()
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color.Catppuccin.base.opacity(0.5))
                        }
                        .padding()
                        .background(Color.Catppuccin.blue)
                        .cornerRadius(20)
                        .shadow(color: Color.Catppuccin.blue.opacity(0.2), radius: 8, x: 0, y: 4)
                        
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
                    .background(Color.Catppuccin.mantlet)
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
                                .foregroundColor(Color.Catppuccin.base)
                                .padding()
                                .background(Color.Catppuccin.blue)
                                .clipShape(Circle())
                                .shadow(color: Color.Catppuccin.blue.opacity(0.3), radius: 10, x: 0, y: 5)
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
                                .foregroundColor(Color.Catppuccin.blue)
                        }
                        
                        Button(action: { showingInsights = true }) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(Color.Catppuccin.blue)
                        }
                        
                        Button(action: { showingGoals = true }) {
                            Image(systemName: "target")
                                .foregroundColor(Color.Catppuccin.blue)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button(action: { showingFilterSheet = true }) {
                            Image(systemName: filterSettings.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .foregroundColor(Color.Catppuccin.blue)
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
        }
    }
    
    private func logRecurring(_ recurring: RecurringExpense) {
        let expense = recurringService.createExpense(from: recurring)
        modelContext.insert(expense)
        try? modelContext.save()
    }
}

// TransactionRow and EmptyStateView remain unchanged (reused)
struct TransactionRow: View {
    let expense: Expense
    private var currencyService = CurrencyService.shared
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.Catppuccin.mantlet)
                    .frame(width: 48, height: 48)
                
                if let data = expense.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "bag")
                        .foregroundColor(Color.Catppuccin.blue)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.tags?.first?.fullName ?? "Uncategorized")
                    .font(.headline)
                    .foregroundColor(Color.Catppuccin.text)
                
                Text(expense.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(Color.Catppuccin.subtext0)
            }
            
            Spacer()
            
            Text(currencyService.format(expense.amount))
                .font(.headline)
                .foregroundColor(Color.Catppuccin.text)
        }
        .padding(.vertical, 4)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundColor(Color.Catppuccin.overlay0)
            
            Text("No transactions yet")
                .font(.headline)
                .foregroundColor(Color.Catppuccin.subtext0)
            
            Text("Start tracking your spending by tapping the + button.")
                .font(.subheadline)
                .foregroundColor(Color.Catppuccin.overlay0)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
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