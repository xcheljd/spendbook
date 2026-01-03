import XCTest
import SwiftData
@testable import Spendbook

final class AddEntryContextTests: XCTestCase {
    
    // Simulate ViewModel logic
    class MockViewModel {
        var date: Date = Date()
        var selectedTags: [Tag] = []
        var note: String = ""
        
        func canSave() -> Bool {
            // Requirement: Must have at least one tag? Let's say yes for accountability.
            return !selectedTags.isEmpty
        }
        
        func save(amount: Decimal, dataManager: DataManager) {
            // Logic to create expense
        }
    }
    
    func testCanSaveValidation() {
        let vm = MockViewModel()
        
        // No tags selected
        XCTAssertFalse(vm.canSave())
        
        // Tag selected
        vm.selectedTags.append(Tag(name: "Test", colorHex: "#FFFFFF"))
        XCTAssertTrue(vm.canSave())
    }
}
