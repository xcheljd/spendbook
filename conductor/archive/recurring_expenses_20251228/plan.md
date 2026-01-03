# Plan: Implement Recurring Expenses (Subscriptions)

## Phase 1: Model & Service
- [x] Create `RecurringExpense` SwiftData model.
- [x] Create `RecurringExpenseService`
    - Logic to check for due items.
    - Logic to increment the due date based on frequency.
    - Logic to convert a `RecurringExpense` into a logged `Expense`.

## Phase 2: Management UI
- [x] Create `RecurringExpenseManagerView`
    - List of all recurring items.
    - Form to add/edit recurring items (selecting frequency and tag).
- [x] Integrate into `SettingsView`.

## Phase 3: Home Feed Integration
- [x] Create `RecurringDueCard`
    - A prominent card in `HomeFeedView` showing items that need confirmation.
- [x] Implement "One-Tap Log" action with Haptic feedback.

## Phase 4: Verification
- [x] Logic Tests
    - Verify date increment logic (weekly, monthly, yearly).
    - Verify correct conversion to `Expense`.
- [x] Manual Verification
    - Create a recurring expense for "Today".
    - Confirm it from the Home Feed.
    - Verify next due date is updated and a new expense appears in the list.
- [x] [checkpoint: de19ce6] Checkpoint Phase 4
