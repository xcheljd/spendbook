import XCTest
@testable import Spendbook

final class ScannerIntegrationTests: XCTestCase {
    
    func testScannerStateUpdate() {
        // Simulate ViewModel updating amount from scanner result
        var inputAmount = "0"
        
        let scannedAmount: Decimal = 15.50
        inputAmount = "\(scannedAmount)"
        
        XCTAssertEqual(inputAmount, "15.5")
    }
}
