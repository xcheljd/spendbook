# Track: Implement Habit Reminders (Notifications)

## Context
Habit formation is the key to Spendbook's success. Users may forget to log their manual entries during a busy day. Subtle nudges can help them maintain their "Logging Streak".

## Goal
Implement local push notifications that remind the user to log their spending if they haven't done so by a certain time.

## Requirements

### 1. Simple Reminders
- Allow users to set a preferred "Reminder Time" (e.g., 8:00 PM).
- Request notification permissions gracefully.

### 2. Smart Nudging
- If the user has *already* logged an expense today, do not fire the notification.
- Check the current day's entry count before triggering the reminder.

### 3. Settings Management
- Add a "Reminders" section in `SettingsView`.
- Enable/Disable toggle and Time Picker.

## Technical Considerations
- Use `UserNotifications` framework.
- Since we want "Smart" checks, use a background task or simply schedule the notification and cancel it if the app is opened and an entry is logged.
- Note: Local notifications are best handled by scheduling a repeating trigger and managing its lifecycle based on app usage.
