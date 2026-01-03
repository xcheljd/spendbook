import SwiftUI
import SwiftData

struct GoalsDashboardView: View {
    @Query(sort: \BudgetGoal.createdAt, order: .reverse) private var goals: [BudgetGoal]
    @Query private var expenses: [Expense]
    
    @State private var showingSetGoal = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.Catppuccin.base.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        StreakCalendarView(expenses: expenses)
                        
                        if goals.isEmpty {
                            EmptyGoalsView()
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
                                .foregroundColor(Color.Catppuccin.base)
                                .padding()
                                .background(Color.Catppuccin.mauve)
                                .clipShape(Circle())
                                .shadow(color: Color.Catppuccin.mauve.opacity(0.3), radius: 10, x: 0, y: 5)
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
    let goal: BudgetGoal
    let expenses: [Expense]
    
    @State private var animatedProgress: Double = 0
    
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
                        .foregroundColor(Color.Catppuccin.text)
                    
                    Text("\(goal.period.rawValue.capitalized) Limit")
                        .font(.caption)
                        .foregroundColor(Color.Catppuccin.subtext0)
                }
                
                Spacer()
                
                Text("\(spent.formatted(.currency(code: "USD"))) / \(goal.limitAmount.formatted(.currency(code: "USD")))")
                    .font(.subheadline.monospacedDigit())
                    .foregroundColor(isOverBudget ? Color.Catppuccin.red : Color.Catppuccin.text)
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.Catppuccin.crust)
                        .frame(height: 12)
                    
                    Capsule()
                        .fill(isOverBudget ? Color.Catppuccin.red : Color.Catppuccin.green)
                        .frame(width: geo.size.width * CGFloat(animatedProgress), height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding()
        .background(Color.Catppuccin.mantlet)
        .cornerRadius(16)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animatedProgress = progress
            }
        }
    }
}

struct EmptyGoalsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(Color.Catppuccin.overlay0)
            
            Text("No goals yet")
                .font(.headline)
                .foregroundColor(Color.Catppuccin.subtext0)
            
            Text("Set a spending limit to stay accountable.")
                .font(.subheadline)
                .foregroundColor(Color.Catppuccin.overlay0)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 100)
    }
}