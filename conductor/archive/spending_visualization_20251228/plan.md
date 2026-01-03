# Plan: Implement Spending Visualization

## Phase 1: Data Preparation
- [x] Create `ChartDataService` (0d932f3)
    - Implement methods to aggregate `[Expense]` by day (for bar chart).
    - Implement methods to aggregate `[Expense]` by tag (for pie/donut chart).
    - Ensure empty days are filled with zero values for the Bar Chart to maintain date continuity.

## Phase 2: Chart Components
- [x] Create `SpendingTrendsChart` (490aac0)
    - Use `Chart` view with `BarMark`.
    - Implement selection/overlay for touch interaction.
- [x] Create `CategoryBreakdownChart` (490aac0)
    - Use `Chart` view with `SectorMark`.
    - Style with `Tag` colors.

## Phase 3: Insights View & Integration
- [x] Create `InsightsView` (c86651f)
    - layout the charts in a scrollable view.
    - Add a `Picker` or `SegmentedControl` to switch timeframes (This Month, Last Month, Year).
- [x] Update `HomeFeedView` (c86651f)
    - Add a "Chart" button to the toolbar to present `InsightsView`.

## Phase 4: Verification
- [x] Logic Tests
    - Verify aggregation logic sums amounts correctly.
- [x] Manual Verification
    - Verify charts match the data in the list.
    - Verify colors match the tags.
    - Verify "No Data" states handling.
- [x] [checkpoint: 86734b1] Checkpoint Phase 4
