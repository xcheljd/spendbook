import Foundation

/// Service responsible for financial math, streak calculations, and budget projections.
struct AccountabilityService {
    
    // MARK: - Safe-to-Spend Logic
    
    /// Calculates the maximum daily spending amount allowed to stay within budget for the remainder of the period.
    /// - Parameters:
    ///   - totalBudget: The total budget limit for the period.
    ///   - currentSpend: The amount already spent in the current period.
    ///   - daysRemaining: Number of days left in the period (including today).
    /// - Returns: The safe daily limit. Returns 0 if over budget or no days remain.
    func calculateDailySafeToSpend(totalBudget: Decimal, currentSpend: Decimal, daysRemaining: Int) -> Decimal {
        guard daysRemaining > 0 else { return 0 }
        
        let remainingBudget = totalBudget - currentSpend
        
        if remainingBudget <= 0 {
            return 0
        }
        
        return remainingBudget / Decimal(daysRemaining)
    }
    
    // MARK: - Streak Logic
    
    /// Calculates the current consecutive logging streak based on expense dates.
    /// - Parameter entryDates: Array of dates when expenses were logged.
    /// - Returns: Count of consecutive days where logging occurred.
    func calculateStreak(from entryDates: [Date]) -> Int {
        // 1. Sort dates descending (newest first)
        let sortedDates = entryDates.sorted(by: { $0 > $1 })
        
        guard let newestDate = sortedDates.first else { return 0 }
        
        // 2. Check if the newest entry is today or yesterday
        // If the last entry was 2 days ago, streak is broken (0)
        let calendar = Calendar.current
        if !calendar.isDateInToday(newestDate) && !calendar.isDateInYesterday(newestDate) {
            return 0
        }
        
        // 3. Iterate and count consecutive days
        var streak = 1
        var currentDate = newestDate
        
        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i]
            
            // Check if same day (ignore multiple entries on same day)
            if calendar.isDate(previousDate, inSameDayAs: currentDate) {
                continue
            }
            
            // Check if consecutive (yesterday)
            if let expectedYesterday = calendar.date(byAdding: .day, value: -1, to: currentDate),
               calendar.isDate(previousDate, inSameDayAs: expectedYesterday) {
                streak += 1
                currentDate = previousDate
            } else {
                // Gap found
                break
            }
        }
        
        return streak
    }
    
    // MARK: - No-Spend Streak
    
    /// Calculates the number of consecutive days without any spending starting from today backwards.
    /// - Parameter expenses: The list of all logged expenses.
    /// - Returns: Count of consecutive days with zero spending.
    func calculateNoSpendStreak(from expenses: [Expense]) -> Int {
        // If there are no expenses at all, there's no tracking happening, so streak is 0
        guard !expenses.isEmpty else {
            return 0
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get all dates where spending occurred, unique by day
        let spendDates = Set(expenses.map { calendar.startOfDay(for: $0.date) })
        
        // If today has spending, no-spend streak is 0
        if spendDates.contains(today) {
            return 0
        }
        
        // Find the most recent day with spending
        let sortedSpendDates = spendDates.sorted(by: >)
        guard let mostRecentSpendDate = sortedSpendDates.first else {
            return 0
        }
        
        // If the most recent spending was today, streak is 0 (already checked above, but belt & suspenders)
        if mostRecentSpendDate == today {
            return 0
        }
        
        // Count consecutive no-spend days from today backwards until we hit a spending day
        var streak = 0
        var checkDate = today
        
        while !spendDates.contains(checkDate) && checkDate > mostRecentSpendDate {
            streak += 1
            guard let nextDate = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = nextDate
            
            // Safety break
            if streak > 365 { break }
        }
        
        return streak
    }
    
    // MARK: - Forecasting Logic
    
    /// Predicts total monthly spend based on current pace.
    /// - Parameters:
    ///   - currentSpend: Amount spent so far this month.
    ///   - daysPassed: Number of days elapsed in the current month.
    ///   - totalDaysInMonth: Total days in the current month (e.g., 28, 30, 31).
    /// - Returns: The projected total at end of month.
    func calculateProjectedMonthlySpend(currentSpend: Decimal, daysPassed: Int, totalDaysInMonth: Int) -> Decimal {
        guard daysPassed > 0 else { return 0 }
        let averageDailySpend = currentSpend / Decimal(daysPassed)
        return averageDailySpend * Decimal(totalDaysInMonth)
    }
    
    /// Estimates the date when the current budget will be exhausted at the current spending pace.
    /// - Parameters:
    ///   - totalBudget: The total budget limit.
    ///   - currentSpend: Amount spent so far.
    ///   - daysPassed: Days elapsed in current period.
    /// - Returns: Predicted date of exhaustion, or nil if current spend is zero.
    func calculateBudgetExhaustionDate(totalBudget: Decimal, currentSpend: Decimal, daysPassed: Int) -> Date? {
        guard daysPassed > 0, currentSpend > 0 else { return nil }
        let averageDailySpend = currentSpend / Decimal(daysPassed)
        guard averageDailySpend > 0 else { return nil }
        
        let remainingBudget = totalBudget - currentSpend
        if remainingBudget <= 0 { return Date() }
        
        let daysRemainingAtCurrentPace = Double(truncating: (remainingBudget / averageDailySpend) as NSNumber)
        return Calendar.current.date(byAdding: .day, value: Int(ceil(daysRemainingAtCurrentPace)), to: Date())
    }
}
