import Foundation
import SwiftUI
import Combine

class StreakService: ObservableObject {
    @AppStorage("bestLoggingStreak") var bestLoggingStreak: Int = 0
    @AppStorage("bestNoSpendStreak") var bestNoSpendStreak: Int = 0
    @AppStorage("lastMilestoneCelebrated") var lastMilestoneCelebrated: Int = 0
    
    func updateBestStreaks(currentLogging: Int, currentNoSpend: Int) {
        if currentLogging > bestLoggingStreak {
            bestLoggingStreak = currentLogging
        }
        if currentNoSpend > bestNoSpendStreak {
            bestNoSpendStreak = currentNoSpend
        }
    }
    
    /// Checks if a new milestone has been reached that hasn't been celebrated yet.
    func checkNewMilestone(streak: Int) -> String? {
        let milestones = [7, 30, 100]
        // Find the highest milestone achieved that is greater than the last one celebrated
        if let milestone = milestones.reversed().first(where: { streak >= $0 && $0 > lastMilestoneCelebrated }) {
            lastMilestoneCelebrated = milestone
            return checkMilestone(streak: milestone)
        }
        return nil
    }
    
    /// Returns a message for a specific milestone.
    func checkMilestone(streak: Int) -> String? {
        switch streak {
        case 7: return "7 Day Milestone! 🥉"
        case 30: return "30 Day Milestone! 🥈"
        case 100: return "100 Day Milestone! 🥇"
        default: return nil
        }
    }
}