# Plan: Implement Localization & Multi-Currency Support

## Phase 1: Currency Infrastructure
- [x] Create `CurrencyService`
    - Logic to fetch available currencies and store the user's choice.
    - Provide a unified `format(Decimal) -> String` method.

## Phase 2: UI Updates
- [x] Refactor `AmountDisplay` components
    - Remove hardcoded "$" from `HomeFeedView`, `InsightsView`, and `AddEntryAmountScreen`.
    - Use `CurrencyService` for all formatting.
- [x] Update `AmountKeypadView`
    - Dynamically show the correct decimal separator based on `Locale.current`.

## Phase 3: Settings Integration
- [x] Update `SettingsView`
    - Add "Region & Currency" section.
    - Implement a searchable list of common currencies.

## Phase 4: Verification
- [x] Manual Verification
    - Change currency to EUR and verify comma decimals.
    - Verify charts and list reflect the new symbol.
- [x] [checkpoint: 4fe8362] Checkpoint Phase 4
