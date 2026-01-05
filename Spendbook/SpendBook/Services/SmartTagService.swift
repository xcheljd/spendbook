import Foundation
import SwiftData

/// Service that provides intelligent tag suggestions based on usage patterns
struct SmartTagService {
    private let calendar = Calendar.current

    /// Calculates a smart score for each tag based on multiple factors
    /// - Parameters:
    ///   - tags: All available tags
    ///   - expenses: Recent expenses to analyze patterns from
    /// - Returns: Tags sorted by smart score (highest first), limited to top 5
    func getSuggestedTags(from tags: [Tag], expenses: [Expense]) -> [Tag] {
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        let currentWeekday = calendar.component(.weekday, from: now)

        // Calculate scores for each tag
        var tagScores: [(tag: Tag, score: Double)] = []

        for tag in tags {
            let score = calculateScore(
                for: tag,
                expenses: expenses,
                currentHour: currentHour,
                currentWeekday: currentWeekday,
                now: now
            )

            if score > 0 {
                tagScores.append((tag, score))
            }
        }

        // Sort by score descending and take top 5
        let sorted = tagScores.sorted { $0.score > $1.score }
        return Array(sorted.prefix(5).map { $0.tag })
    }

    private func calculateScore(
        for tag: Tag,
        expenses: [Expense],
        currentHour: Int,
        currentWeekday: Int,
        now: Date
    ) -> Double {
        guard let tagExpenses = tag.expenses, !tagExpenses.isEmpty else {
            return 0
        }

        var score: Double = 0

        // 1. Frequency Score (40% weight)
        // More expenses = higher score, with diminishing returns
        let frequencyScore = min(Double(tagExpenses.count) / 10.0, 1.0) * 40
        score += frequencyScore

        // 2. Recency Score (35% weight)
        // Find the most recent expense with this tag
        let recentExpenses = expenses.filter { expense in
            expense.tags?.contains(where: { $0.id == tag.id }) == true
        }

        if let mostRecent = recentExpenses.max(by: { $0.date < $1.date }) {
            let daysSinceUse = calendar.dateComponents([.day], from: mostRecent.date, to: now).day ?? 999

            // Score decreases as days increase
            // Used today = 35 points, used 7 days ago = ~5 points, used 30+ days ago = ~0
            let recencyScore = max(0, 35 - Double(daysSinceUse) * 1.2)
            score += recencyScore
        }

        // 3. Time-of-Day Pattern Score (15% weight)
        // Check if this tag is commonly used at this time of day
        let hourlyMatches = recentExpenses.filter { expense in
            let expenseHour = calendar.component(.hour, from: expense.date)
            // Consider a 3-hour window
            return abs(expenseHour - currentHour) <= 1 ||
                   abs(expenseHour - currentHour) >= 23 // Handle midnight wraparound
        }

        if !recentExpenses.isEmpty {
            let timeMatchRatio = Double(hourlyMatches.count) / Double(recentExpenses.count)
            score += timeMatchRatio * 15
        }

        // 4. Day-of-Week Pattern Score (10% weight)
        // Check if this tag is commonly used on this day
        let weekdayMatches = recentExpenses.filter { expense in
            calendar.component(.weekday, from: expense.date) == currentWeekday
        }

        if !recentExpenses.isEmpty {
            let weekdayMatchRatio = Double(weekdayMatches.count) / Double(recentExpenses.count)
            score += weekdayMatchRatio * 10
        }

        return score
    }
}
