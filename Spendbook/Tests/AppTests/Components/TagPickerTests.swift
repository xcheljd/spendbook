import XCTest
@testable import Spendbook

final class TagPickerTests: XCTestCase {
    
    // Simulating Tag Selection Logic
    func testTagSelection() {
        let tag1 = TagStub(id: UUID(), name: "Food")
        let tag2 = TagStub(id: UUID(), name: "Transport")
        
        var selectedTags: [TagStub] = []
        
        // Select Tag 1
        selectedTags.append(tag1)
        XCTAssertTrue(selectedTags.contains(where: { $0.id == tag1.id }))
        
        // Deselect Tag 1
        selectedTags.removeAll(where: { $0.id == tag1.id })
        XCTAssertFalse(selectedTags.contains(where: { $0.id == tag1.id }))
        
        // Select Tag 2
        selectedTags.append(tag2)
        XCTAssertEqual(selectedTags.count, 1)
        XCTAssertEqual(selectedTags.first?.name, "Transport")
    }
    
    func testHierarchicalSearch() {
        let parent = TagStub(id: UUID(), name: "Food")
        let child = TagStub(id: UUID(), name: "Dining Out", parentID: parent.id)
        let tags = [parent, child]
        
        let searchText = "Dining"
        let filtered = tags.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.name, "Dining Out")
    }
    
    // Stub for testing logic without SwiftData dependencies in this simple test
    struct TagStub {
        let id: UUID
        let name: String
        var parentID: UUID? = nil
    }
}
