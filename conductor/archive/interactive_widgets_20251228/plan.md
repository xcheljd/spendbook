# Plan: Implement Interactive Widgets

## Phase 1: Deep Linking & App Groups
- [x] Configure App Group
    - Ensure the SwiftData container is initialized with an App Group identifier to allow shared access.
- [x] Implement URL Schemes
    - Add `spendbook://add` handling in `SpendbookApp.swift`.
    - Update `HomeFeedView` to respond to the incoming URL by showing the `AddEntryAmountScreen`.

## Phase 2: Widget Infrastructure
- [x] Create Widget Extension
    - Boilerplate setup for `SpendbookWidgets`.
- [x] Implement `WidgetDataProvider`
    - Logic to fetch "Safe to Spend" and "Streaks" from the shared SwiftData store within the widget process.

## Phase 3: Widget UI
- [x] Create `QuickLogWidget` (Small)
    - Design the UI with a large action button.
- [x] Create `StatusOverviewWidget` (Medium)
    - Design the UI with budget status, streaks, and mini-chart.
    - Reuse `Catppuccin` color extensions.

## Phase 4: Integration & Polish
- [x] Implement Interactive Buttons (App Intents)
    - Add an interactive button to the medium widget for a "Quick $1.00 Log" or similar common action.

## Phase 5: Verification
- [x] Manual Verification
    - Add widgets to the Home Screen.
    - Verify data matches the app.
    - Verify deep-linking from the small widget opens the entry screen.
- [x] [checkpoint: 592406f] Checkpoint Phase 5
