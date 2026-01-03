import XCTest
import SwiftData
@testable import Spendbook

final class DataExportServiceTests: XCTestCase {
    
    // MARK: - Test Helpers
    // Since we can't easily mock ModelContext in pure unit tests without a container,
    // we will test the formatting logic by passing data directly or using a protocol.
    // However, the plan implies the service fetches data.
    // To make it testable on Linux/Logic, we'll design the service to accept [Expense]
    // for the generation methods, or use a dependency injection pattern.
    
    func testCSVGeneration() {
        let date = Date(timeIntervalSince1970: 1700000000) // Fixed date
        let expense = Expense(amount: 10.50, date: date, note: "Lunch", tags: [Tag(name: "Food", colorHex: "#000000")])
        
        let service = DataExportService()
        let csv = service.generateCSV(from: [expense])
        
        let expectedHeader = "Date,Amount,Note,Tags\n"
        // Adjust expected string based on date formatter in service
        // We expect ISO8601 or similar standard for export
        XCTAssertTrue(csv.contains(expectedHeader))
        XCTAssertTrue(csv.contains("10.50"))
        XCTAssertTrue(csv.contains("Lunch"))
        XCTAssertTrue(csv.contains("Food"))
    }
    
    func testJSONGeneration() throws {
        let date = Date(timeIntervalSince1970: 1700000000)
        let expense = Expense(amount: 20.00, date: date, note: "Taxi")
        
        let service = DataExportService()
        let jsonData = try service.generateJSON(from: [expense])
        
        let decoder = JSONDecoder()
        // We decode into the Exportable struct or a generic dictionary to verify
        // But since we can't access internal structs easily in tests without @testable,
        // we assume standard JSON structure.
        
        let jsonString = String(data: jsonData, encoding: .utf8)!
        XCTAssertTrue(jsonString.contains("20"))
        XCTAssertTrue(jsonString.contains("Taxi"))
    }
}
