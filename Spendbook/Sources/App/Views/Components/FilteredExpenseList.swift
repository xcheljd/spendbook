import SwiftUI
import SwiftData

struct FilteredExpenseList: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Environment(\.modelContext) private var modelContext
    
    init(filterSettings: FilterSettings, searchText: String) {
        let text = searchText
        
        // Unwrap optionals for Predicate stability
        let minAmt = filterSettings.minAmount
        let maxAmt = filterSettings.maxAmount
        
        let hasPhoto = filterSettings.photoStatus == .hasPhoto
        let noPhoto = filterSettings.photoStatus == .noPhoto
        
        // Calculate Dates
        let calendar = Calendar.current
        let now = Date()
        var calculatedStart: Date? = nil
        var calculatedEnd: Date? = nil
        
        switch filterSettings.dateRange {
        case .thisMonth:
            if let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
               let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start) {
                calculatedStart = start
                calculatedEnd = end
            }
        case .lastMonth:
            if let startCurrent = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
               let startLast = calendar.date(byAdding: .month, value: -1, to: startCurrent),
               let endLast = calendar.date(byAdding: .day, value: -1, to: startCurrent) {
                calculatedStart = startLast
                calculatedEnd = endLast
            }
        case .thisYear:
            if let start = calendar.date(from: calendar.dateComponents([.year], from: now)),
               let end = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: start) {
                calculatedStart = start
                calculatedEnd = end
            }
        case .custom:
            calculatedStart = filterSettings.customStartDate
            calculatedEnd = filterSettings.customEndDate
        case .allTime:
            break
        }
        
        let startLimit = calculatedStart
        let endLimit = calculatedEnd
        
        // Tags
        let tagNames = filterSettings.selectedTags.map { $0.name }
        let filterByTags = !tagNames.isEmpty
        
        // Predicate Construction
        let predicate = #Predicate<Expense> { expense in
            // Text Search (Note)
            (text.isEmpty || (expense.note?.localizedStandardContains(text) ?? false)) &&
            // Amount
            (minAmt == nil || expense.amount >= minAmt!) &&
            (maxAmt == nil || expense.amount <= maxAmt!) &&
            // Photo
            (!hasPhoto || expense.photoData != nil) &&
            (!noPhoto || expense.photoData == nil) &&
            // Date
            (startLimit == nil || expense.date >= startLimit!) &&
            (endLimit == nil || expense.date <= endLimit!) &&
            // Tags
            (!filterByTags || (expense.tags?.contains(where: { tagNames.contains($0.name) }) ?? false))
        }
        
        _expenses = Query(filter: predicate, sort: \.date, order: .reverse)
    }
    
    var body: some View {
        Group {
            if expenses.isEmpty {
                ContentUnavailableView {
                    Label("No Results", systemImage: "magnifyingglass")
                } description: {
                    Text("Try adjusting your filters or search terms.")
                }
            } else {
                List {
                    ForEach(expenses) { expense in
                        TransactionRow(expense: expense)
                            .listRowBackground(Color.Catppuccin.base)
                            .listRowSeparatorTint(Color.Catppuccin.overlay0.opacity(0.2))
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .onDelete(perform: deleteExpenses)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
    
    private func deleteExpenses(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(expenses[index])
            }
        }
    }
}
