import SwiftUI
import SwiftData

struct ActiveFiltersView: View {
    var filterSettings: FilterSettings
    @Query(sort: \Tag.name) private var allTags: [Tag]
    private let currencyService = CurrencyService.shared

    private var selectedTags: [Tag] {
        allTags.filter { filterSettings.selectedTagNames.contains($0.name) }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if filterSettings.dateRange != .allTime {
                    FilterChip(label: filterSettings.dateRange.rawValue) {
                        withAnimation {
                            filterSettings.dateRange = .allTime
                        }
                    }
                }

                ForEach(selectedTags) { tag in
                    FilterChip(label: tag.name, color: Color(hex: tag.colorHex)) {
                        withAnimation {
                            filterSettings.removeTag(tag)
                        }
                    }
                }

                if let min = filterSettings.minAmount {
                    FilterChip(label: "Min \(currencyService.format(min))") {
                        withAnimation {
                            filterSettings.minAmount = nil
                        }
                    }
                }

                if let max = filterSettings.maxAmount {
                    FilterChip(label: "Max \(currencyService.format(max))") {
                        withAnimation {
                            filterSettings.maxAmount = nil
                        }
                    }
                }

                if filterSettings.photoStatus != .any {
                    FilterChip(label: filterSettings.photoStatus.rawValue) {
                        withAnimation {
                            filterSettings.photoStatus = .any
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: filterSettings.selectedTagNames)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: filterSettings.dateRange)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: filterSettings.photoStatus)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: filterSettings.minAmount)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: filterSettings.maxAmount)
        }
    }
}

struct FilterChip: View {
    let label: String
    var color: Color = Color.Catppuccin.blue
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(.white)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2.bold())
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color)
        .clipShape(Capsule())
    }
}
