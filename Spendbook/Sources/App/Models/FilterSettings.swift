import Foundation
import SwiftData

enum DateRangeOption: String, CaseIterable, Identifiable {
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case thisYear = "This Year"
    case allTime = "All Time"
    case custom = "Custom"
    
    var id: String { rawValue }
}

enum PhotoStatusOption: String, CaseIterable, Identifiable {
    case any = "Any"
    case hasPhoto = "Has Photo"
    case noPhoto = "No Photo"
    
    var id: String { rawValue }
}

@Observable
class FilterSettings {
    var dateRange: DateRangeOption = .allTime
    var customStartDate: Date = Date()
    var customEndDate: Date = Date()
    
    var selectedTags: [Tag] = []
    
    var minAmount: Decimal?
    var maxAmount: Decimal?
    
    var photoStatus: PhotoStatusOption = .any
    
    init() {}
    
    var hasActiveFilters: Bool {
        return dateRange != .allTime ||
               !selectedTags.isEmpty ||
               minAmount != nil ||
               maxAmount != nil ||
               photoStatus != .any
    }
    
    func reset() {
        dateRange = .allTime
        selectedTags = []
        minAmount = nil
        maxAmount = nil
        photoStatus = .any
        customStartDate = Date()
        customEndDate = Date()
    }
}
