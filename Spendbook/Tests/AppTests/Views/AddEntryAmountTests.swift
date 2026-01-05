import XCTest
@testable import SpendBook

@MainActor
final class AddEntryAmountTests: XCTestCase {
    
    // Logic that will be in the View or ViewModel
    func testAmountValidation() {
        XCTAssertFalse(isValidAmount("0"))
        XCTAssertFalse(isValidAmount("0."))
        XCTAssertFalse(isValidAmount("0.0"))
        XCTAssertFalse(isValidAmount("0.00"))
        
        XCTAssertTrue(isValidAmount("1"))
        XCTAssertTrue(isValidAmount("0.01"))
        XCTAssertTrue(isValidAmount("100.50"))
    }
    
    private func isValidAmount(_ amount: String) -> Bool {
        guard let decimal = Decimal(string: amount) else { return false }
        return decimal > 0
    }
}
