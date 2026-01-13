import SwiftUI
import SwiftData

enum Timeframe: String, CaseIterable, Identifiable {
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case thisYear = "This Year"
    
    var id: String { rawValue }
}

struct InsightsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    @State private var timeframe: Timeframe = .thisMonth
    private let chartService = ChartDataService()

    private var calendar: Calendar { .current }
    private var theme: Theme { Theme(colorScheme) }
    
    var filteredExpenses: [Expense] {
        let now = Date()
        
        return expenses.filter { expense in
            switch timeframe {
            case .thisMonth:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
            case .lastMonth:
                guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return false }
                return calendar.isDate(expense.date, equalTo: lastMonth, toGranularity: .month)
            case .thisYear:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .year)
            }
        }
    }
    
    var dateRange: ClosedRange<Date> {
        let now = Date()
        let start: Date
        let end: Date
        
        switch timeframe {
        case .thisMonth:
            start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start)!
        case .lastMonth:
            let startOfThis = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            start = calendar.date(byAdding: .month, value: -1, to: startOfThis)!
            end = calendar.date(byAdding: .day, value: -1, to: startOfThis)!
        case .thisYear:
            start = calendar.date(from: calendar.dateComponents([.year], from: now))!
            end = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: start)!
        }
        
        return start...end
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.base.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Timeframe Picker
                        Picker("Timeframe", selection: $timeframe) {
                            ForEach(Timeframe.allCases) { tf in
                                Text(tf.rawValue).tag(tf)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        if filteredExpenses.isEmpty {
                            InsightsEmptyState(timeframeName: timeframe.rawValue)
                                .padding(.top, 60)
                        } else {
                            // Trends Chart
                            SpendingTrendsChart(data: chartService.aggregateExpensesByDay(filteredExpenses, in: dateRange))
                                .padding(.horizontal)
                            
                            // Category Chart
                            CategoryBreakdownChart(data: chartService.aggregateExpensesByCategory(filteredExpenses))
                                .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
