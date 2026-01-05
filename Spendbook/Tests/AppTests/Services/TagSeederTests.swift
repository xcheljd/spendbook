import XCTest
import SwiftData
@testable import SpendBook

@MainActor
final class TagSeederTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Tag.self, configurations: config)
        modelContext = modelContainer.mainContext
    }

    func testSeedDefaultTags() throws {
        let tagSeeder = TagSeeder(modelContext: modelContext)
        
        tagSeeder.seedDefaultTags()
        
        let descriptor = FetchDescriptor<Tag>()
        let tags = try modelContext.fetch(descriptor)
        
        XCTAssertGreaterThan(tags.count, 0, "Default tags should be created")
        
        let foodTag = tags.first(where: { $0.name == "Food" })
        XCTAssertNotNil(foodTag, "Food tag should exist")
        
        let diningOutTag = tags.first(where: { $0.name == "Dining Out" })
        XCTAssertNotNil(diningOutTag, "Dining Out tag should exist")
        XCTAssertEqual(diningOutTag?.parent?.name, "Food", "Dining Out should be a child of Food")
    }
    
    func testSeedOnlyOnce() throws {
        let tagSeeder = TagSeeder(modelContext: modelContext)
        
        tagSeeder.seedDefaultTags()
        let countAfterFirst = try modelContext.fetchCount(FetchDescriptor<Tag>())
        
        tagSeeder.seedDefaultTags()
        let countAfterSecond = try modelContext.fetchCount(FetchDescriptor<Tag>())
        
        XCTAssertEqual(countAfterFirst, countAfterSecond, "Tags should only be seeded once")
    }
}
