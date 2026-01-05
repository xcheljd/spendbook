import XCTest
import SwiftData
@testable import SpendBook

@MainActor
final class TagTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Tag.self, Expense.self, configurations: config)
        modelContext = modelContainer.mainContext
    }

    func testTagInitialization() throws {
        let tag = Tag(name: "Groceries", colorHex: "#00FF00")
        modelContext.insert(tag)
        
        XCTAssertNotNil(tag.id)
        XCTAssertEqual(tag.name, "Groceries")
        XCTAssertEqual(tag.colorHex, "#00FF00")
    }

    func testTagParentChildRelationship() throws {
        let parentTag = Tag(name: "Food", colorHex: "#FF0000")
        let childTag = Tag(name: "Dining Out", colorHex: "#FF0000")
        
        modelContext.insert(parentTag)
        modelContext.insert(childTag)
        
        childTag.parent = parentTag
        
        XCTAssertEqual(childTag.parent?.name, "Food")
        // Assuming we implement a children relationship
        // XCTAssertTrue(parentTag.children.contains(where: { $0.name == "Dining Out" }))
    }
}
