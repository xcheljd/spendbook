import SwiftUI
import SwiftData

struct RecurringExpenseManagerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RecurringExpense.name) private var recurringExpenses: [RecurringExpense]
    private var currencyService = CurrencyService.shared
    
    @State private var showingAddSheet = false
    
    var body: some View {
        List {
            if recurringExpenses.isEmpty {
                Text("No recurring expenses yet.")
                    .foregroundColor(Color.Catppuccin.subtext0)
                    .listRowBackground(Color.Catppuccin.base)
            } else {
                ForEach(recurringExpenses) { recurring in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recurring.name)
                                .font(.headline)
                                .foregroundColor(Color.Catppuccin.text)
                            Text("\(recurring.frequency.rawValue) • \(currencyService.format(recurring.amount))")
                                .font(.subheadline)
                                .foregroundColor(Color.Catppuccin.subtext0)
                        }
                        Spacer()
                        if let tag = recurring.tag {
                            Text(tag.name)
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: tag.colorHex).opacity(0.2))
                                .foregroundColor(Color(hex: tag.colorHex))
                                .clipShape(Capsule())
                        }
                    }
                    .listRowBackground(Color.Catppuccin.base)
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationTitle("Recurring")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.Catppuccin.base)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color.Catppuccin.blue)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddRecurringExpenseView()
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recurringExpenses[index])
        }
        try? modelContext.save()
    }
}

struct AddRecurringExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tag.name) private var tags: [Tag]
    private var currencyService = CurrencyService.shared
    
    @State private var name = ""
    @State private var amount: Decimal = 0
    @State private var frequency: RecurringFrequency = .monthly
    @State private var selectedTag: Tag?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name (e.g. Rent)", text: $name)
                        .foregroundColor(Color.Catppuccin.text)
                    
                    HStack {
                        Text(currencyService.selectedCurrencyCode)
                            .foregroundColor(Color.Catppuccin.subtext0)
                        TextField("Amount", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                            .foregroundColor(Color.Catppuccin.text)
                    }
                }
                
                Section("Frequency") {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(RecurringFrequency.allCases) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Category") {
                    Picker("Tag", selection: $selectedTag) {
                        Text("None").tag(nil as Tag?)
                        ForEach(tags) { tag in
                            Text(tag.name).tag(tag as Tag?)
                        }
                    }
                }
            }
            .navigationTitle("Add Recurring")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Color.Catppuccin.base)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color.Catppuccin.blue)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let new = RecurringExpense(name: name, amount: amount, frequency: frequency, tag: selectedTag)
                        modelContext.insert(new)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(name.isEmpty || amount <= 0)
                    .foregroundColor(Color.Catppuccin.blue)
                }
            }
        }
    }
}
