# Plan: Implement Behavioral Streaks & Milestones

## Phase 1: Logic Expansion
- [x] Update `AccountabilityService`
    - Implement `calculateNoSpendStreak(from expenses: [Expense], startingDate: Date) -> Int`.
    - Enhance `calculateStreak` (Logging Streak) to be more robust.
- [x] Create `StreakService`
    - Logic to track "All-time Best" streaks using `UserDefaults` or `AppStorage`.
    - Logic to check for milestone achievements.

## Phase 2: Visual Elements
- [x] Create `StreakSummaryCard`
    - A compact view for the header showing current and best streaks.
    - Animation for the "flame" icon based on streak length.
- [x] Create `StreakCalendarView`
    - A simple grid showing the current month and days with activity/no-spend status.

## Phase 3: Integration
- [x] Update `HomeFeedView`
    - Replace the simple flame text with `StreakSummaryCard`.
- [x] Update `GoalsDashboardView`
    - Integrate the `StreakCalendarView` and Milestone history.

## Phase 4: Verification
- [x] Logic Tests
    - Test `calculateNoSpendStreak` with various date gaps.
    - Test Milestone detection logic.
- [x] Manual Verification
    - Log expenses across multiple days (using manual date adjustment) to trigger streaks.
    - Verify milestone UI appears at 7 days.
- [x] [checkpoint: 80131a9] Checkpoint Phase 4
