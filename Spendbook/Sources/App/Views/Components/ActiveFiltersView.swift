import SwiftUI

struct ActiveFiltersView: View {
    @Bindable var filterSettings: FilterSettings
    
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
                
                ForEach(filterSettings.selectedTags) { tag in
                    FilterChip(label: tag.name, color: Color(hex: tag.colorHex)) {
                        withAnimation {
                            if let idx = filterSettings.selectedTags.firstIndex(of: tag) {
                                filterSettings.selectedTags.remove(at: idx)
                            }
                        }
                    }
                }
                
                if let min = filterSettings.minAmount {
                    FilterChip(label: "Min \(min.formatted(.currency(code: "USD")))") {
                        withAnimation {
                            filterSettings.minAmount = nil
                        }
                    }
                }
                
                if let max = filterSettings.maxAmount {
                    FilterChip(label: "Max \(max.formatted(.currency(code: "USD")))") {
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
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: filterSettings.selectedTags)
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
