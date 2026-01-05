import SwiftUI
import SwiftData

struct GoalsDashboardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \BudgetGoal.createdAt, order: .reverse) private var goals: [BudgetGoal]
    @Query private var expenses: [Expense]

    @State private var showingSetGoal = false

    private var theme: Theme { Theme(colorScheme) }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.base.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        StreakCalendarView(expenses: expenses)

                        if goals.isEmpty {
                            EmptyGoalsView { showingSetGoal = true }
                        } else {
                            ForEach(goals) { goal in
                                GoalProgressCard(goal: goal, expenses: expenses)
                            }
                        }
                    }
                    .padding()
                }

                // Add Goal Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingSetGoal = true }) {
                            Image(systemName: "plus")
                                .font(.title.bold())
                                .foregroundColor(theme.base)
                                .padding()
                                .background(theme.mauve)
                                .clipShape(Circle())
                                .shadow(color: theme.mauve.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Goals")
            .sheet(isPresented: $showingSetGoal) {
                SetGoalView()
            }
        }
    }
}

struct GoalProgressCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let goal: BudgetGoal
    let expenses: [Expense]
    var currencyService = CurrencyService.shared

    @State private var animatedProgress: Double = 0

    private var theme: Theme { Theme(colorScheme) }

    var spent: Decimal {
        let calendar = Calendar.current
        let currentPeriodExpenses = expenses.filter { expense in
            if goal.type == .category, let goalTag = goal.tag {
                guard expense.tags?.contains(where: { $0.id == goalTag.id }) == true else { return false }
            }
            return calendar.isDate(expense.date, equalTo: Date(), toGranularity: .month)
        }
        return currentPeriodExpenses.reduce(0) { $0 + $1.amount }
    }

    var progress: Double {
        let limit = NSDecimalNumber(decimal: goal.limitAmount).doubleValue
        let current = NSDecimalNumber(decimal: spent).doubleValue
        guard limit > 0 else { return 0 }
        return min(current / limit, 1.0)
    }

    var isOverBudget: Bool {
        spent > goal.limitAmount
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.type == .total ? "Total Budget" : (goal.tag?.name ?? "Category"))
                        .font(.headline)
                        .foregroundColor(theme.text)

                    Text("\(goal.period.rawValue.capitalized) Limit")
                        .font(.caption)
                        .foregroundColor(theme.subtext0)
                }

                Spacer()

                Text("\(currencyService.format(spent)) / \(currencyService.format(goal.limitAmount))")
                    .font(.subheadline.monospacedDigit())
                    .foregroundColor(isOverBudget ? theme.red : theme.text)
            }

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(theme.crust)
                        .frame(height: 12)

                    Capsule()
                        .fill(isOverBudget ? theme.red : theme.green)
                        .frame(width: geo.size.width * CGFloat(animatedProgress), height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding()
        .background(theme.mantle)
        .cornerRadius(16)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animatedProgress = progress
            }
        }
    }
}

struct EmptyGoalsView: View {
    var onAddGoal: (() -> Void)? = nil

    var body: some View {
        GoalsEmptyState(onAddGoal: onAddGoal)
            .padding(.top, 60)
    }
}
