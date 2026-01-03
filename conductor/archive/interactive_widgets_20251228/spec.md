# Track: Implement Interactive Widgets

## Context
One of Spendbook's key features is "Rapid Manual Entry". To minimize friction, users should be able to log expenses or check their daily budget status directly from the iOS Home Screen without opening the app first.

## Goal
Implement a suite of iOS Home Screen widgets using WidgetKit that provide quick access to logging and real-time financial status.

## Requirements

### 1. Quick Action Widget (Small)
- **Visual:** A simple, prominent "+" button styled with Catppuccin Blue.
- **Action:** Tapping the widget deep-links directly into the `AddEntryAmountScreen`.

### 2. Status Dashboard Widget (Medium)
- **Visuals:**
    - Display "Safe to Spend Today" amount prominently.
    - Show current Logging and No-Spend streaks.
    - Include a mini-bar chart of the last 7 days of spending.
- **Action:** Tapping opens the `HomeFeedView`.

### 3. Interactive Logging (iOS 17+)
- Explore using App Intents to allow basic interactions (like incrementing a frequent quick-buy amount) directly within the widget (optional/bonus).

### 4. Shared Data
- Ensure the Widget extension can access the same SwiftData container as the main app.

## Technical Considerations
- Use **WidgetKit** and **AppIntents**.
- Configure **App Groups** to share the SwiftData store between the main target and the widget extension.
- Implement a custom URL scheme (e.g., `spendbook://add`) for deep-linking.
