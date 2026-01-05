# Track: Implement Recurring Expenses (Subscriptions)

## Context
Many expenses are predictable (Rent, Netflix, Gym). Users need a way to manage these without re-entering the details every time, while still maintaining the "Accountability Moment" of deliberate logging.

## Goal
Implement a recurring expense management system that surfaces "Due Today" items for quick, one-tap confirmation.

## Requirements

### 1. Data Model
- Create `RecurringExpense` model:
    - `name: String`
    - `amount: Decimal`
    - `frequency: Enum` (weekly, monthly, yearly)
    - `startDate: Date`
    - `nextDueDate: Date`
    - `tag: Tag?`

### 2. Management UI
- Add a "Recurring" section in `SettingsView` or a dedicated sub-view.
- Allow users to Create, Edit, and Delete recurring expenses.

### 3. Confirmation Flow
- In `HomeFeedView`, if a recurring expense is due, show a "Due Today" card.
- User can tap "Confirm Log" to create a standard `Expense` record for the amount.
- App automatically calculates the next `nextDueDate` after confirmation.

## Technical Considerations
- Use SwiftData for the new model.
- Implement logic to handle overdue recurring items (e.g., if the user didn't open the app for 3 days).
