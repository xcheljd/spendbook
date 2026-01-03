# Plan: Implement Habit Reminders (Notifications)

## Phase 1: Notification Infrastructure
- [x] Create `NotificationService`
    - Logic to request permissions.
    - Logic to schedule a daily reminder at a specific `DateComponents`.
    - Logic to cancel all pending notifications.

## Phase 2: Logging Integration
- [x] Implement Smart Cancellation
    - Whenever an `Expense` is saved, check if today's logging goal is met.
    - If met, cancel today's remaining reminder (if applicable) or reschedule for tomorrow.

## Phase 3: Settings UI
- [x] Update `SettingsView`
    - Add "Reminders" section.
    - TimePicker for reminder time.
    - "Test Notification" button for verification.

## Phase 4: Verification
- [x] Manual Verification
    - Enable reminders.
    - Set time to 1 minute from now.
    - Lock device and wait for notification.
    - Log an expense and verify no more notifications for the day.
- [x] [checkpoint: 9c5903f] Checkpoint Phase 4
