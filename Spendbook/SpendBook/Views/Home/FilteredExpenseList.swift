import SwiftUI
import SwiftData

struct FilteredExpenseList: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Environment(\.modelContext) private var modelContext

    @State private var expenseToDelete: Expense?
    @State private var showDeleteConfirmation = false
    @State private var selectedExpense: Expense?

    private var privacyBlurState: PrivacyBlurState { PrivacyBlurState.shared }

    let filterSettings: FilterSettings
    let searchText: String
    
    init(filterSettings: FilterSettings, searchText: String) {
        self.filterSettings = filterSettings
        self.searchText = searchText
        
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
        
        // Only date filtering in predicate - other filters applied post-fetch
        let predicate = #Predicate<Expense> { expense in
            (startLimit == nil || expense.date >= startLimit!) &&
            (endLimit == nil || expense.date <= endLimit!)
        }
        
        _expenses = Query(filter: predicate, sort: \.date, order: .reverse)
    }
    
    // Apply remaining filters post-fetch
    private var filteredExpenses: [Expense] {
        expenses.filter { expense in
            // Search text filter
            if !searchText.isEmpty {
                let matchesNote = expense.note?.localizedCaseInsensitiveContains(searchText) ?? false
                let matchesTag = expense.tags?.contains(where: { $0.name.localizedCaseInsensitiveContains(searchText) }) ?? false
                let matchesAmount = String(describing: expense.amount).contains(searchText)
                
                if !(matchesNote || matchesTag || matchesAmount) {
                    return false
                }
            }
            
            // Amount filter
            if let minAmount = filterSettings.minAmount, expense.amount < minAmount {
                return false
            }
            if let maxAmount = filterSettings.maxAmount, expense.amount > maxAmount {
                return false
            }
            
            // Photo filter
            switch filterSettings.photoStatus {
            case .hasPhoto:
                if expense.photoData == nil {
                    return false
                }
            case .noPhoto:
                if expense.photoData != nil {
                    return false
                }
            case .any:
                break
            }
            
            // Tag filter
            if !filterSettings.selectedTagNames.isEmpty {
                let expenseTagNames = expense.tags?.map { $0.name } ?? []
                let hasMatchingTag = filterSettings.selectedTagNames.contains(where: { expenseTagNames.contains($0) })
                if !hasMatchingTag {
                    return false
                }
            }
            
            return true
        }
    }
    
    var body: some View {
        Group {
            if filteredExpenses.isEmpty {
                ContentUnavailableView {
                    Label("No Results", systemImage: "magnifyingglass")
                } description: {
                    Text("Try adjusting your filters or search terms.")
                }
            } else {
                List {
                    ForEach(filteredExpenses) { expense in
                        TransactionRow(expense: expense, isBlurred: privacyBlurState.isEnabled)
                            .listRowBackground(Color.Catppuccin.base)
                            .listRowSeparatorTint(Color.Catppuccin.overlay0.opacity(0.2))
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .onTapGesture {
                                selectedExpense = expense
                            }
                    }
                    .onDelete(perform: confirmDelete)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .alert("Delete Expense?", isPresented: $showDeleteConfirmation, presenting: expenseToDelete) { expense in
            Button("Cancel", role: .cancel) {
                expenseToDelete = nil
            }
            Button("Delete", role: .destructive) {
                deleteExpense(expense)
            }
        } message: { expense in
            Text(deleteConfirmationMessage(for: expense))
        }
        .sheet(item: $selectedExpense) { expense in
            ExpenseDetailView(expense: expense)
        }
    }

    private func confirmDelete(offsets: IndexSet) {
        guard let index = offsets.first else { return }
        expenseToDelete = filteredExpenses[index]
        showDeleteConfirmation = true
    }

    private func deleteExpense(_ expense: Expense) {
        withAnimation {
            modelContext.delete(expense)
        }
        expenseToDelete = nil
    }

    private func deleteConfirmationMessage(for expense: Expense) -> String {
        let amount = CurrencyService.shared.format(expense.amount)
        let tagName = expense.tags?.first?.fullName ?? "Uncategorized"
        return "\(amount) • \(tagName)"
    }
}
