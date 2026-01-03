import XCTest
@testable import Spendbook

final class ReceiptScannerTests: XCTestCase {
    
    func testAmountExtraction() {
        let scanner = ReceiptScannerService()
        
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
        let scanner = ReceiptScannerService()
        
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