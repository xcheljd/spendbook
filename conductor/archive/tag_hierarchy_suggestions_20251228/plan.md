# Plan: Implement Smart Tag Suggestions & Hierarchy

## Phase 1: Suggestion Logic
- [x] Update `TagPickerView` Data Fetching
    - Implement a query to fetch tags sorted by `expenses.count`.
    - Create a "Frequently Used" section in the UI.

## Phase 2: Hierarchical UI
- [x] Refactor `TagPickerView`
    - Implement state to track the `currentParentTag`.
    - Filter displayed tags based on the current parent.
    - Add "Back" button when browsing children.
- [x] Update `TagButton`
    - Add chevron icon if `tag.children` is not empty.

## Phase 3: Display Logic
- [x] Create `TagHierarchyString` helper
    - A utility to generate the full "Parent > Child" string.
- [x] Update `TransactionRow` and `AddEntryContextScreen` to show the full hierarchy.

## Phase 4: Verification
- [x] Logic Tests
    - Verify frequency calculation logic.
- [x] Manual Verification
    - Create nested tags and navigate them.
    - Log expenses and verify the "Frequent" list updates.
- [x] [checkpoint: 927166f] Checkpoint Phase 4
