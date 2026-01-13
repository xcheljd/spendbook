import SwiftUI
import SwiftData

struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var filterSettings: FilterSettings
    @Query(sort: \Tag.name) private var allTags: [Tag]
    private let currencyService = CurrencyService.shared

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
                        TextField("0.00", value: $filterSettings.minAmount, format: .currency(code: currencyService.selectedCurrencyCode))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Max")
                        TextField("No Limit", value: $filterSettings.maxAmount, format: .currency(code: currencyService.selectedCurrencyCode))
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
                                    TagButton(tag: tag, isSelected: filterSettings.isTagSelected(tag), action: {
                                        filterSettings.toggleTag(tag)
                                    }, onNavigate: {})
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
}
