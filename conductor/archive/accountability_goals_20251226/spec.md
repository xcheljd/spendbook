# Specification: Accountability Goals & "Safe-to-Spend" Metrics

## Overview
This track implements the core motivational features of Spendbook. It moves the app from a simple logger to a proactive financial coach by providing positive reinforcement through "Safe-to-Spend" daily limits and tracking behavioral streaks.

## User Stories
- **Daily Guidance:** As a user, I want to see exactly how much I can spend today without breaking my monthly budget, so I can make informed choices.
- **Budget Guardrails:** As a user, I want to set spending caps for specific tags (e.g., "Dining Out") so I can stay disciplined.
- **Behavioral Streaks:** As a user, I want to see how many consecutive days I've logged my expenses or stayed under budget, to build a positive habit.

## Functional Requirements
- **Goal Model:**
    - `BudgetGoal`: Type (Total/Category), Period (Weekly/Monthly), Limit Amount.
- **Calculation Logic:**
    - "Safe-to-Spend": (Total Budget - Current Spend) / Days Remaining in Period.
    - Streak Detection: Consecutive days with at least one entry and spend < daily budget.
- **UI Integration:**
    - New "Goals" tab or section to set and view budgets.
    - Enhanced Header in `HomeFeedView` showing the "Safe-to-Spend" amount.
    - Visual indicators (e.g., progress bars) for category-specific goals.

## Technical Constraints
- **Storage:** SwiftData for persisting goals.
- **Theming:** Use Catppuccin accent colors (Green for "under budget", Red for "over budget").

## Acceptance Criteria
- User can set a monthly total budget of $1000.
- Home screen correctly displays the daily "Safe-to-Spend" amount based on current date and month's spending.
- Categories with spending limits show a progress bar in the category list.
