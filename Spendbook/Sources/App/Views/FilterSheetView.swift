import SwiftUI
import SwiftData

struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var filterSettings: FilterSettings
    @Query(sort: \Tag.name) private var allTags: [Tag]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Date Range") {
                    Picker("Range", selection: $filterSettings.dateRange) {
                        ForEach(DateRangeOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    
                    if filterSettings.dateRange == .custom {
                        DatePicker("Start Date", selection: $filterSettings.customStartDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $filterSettings.customEndDate, displayedComponents: .date)
                    }
                }
                
                Section("Amount") {
                    HStack {
                        Text("Min")
                        TextField("0.00", value: $filterSettings.minAmount, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Max")
                        TextField("No Limit", value: $filterSettings.maxAmount, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Attachments") {
                    Picker("Photo Status", selection: $filterSettings.photoStatus) {
                        ForEach(PhotoStatusOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Tags") {
                    if allTags.isEmpty {
                        Text("No tags available.")
                            .foregroundStyle(.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(allTags) { tag in
                                    TagButton(tag: tag, isSelected: filterSettings.selectedTags.contains(tag)) {
                                        toggleTag(tag)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Section {
                    Button("Reset Filters", role: .destructive) {
                        filterSettings.reset()
                    }
                    .disabled(!filterSettings.hasActiveFilters)
                }
            }
            .navigationTitle("Filter Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleTag(_ tag: Tag) {
        if let index = filterSettings.selectedTags.firstIndex(of: tag) {
            filterSettings.selectedTags.remove(at: index)
        } else {
            filterSettings.selectedTags.append(tag)
        }
    }
}
