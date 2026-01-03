# Plan: Implement Spending Forecasting & Nudging

## Phase 1: Forecasting Logic
- [x] Update `AccountabilityService`
    - Implement `calculateProjectedMonthlySpend()`.
    - Implement `calculateBudgetExhaustionDate()`.
    - Implement `calculateDailySavingRequiredToStayOnTrack()`.

## Phase 2: UI Integration
- [x] Create `ForecastingView` component
    - Small banner or card for the `HomeFeedView` header.
    - Color-coded icons (Checkmark, Warning, Alert).
- [x] Implement "Forecast Details" sheet
    - Breakdown of the math: "You spend $X/day on average."

## Phase 3: Notifications & Nudges
- [x] Integrate with `NotificationService`
    - Schedule a weekly "Status Report" notification with the current forecast.

## Phase 4: Verification
- [x] Logic Tests
    - Verify projection math with various spending patterns.
- [x] Manual Verification
    - Log high-value items and verify the "Pace" indicator turns red.
    - Verify "Exhaustion Date" updates correctly.
- [x] [checkpoint: 7d96fab] Checkpoint Phase 4
