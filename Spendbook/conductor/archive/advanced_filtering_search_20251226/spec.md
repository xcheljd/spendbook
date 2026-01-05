# Track: Implement Advanced Filtering and Search

## Context
As the user base grows, the list of transactions in `HomeFeedView` becomes difficult to manage. Users need a way to find specific expenses, analyze spending within specific timeframes, or isolate expenses with specific attributes (like missing receipts).

## Goal
Implement a robust filtering and search system in the `HomeFeedView` that allows users to query their expense history.

## Requirements

### 1. Search Interface
- Add a search bar to the top of the transaction list in `HomeFeedView`.
- **Search Scope:**
    - `note`: Match text case-insensitively.
    - `tags`: Match tag names.

### 2. Filtering Options
- Create a "Filter" button/menu that presents the following options:
    - **Date Range:**
        - Presets: "This Month", "Last Month", "This Year", "All Time".
        - Custom: Start Date and End Date pickers.
    - **Tags:**
        - Multi-select list of existing tags.
    - **Amount:**
        - Min Amount and Max Amount fields.
    - **Photo Attachment:**
        - Options: "Any", "Has Photo", "No Photo".

### 3. SwiftData Querying
- Utilize SwiftData's `#Predicate` to efficiently filter `Expense` objects.
- Ensure the query updates dynamically as the user changes filters.

### 4. UI/UX
- **Filter State:** Show visual indicators (e.g., a badge on the filter icon or "chips" below the search bar) when active filters are applied.
- **Empty State:** specific empty state when a search/filter yields no results (distinct from "no expenses yet").

## Technical Considerations
- Use `.searchable` modifier in SwiftUI.
- Construct SwiftData predicates dynamically based on the state of the filter view model.
