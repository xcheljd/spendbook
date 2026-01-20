import Foundation
import SwiftUI
import Combine

/// Service that tracks personal records for logging and no-spend streaks, and manages milestone celebrations.
@MainActor
class StreakService: ObservableObject {
    /// The highest number of consecutive days the user has logged an expense.
    @AppStorage("bestLoggingStreak") var bestLoggingStreak: Int = 0
    /// The highest number of consecutive days the user has gone without spending.
    @AppStorage("bestNoSpendStreak") var bestNoSpendStreak: Int = 0
    /// The value of the last milestone (7, 30, 100) that was celebrated with a UI notification.
    @AppStorage("lastMilestoneCelebrated") var lastMilestoneCelebrated: Int = 0
    
    /// Compares current streaks against stored bests and updates them if a new record is reached.
    /// - Parameters:
    ///   - currentLogging: Current consecutive logging days.
    ///   - currentNoSpend: Current consecutive no-spend days.
    func updateBestStreaks(currentLogging: Int, currentNoSpend: Int) {
        if currentLogging > bestLoggingStreak {
            bestLoggingStreak = currentLogging
        }
        if currentNoSpend > bestNoSpendStreak {
            bestNoSpendStreak = currentNoSpend
        }
    }
    
    /// Determines if the current streak has hit a new milestone that hasn't been celebrated yet.
    /// - Parameter streak: The current streak value to check.
    /// - Returns: A celebration message if a new milestone is reached, otherwise nil.
    func checkNewMilestone(streak: Int) -> String? {
        let milestones = [7, 30, 100]
        // Find the highest milestone achieved that is greater than the last one celebrated
        if let milestone = milestones.reversed().first(where: { streak >= $0 && $0 > lastMilestoneCelebrated }) {
            lastMilestoneCelebrated = milestone
            return checkMilestone(streak: milestone)
        }
        return nil
    }
    
    /// Provides the localized milestone message for specific streak levels.
    /// - Parameter streak: The specific milestone value (e.g., 7, 30, 100).
    /// - Returns: A string with an emoji trophy, or nil if not a recognized milestone.
    func checkMilestone(streak: Int) -> String? {
        switch streak {
        case 7: return "7 Day Milestone! 🥉"
        case 30: return "30 Day Milestone! 🥈"
        case 100: return "100 Day Milestone! 🥇"
        default: return nil
        }
    }
}
