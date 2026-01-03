import XCTest
@testable import Spendbook

final class FilterSettingsTests: XCTestCase {
    func testDefaultInitialization() {
        let settings = FilterSettings()
        XCTAssertEqual(settings.dateRange, .allTime)
        XCTAssertTrue(settings.selectedTags.isEmpty)
        XCTAssertNil(settings.minAmount)
        XCTAssertNil(settings.maxAmount)
        XCTAssertEqual(settings.photoStatus, .any)
        XCTAssertFalse(settings.hasActiveFilters)
    }
    
    func testActiveFiltersDetection() {
        var settings = FilterSettings()
        
        // Test Date Range
        settings.dateRange = .thisMonth
        XCTAssertTrue(settings.hasActiveFilters)
        settings.dateRange = .allTime
        XCTAssertFalse(settings.hasActiveFilters)
        
        // Test Tags
        let tag = Tag(name: "Test", color: "Blue", icon: "tag")
        settings.selectedTags = [tag]
        XCTAssertTrue(settings.hasActiveFilters)
        settings.selectedTags = []
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
        var settings = FilterSettings()
        settings.dateRange = .thisMonth
        settings.minAmount = 50
        
        settings.reset()
        
        XCTAssertFalse(settings.hasActiveFilters)
        XCTAssertEqual(settings.dateRange, .allTime)
        XCTAssertNil(settings.minAmount)
    }
}
