# Track: Implement Smart Tag Suggestions & Hierarchy

## Context
The current tag picker is a flat grid. To support "Rapid Manual Entry", we should surface frequently used tags and fully utilize the hierarchical structure (Parent/Child tags) already defined in our data model.

## Goal
Improve the tag selection experience with smart suggestions and intuitive navigation of nested tags.

## Requirements

### 1. Smart Suggestions
- Surface the top 5 most frequently used tags at the top of the picker.
- Calculate frequency based on the total count of `Expense` records associated with each tag.

### 2. Hierarchical Navigation
- Update `TagPickerView` to support drill-down navigation.
- If a tag has children, show a chevron. Tapping it shows only the child tags.
- Breadcrumb navigation to return to the parent level.

### 3. Visual Polish
- Display parent context (e.g., "Food > Groceries") in the transaction list and detail views.

## Technical Considerations
- Use SwiftData's `FetchDescriptor` with grouping or count-based sorting for suggestions.
- Ensure the recursive navigation in SwiftUI handles deep nesting without performance issues.
