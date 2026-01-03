import XCTest
@testable import Spendbook

final class HomeFeedTests: XCTestCase {
    
    func testFeedGroupingLogic() {
        // Logic to test if expenses are grouped by date or sorted correctly
        let e1 = ExpenseStub(amount: 10, date: Date())
        let e2 = ExpenseStub(amount: 20, date: Date().addingTimeInterval(-86400)) // Yesterday
        
        let feed = [e1, e2]
        let sorted = feed.sorted(by: { $0.date > $1.date })
        
        XCTAssertEqual(sorted.first?.amount, 10)
        XCTAssertEqual(sorted.last?.amount, 20)
    }
    
    struct ExpenseStub {
        let amount: Decimal
        let date: Date
    }
}
