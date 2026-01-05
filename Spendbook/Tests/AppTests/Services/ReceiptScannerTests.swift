import XCTest
@testable import SpendBook

@MainActor
final class ReceiptScannerTests: XCTestCase {
    var scanner: ReceiptScannerService!

    override func setUpWithError() throws {
        scanner = ReceiptScannerService()
    }

    func testAmountExtraction() {
        
        // Basic Total
        XCTAssertEqual(scanner.extractAmount(from: "Total: 12.34"), 12.34)
        
        // Multi-line with subtotal
        let multiLine = """
        Subtotal: 10.00
        Tax: 0.80
        Total: 10.80
        """
        XCTAssertEqual(scanner.extractAmount(from: multiLine), 10.80)
        
        // Largest number fallback
        let noise = """
        Item 1: 1.00
        Item 2: 99.00
        Something else: 50.00
        """
        XCTAssertEqual(scanner.extractAmount(from: noise), 99.00)
        
        // OCR Error variants (dot vs comma)
        XCTAssertEqual(scanner.extractAmount(from: "Total 15,50"), 15.50)
    }
    
    func testDateExtraction() {
        let text1 = "Date: 12/28/2025"
        let date1 = scanner.extractDate(from: text1)
        XCTAssertNotNil(date1)
        
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month, .day], from: date1!)
        XCTAssertEqual(comps.year, 2025)
        XCTAssertEqual(comps.month, 12)
        XCTAssertEqual(comps.day, 28)
    }
}