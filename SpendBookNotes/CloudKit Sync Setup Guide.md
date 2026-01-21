# CloudKit Sync Setup Guide

## Current State
- CloudKit is **disabled** (`cloudKitDatabase: .none`)
- App works with local-only storage
- All models are CloudKit-compatible and ready for sync

## Why It's Disabled
The `.private` CloudKit option requires:
1. A container identifier string
2. Proper entitlements configuration
3. Apple Developer account setup

## Steps to Enable iCloud Sync

### 1. Add iCloud Capability in Xcode
1. Select the **SpendBook** project in navigator
2. Select the **SpendBook** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **iCloud**
6. Check **CloudKit**
7. Create or select a container (e.g., `iCloud.com.spendbook.data`)

### 2. Repeat for Widget Extension
1. Select **SpendBookWidgetExtension** target
2. Add same iCloud capability
3. Use the **same** CloudKit container

### 3. Update Code
In both files, change `.none` to `.private` with your container ID:

**SpendbookApp.swift** (line ~26):
```swift
cloudKitDatabase: .private("iCloud.com.spendbook.data")
```

**SpendBookWidget.swift** (line ~73):
```swift
cloudKitDatabase: .private("iCloud.com.spendbook.data")
```

### 4. Models Already in Schema
These models will sync automatically:
- `Expense` (includes vendor, paymentMethod relationship)
- `Tag`
- `BudgetGoal`
- `RecurringExpense`
- `PaymentMethod` (includes isArchived flag)

## Testing Sync
1. Build and run on device (simulator has limited CloudKit support)
2. Add an expense
3. Check CloudKit Dashboard (developer.apple.com) to verify data
4. Install on second device with same Apple ID
5. Verify data appears

## Optional: Sync Status Indicator
Consider adding a sync status indicator in SettingsView to show:
- Last sync time
- Sync in progress
- Sync errors

## Notes
- First sync may take a moment
- SwiftData `@Query` auto-updates when cloud data arrives
- Private database = only user's devices, not shared
