# Plan: Implement iCloud Sync (CloudKit)

## Phase 1: Model Configuration
- [x] Review Models
    - Ensure all properties in `Expense`, `Tag`, `BudgetGoal` are CloudKit compatible (mostly optional or with default values).
    - *Note:* SwiftData handles most of this, but relationships need to be optional.

## Phase 2: App Configuration
- [x] Update `SpendbookApp.swift`
    - Modify `ModelConfiguration` to explicitly set `cloudKitDatabase: .private` (although default behavior usually enables it if the entitlement is present, explicit is better for intent).

## Phase 3: Settings & Diagnostics
- [x] Update `SettingsView`
    - Add a simple text footnote: "iCloud Sync: Enabled/Disabled" (based on reachability if possible, or just static text instructing user).

## Phase 4: Verification
- [x] Manual Verification (User Required)
    - Since this requires Entitlements and multiple devices, the user must verify this in Xcode/TestFlight.
    - We will verify the code compiles and the configuration is set correctly.
- [x] [checkpoint: 4fcac41] Checkpoint Phase 4
