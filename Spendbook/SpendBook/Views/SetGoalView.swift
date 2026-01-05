import SwiftUI
import SwiftData

struct SetGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Tag.name) private var tags: [Tag]
    
    @State private var type: BudgetGoalType = .total
    @State private var period: BudgetPeriod = .monthly
    @State private var limitAmountString: String = ""
    @State private var selectedTag: Tag?
    
    var isValid: Bool {
        guard let amount = Decimal(string: limitAmountString), amount > 0 else { return false }
        if type == .category {
            return selectedTag != nil
        }
        return true
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.Catppuccin.base.ignoresSafeArea()
                
                Form {
                    Section {
                        Picker("Goal Type", selection: $type) {
                            Text("Total Budget").tag(BudgetGoalType.total)
                            Text("Category Limit").tag(BudgetGoalType.category)
                        }
                        .listRowBackground(Color.Catppuccin.mantle)
                        
                        Picker("Period", selection: $period) {
                            Text("Weekly").tag(BudgetPeriod.weekly)
                            Text("Monthly").tag(BudgetPeriod.monthly)
                        }
                        .listRowBackground(Color.Catppuccin.mantle)
                    } header: {
                        Text("Goal Details")
                            .foregroundColor(Color.Catppuccin.subtext0)
                    }
                    
                    if type == .category {
                        Section {
                            Picker("Tag", selection: $selectedTag) {
                                Text("Select a tag").tag(Tag?.none)
                                ForEach(tags) { tag in
                                    Text(tag.name).tag(tag as Tag?)
                                }
                            }
                            .listRowBackground(Color.Catppuccin.mantle)
                        } header: {
                            Text("Category")
                                .foregroundColor(Color.Catppuccin.subtext0)
                        }
                    }
                    
                    Section {
                        TextField("Limit Amount", text: $limitAmountString)
                            .keyboardType(.decimalPad)
                            .listRowBackground(Color.Catppuccin.mantle)
                            .foregroundColor(Color.Catppuccin.text)
                    } header: {
                        Text("Limit")
                            .foregroundColor(Color.Catppuccin.subtext0)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Set Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color.Catppuccin.blue)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveGoal() }
                        .disabled(!isValid)
                        .foregroundColor(isValid ? Color.Catppuccin.blue : Color.Catppuccin.overlay0)
                }
            }
        }
    }
    
    private func saveGoal() {
        guard let amount = Decimal(string: limitAmountString) else { return }
        
        let goal = BudgetGoal(
            type: type,
            period: period,
            limitAmount: amount,
            tag: selectedTag
        )
        
        modelContext.insert(goal)
        dismiss()
    }
}
