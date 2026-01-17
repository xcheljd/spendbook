import XCTest
import SwiftUI
@testable import SpendBook

@MainActor
final class StreakServiceTests: XCTestCase {
    var service: StreakService!
    
    override func setUp() {
        super.setUp()
        service = StreakService()
        service.bestLoggingStreak = 0
        service.bestNoSpendStreak = 0
        service.lastMilestoneCelebrated = 0
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    func testUpdateBestStreaks() {
        XCTAssertEqual(service.bestLoggingStreak, 0)
        XCTAssertEqual(service.bestNoSpendStreak, 0)
        
        service.updateBestStreaks(currentLogging: 5, currentNoSpend: 10)
        XCTAssertEqual(service.bestLoggingStreak, 5)
        XCTAssertEqual(service.bestNoSpendStreak, 10)
        
        service.updateBestStreaks(currentLogging: 3, currentNoSpend: 8)
        XCTAssertEqual(service.bestLoggingStreak, 5)
        XCTAssertEqual(service.bestNoSpendStreak, 10)
        
        service.updateBestStreaks(currentLogging: 7, currentNoSpend: 2)
        XCTAssertEqual(service.bestLoggingStreak, 7)
        XCTAssertEqual(service.bestNoSpendStreak, 10)
    }
    
    func testCheckNewMilestoneBronze() {
        let message = service.checkNewMilestone(streak: 7)
        XCTAssertEqual(message, "7 Day Milestone! 🥉")
        XCTAssertEqual(service.lastMilestoneCelebrated, 7)
        
        let message2 = service.checkNewMilestone(streak: 7)
        XCTAssertNil(message2)
    }
    
    func testCheckNewMilestoneSilver() {
        let message = service.checkNewMilestone(streak: 35)
        XCTAssertEqual(message, "30 Day Milestone! 🥈")
        XCTAssertEqual(service.lastMilestoneCelebrated, 30)
    }
    
    func testCheckNewMilestoneGold() {
        _ = service.checkNewMilestone(streak: 7)
        _ = service.checkNewMilestone(streak: 30)
        let message = service.checkNewMilestone(streak: 105)
        
        XCTAssertEqual(message, "100 Day Milestone! 🥇")
        XCTAssertEqual(service.lastMilestoneCelebrated, 100)
    }
    
    func testCheckMilestoneMessages() {
        XCTAssertEqual(service.checkMilestone(streak: 7), "7 Day Milestone! 🥉")
        XCTAssertEqual(service.checkMilestone(streak: 30), "30 Day Milestone! 🥈")
        XCTAssertEqual(service.checkMilestone(streak: 100), "100 Day Milestone! 🥇")
        XCTAssertNil(service.checkMilestone(streak: 5))
        XCTAssertNil(service.checkMilestone(streak: 50))
    }
}
