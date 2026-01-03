# Track: Implement Spending Forecasting & Nudging

## Context
Users know what they've spent, but it's hard to tell if their current pace is sustainable. By projecting their current spending velocity against their monthly goal, the app can provide early warnings and positive reinforcement.

## Goal
Implement a forecasting engine that predicts end-of-month spending and nudges the user to adjust their habits if they are on track to exceed their limit.

## Requirements

### 1. Velocity Calculation
- Calculate "Average Daily Spend" for the current month.
- Calculate "Projected Monthly Total" (Average Daily Spend * Days in Month).

### 2. UI Status Indicators
- Add a "Pace" indicator to the `HomeFeedView` header.
- Statuses: 
    - **Under Budget:** Projected total < Goal.
    - **Running High:** Projected total is within 10% of Goal.
    - **Over Pace:** Projected total > Goal.
- Show "Predicted Exhaustion Date" (the date when the user is expected to run out of budget).

### 3. Smart Nudging
- If the user is "Over Pace", show a helpful nudge: "At this rate, you'll reach your limit by the 22nd. Try to save $X/day to stay on track."

## Technical Considerations
- Update `AccountabilityService` with the math.
- Ensure the forecast excludes "one-off" large anomalies if possible (optional/v2).
