# Plan: Implement Advanced Filtering and Search

## Phase 1: Core Filtering Logic & Infrastructure
- [x] Create `FilterSettings` model
    - Define a struct/class to hold filter state: date range, selected tags, amount range, photo status.
    - Implement helper methods to check if filters are active (default state vs. modified).
- [x] Create `FilteredExpenseList` Component
    - Create a new SwiftUI View that accepts `searchText` and `FilterSettings`.
    - Implement the `init` to construct a SwiftData `#Predicate` dynamically based on the inputs.
    - Render the list of expenses using the existing `TransactionRow`.

## Phase 2: Filter Interface (UI)
- [x] Create `FilterSheetView`
    - Design a sheet with sections for:
        - Date Range (Presets + Custom Picker)
        - Tags (Flow layout or List with multi-select)
        - Amount Range (Min/Max TextFields)
        - Photo Attachments (Picker/Segmented Control)
- [x] Create `ActiveFiltersView` (Chips)
    - Create a horizontal scroll view to display "chips" for active filters.
    - Add "X" buttons to chips to quickly remove specific filters.

## Phase 3: Integration & Search
- [x] Update `HomeFeedView`
    - Add `@State` for `searchText` and `filterSettings`.
    - Add `.searchable` modifier to the `NavigationStack`.
    - Add a "Filter" button to the toolbar to open `FilterSheetView`.
    - Replace the existing `List` loop with `FilteredExpenseList`, passing the state.
- [x] Implement "No Results" State
    - Create a specific view for when the filter/search yields zero results (distinct from an empty database).

## Phase 4: Verification & Polish
- [x] Integration Tests
    - Verify search text filters by note and tag.
    - Verify date range filters (inclusive bounds).
    - Verify amount range filters.
    - Verify photo filters.
- [x] UI Polish
    - Ensure filter sheet looks good in light/dark mode (Catppuccin).
    - Animation for adding/removing chips.
- [x] [checkpoint: 63f2d1f] Checkpoint Phase 4
