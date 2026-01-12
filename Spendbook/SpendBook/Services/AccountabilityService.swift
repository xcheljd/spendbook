import Foundation

struct AccountabilityService {
    
    // MARK: - Safe-to-Spend Logic
    
    func calculateDailySafeToSpend(totalBudget: Decimal, currentSpend: Decimal, daysRemaining: Int) -> Decimal {
        guard daysRemaining > 0 else { return 0 }
        
        let remainingBudget = totalBudget - currentSpend
        
        if remainingBudget <= 0 {
            return 0
        }
        
        return remainingBudget / Decimal(daysRemaining)
    }
    
    // MARK: - Streak Logic
    
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
    
    func calculateProjectedMonthlySpend(currentSpend: Decimal, daysPassed: Int, totalDaysInMonth: Int) -> Decimal {
        guard daysPassed > 0 else { return 0 }
        let averageDailySpend = currentSpend / Decimal(daysPassed)
        return averageDailySpend * Decimal(totalDaysInMonth)
    }
    
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
