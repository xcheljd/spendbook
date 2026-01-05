# Track: Implement Spending Visualization

## Context
Users have raw data in the list view, but lack a high-level overview of their spending habits. Visualizing data helps users identify patterns and reinforces the accountability loop.

## Goal
Implement a dedicated "Insights" view featuring interactive charts to visualize spending trends and category breakdowns.

## Requirements

### 1. Insights Dashboard
- Create a new top-level view `InsightsView`.
- Access: Add a Chart icon to the `HomeFeedView` toolbar (or consider a TabView structure if the app grows, but for now, toolbar access is fine).

### 2. Spending Over Time (Bar Chart)
- **Visual:** Vertical bars representing total spending per day for the current month.
- **Interaction:** Tap/Hold on a bar to see the exact date and amount.
- **Goal Line:** Overlay the daily "Safe-to-Spend" average or limit if applicable.

### 3. Spending by Category (Donut Chart)
- **Visual:** Donut chart showing the distribution of spending across tags.
- **Legend:** clearly labeled tags with their assigned colors.
- **Sorting:** Largest categories first.

## Technical Considerations
- Use **Swift Charts** framework (iOS 16+).
- Grouping data by Day and by Tag is required before rendering.
- Ensure charts are accessible (VoiceOver).
