# Track: Implement iCloud Sync (CloudKit)

## Context
Privacy is paramount, but so is data safety and multi-device availability. Users expect their data to survive a device loss and sync between their iPhone and iPad.

## Goal
Enable seamless, private iCloud synchronization using SwiftData and CloudKit.

## Requirements

### 1. CloudKit Configuration
- Enable the "iCloud" capability in the App Project (Note: This usually requires Xcode UI, but we can prepare the code).
- **Schema:** Ensure `Expense`, `Tag`, and `BudgetGoal` models are compatible with CloudKit (no unique constraints that conflict, proper optionality).
- **Container:** Use the default container.

### 2. SwiftData Setup
- Configure `ModelConfiguration` to enable CloudKit sync (`cloudKitDatabase: .private`).

### 3. UI Indications
- Add a "Sync Status" indicator in `SettingsView` (optional but good for debugging).
- Ensure UI updates automatically when data arrives from the cloud (SwiftData `@Query` handles this, but testing is key).

## Technical Considerations
- **Prerequisite:** The Apple Developer Account and App ID with iCloud capability are required. Since we are in a CLI environment, we can only modify the *code*. The user must perform the Capability enablement in Xcode.
- **Code Changes:** Update `SpendbookApp.swift` `ModelContainer` configuration.
