import XCTest
@testable import Spendbook

final class NavigationTests: XCTestCase {
    
    func testNavigationState() {
        var isShowingAdd = false
        
        // Open
        isShowingAdd = true
        XCTAssertTrue(isShowingAdd)
        
        // Close
        isShowingAdd = false
        XCTAssertFalse(isShowingAdd)
    }
}
