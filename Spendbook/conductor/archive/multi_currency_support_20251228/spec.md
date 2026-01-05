# Track: Implement Localization & Multi-Currency Support

## Context
Spendbook currently has hardcoded USD symbols and standard date formatting. To be useful globally, users should be able to set their primary currency and see all amounts formatted according to their locale.

## Goal
Implement a flexible currency system and ensure all UI elements respect the user's regional settings.

## Requirements

### 1. Primary Currency Selection
- Add a "Currency" picker in `SettingsView`.
- Store the selected currency code (e.g., "USD", "EUR", "JPY") in `AppStorage`.

### 2. Global Amount Formatting
- Replace all hardcoded "$" with dynamic formatting based on the selected currency code.
- Ensure decimal separators (dot vs comma) follow the user's `Locale`.

### 3. Localization Ready
- Audit the codebase for hardcoded strings and prepare for string catalog implementation.

## Technical Considerations
- Use `Foundation.NumberFormatter` or the new `Decimal.formatted(.currency(code:))` API.
- Ensure the `AmountKeypadView` handles the correct decimal separator for the locale.
