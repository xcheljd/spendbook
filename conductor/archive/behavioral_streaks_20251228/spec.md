# Track: Implement Behavioral Streaks & Milestones

## Context
Spendbook currently calculates a simple "Logging Streak" (consecutive days with entries). To deepen the accountability moment, we need to track "No-Spend" streaks (days without spending) and provide a sense of progression through milestones.

## Goal
Expand the streak logic to include different behavioral metrics and visualize them to reward user consistency.

## Requirements

### 1. Dual Streak Logic
- **Logging Streak:** Days where the user opened the app and logged at least one item (already exists, but needs refinement to differentiate from spending).
- **No-Spend Streak:** Consecutive days where zero expenses were recorded.

### 2. Streak Visualization
- Update the `HomeFeedView` header to display both streaks or toggle between them.
- Create a `StreakCalendarView` that shows a heat map or checkmarks for the current month.

### 3. Milestones & Achievements
- Implement a system to track "Best Streaks".
- Define milestones: 7 days (Bronze), 30 days (Silver), 100 days (Gold).
- Show "New Milestone!" celebratory UI when reached.

## Technical Considerations
- Update `AccountabilityService` to handle `calculateNoSpendStreak`.
- Use `AppStorage` or a new `UserStats` SwiftData model to persist "Best Streaks" (so they don't disappear if a streak is broken).
- Use `SwiftUI` animations for milestone celebrations.
