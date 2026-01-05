import Foundation
import SwiftData
import Observation

enum DateRangeOption: String, CaseIterable, Identifiable, Sendable {
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case thisYear = "This Year"
    case allTime = "All Time"
    case custom = "Custom"

    var id: String { rawValue }
}

enum PhotoStatusOption: String, CaseIterable, Identifiable, Sendable {
    case any = "Any"
    case hasPhoto = "Has Photo"
    case noPhoto = "No Photo"

    var id: String { rawValue }
}

@Observable
@MainActor
final class FilterSettings {
    var dateRange: DateRangeOption = .allTime
    var customStartDate: Date = Date()
    var customEndDate: Date = Date()
    var selectedTagNames: Set<String> = []
    var minAmount: Decimal?
    var maxAmount: Decimal?
    var photoStatus: PhotoStatusOption = .any

    init() {}

    // Explicit nonisolated deinit to avoid Swift Concurrency back-deployment
    // issues with task-local storage cleanup when deallocating @MainActor objects
    nonisolated deinit {}

    var hasActiveFilters: Bool {
        return dateRange != .allTime ||
               !selectedTagNames.isEmpty ||
               minAmount != nil ||
               maxAmount != nil ||
               photoStatus != .any
    }

    func reset() {
        dateRange = .allTime
        selectedTagNames = []
        minAmount = nil
        maxAmount = nil
        photoStatus = .any
        customStartDate = Date()
        customEndDate = Date()
    }

    func isTagSelected(_ tag: Tag) -> Bool {
        selectedTagNames.contains(tag.name)
    }

    func toggleTag(_ tag: Tag) {
        if selectedTagNames.contains(tag.name) {
            selectedTagNames.remove(tag.name)
        } else {
            selectedTagNames.insert(tag.name)
        }
    }

    func removeTag(_ tag: Tag) {
        selectedTagNames.remove(tag.name)
    }
}
