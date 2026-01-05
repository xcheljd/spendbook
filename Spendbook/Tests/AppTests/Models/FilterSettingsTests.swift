import XCTest
@testable import SpendBook

@MainActor
final class FilterSettingsTests: XCTestCase {
    func testDefaultInitialization() {
        let settings = FilterSettings()
        XCTAssertEqual(settings.dateRange, .allTime)
        XCTAssertTrue(settings.selectedTagNames.isEmpty)
        XCTAssertNil(settings.minAmount)
        XCTAssertNil(settings.maxAmount)
        XCTAssertEqual(settings.photoStatus, .any)
        XCTAssertFalse(settings.hasActiveFilters)
    }

    func testActiveFiltersDetection() {
        let settings = FilterSettings()

        // Test Date Range
        settings.dateRange = .thisMonth
        XCTAssertTrue(settings.hasActiveFilters)
        settings.dateRange = .allTime
        XCTAssertFalse(settings.hasActiveFilters)

        // Test Tags (using tag names directly to avoid SwiftData memory issues)
        settings.selectedTagNames.insert("Test")
        XCTAssertTrue(settings.hasActiveFilters)
        settings.selectedTagNames.removeAll()
        XCTAssertFalse(settings.hasActiveFilters)

        // Test Amounts
        settings.minAmount = 10
        XCTAssertTrue(settings.hasActiveFilters)
        settings.minAmount = nil

        settings.maxAmount = 100
        XCTAssertTrue(settings.hasActiveFilters)
        settings.maxAmount = nil
        XCTAssertFalse(settings.hasActiveFilters)

        // Test Photo
        settings.photoStatus = .hasPhoto
        XCTAssertTrue(settings.hasActiveFilters)
        settings.photoStatus = .any
        XCTAssertFalse(settings.hasActiveFilters)
    }

    func testReset() {
        let settings = FilterSettings()
        settings.dateRange = .thisMonth
        settings.minAmount = 50
        settings.selectedTagNames.insert("Food")

        settings.reset()

        XCTAssertFalse(settings.hasActiveFilters)
        XCTAssertEqual(settings.dateRange, .allTime)
        XCTAssertNil(settings.minAmount)
        XCTAssertTrue(settings.selectedTagNames.isEmpty)
    }
}
