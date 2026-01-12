# 📦 Project Reorganization Guide

This guide walks you through reorganizing your Spendbook project to follow best practices for iOS app structure.

## 🎯 Goals

- Improve code discoverability and maintainability
- Group related files together by feature
- Separate concerns (Models, Views, Services, etc.)
- Make onboarding new developers easier
- Improve Xcode navigation experience

## 📋 Before You Start

### Prerequisites

1. **Commit your current work**
   ```bash
   git add .
   git commit -m "Before project reorganization"
   ```

2. **Create a backup** (optional but recommended)
   ```bash
   git branch backup-before-restructure
   ```

3. **Close Xcode** and reopen to ensure clean state

## 🗂️ Step 1: Create Group Structure

In Xcode, create the following group hierarchy:

### Root Level Groups

1. Right-click on your project name in the navigator
2. Select **New Group**
3. Create these groups in order:

```
Spendbook/
├── 📁 App
├── 📁 Models
├── 📁 Views
├── 📁 Services
├── 📁 Extensions
├── 📁 Utilities
├── 📁 Widgets
└── 📁 Tests
```

### Sub-Groups Under Views

Right-click on **Views** group and create these sub-groups:

```
Views/
├── 📁 Home
├── 📁 AddEntry
├── 📁 Settings
├── 📁 Goals
├── 📁 Insights
├── 📁 Onboarding
├── 📁 Filters
├── 📁 EmptyStates
└── 📁 RecurringExpenses
```

## 🚚 Step 2: Move Files to Groups

Now drag and drop files into their appropriate groups. Here's the complete mapping:

### App Group
Move these files to **App/**:
- `SpendbookApp.swift`
- `Info.plist`

### Models Group
Move these files to **Models/**:
- `Expense.swift` *(search for this file)*
- `Tag.swift` *(search for this file)*
- `BudgetGoal.swift`
- `RecurringExpense.swift` *(search for this file)*
- `FilterSettings.swift`

### Views/Home Group
Move these files to **Views/Home/**:
- `HomeFeedView.swift`
- `FilteredExpenseList.swift`
- `StreakCalendarView.swift`

**Optional**: Extract these components from `HomeFeedView.swift` into separate files:
- Create `TransactionRow.swift` (already defined in HomeFeedView)
- Create `SafeToSpendCard.swift` (already defined in HomeFeedView)
- Create `StreakSummaryCard.swift` *(search for this file)*
- Create `ForecastingView.swift` *(search for this file)*

### Views/AddEntry Group
Move these files to **Views/AddEntry/**:
- `AddEntryAmountScreen.swift`
- `AddEntryContextScreen.swift` *(search for this file)*
- `ScannerView.swift`
- `AmountKeypadView.swift` *(search for this file)*

### Views/Settings Group
Move these files to **Views/Settings/**:
- `SettingsView.swift`
- `TagManagementView.swift`
- `RecurringExpenseManagerView.swift`

### Views/Goals Group
Move these files to **Views/Goals/**:
- `GoalsDashboardView.swift` *(search for this file)*
- `SetGoalView.swift` *(if exists)*

### Views/Insights Group
Move these files to **Views/Insights/**:
- `InsightsView.swift` *(search for this file)*
- `StreakCalendarView.swift` *(if not already in Home)*

### Views/Onboarding Group
Move these files to **Views/Onboarding/**:
- `OnboardingView.swift` *(search for this file)*
- `AppLockView.swift` *(search for this file)*

### Views/Filters Group
Move these files to **Views/Filters/**:
- `FilterSheetView.swift`
- `ActiveFiltersView.swift`

### Views/EmptyStates Group
Move these files to **Views/EmptyStates/**:
- `EmptyStates.swift`
- `TransactionsEmptyState.swift` *(if separate file)*

### Views/RecurringExpenses Group
Move these files to **Views/RecurringExpenses/**:
- `RecurringDueCard.swift`

### Services Group
Move these files to **Services/**:
- `ReceiptScannerService.swift`
- `NotificationService.swift`
- `SecurityService.swift`
- `SecurityManager.swift` *(search for this file)*
- `CurrencyService.swift` *(search for this file)*
- `DataExportService.swift` *(search for this file)*
- `ChartDataService.swift`
- `StreakService.swift` *(search for this file)*
- `AccountabilityService.swift` *(search for this file)*
- `RecurringExpenseService.swift` *(search for this file)*
- `SmartTagService.swift` *(if exists)*
- `TagSeeder.swift` *(if exists)*

### Extensions Group
Move these files to **Extensions/**:
- `Color+Catppuccin.swift`
- Any other extension files (View+Extensions, etc.)

### Utilities Group
Move these files to **Utilities/**:
- `Theme.swift` *(search for this file)*
- Any helper/utility files

### Widgets Group
Move these files to **Widgets/**:
- `SpendBookWidget.swift`
- `WIDGET_SETUP_README.md`

### Tests Group
Move these files to **Tests/**:
- `AddEntryContextTests.swift`
- `DataExportServiceTests.swift`
- `PhotoIntegrationTests.swift`
- `TagTests.swift` *(if exists)*
- Any other test files

## ⚙️ Step 3: Verify and Build

### 3.1 Check Target Membership

For each moved file:
1. Select the file in Xcode
2. Open File Inspector (right panel, first tab)
3. Check **Target Membership**
4. Ensure your app target is checked
5. Ensure test files have the test target checked

### 3.2 Build the Project

1. Clean Build Folder: **Shift + Cmd + K**
2. Build: **Cmd + B**
3. Fix any issues that arise (should be none if files were moved correctly)

### 3.3 Run Tests

1. Run tests: **Cmd + U**
2. Verify all tests pass

### 3.4 Run the App

1. Select a simulator or device
2. Run: **Cmd + R**
3. Test key features:
   - Adding an expense
   - Scanning a receipt
   - Viewing settings
   - Setting a goal
   - Viewing insights

## 🔄 Step 4: Sync with File System (Recommended)

By default, Xcode groups are virtual and don't match the file system. To sync them:

### Option A: Manual Sync (Recommended for existing projects)

1. In Finder, create the same folder structure
2. Move physical files to match Xcode groups
3. In Xcode, re-link files if needed (right-click → Show in Finder)

### Option B: Use Physical Folders from Start (For new projects)

When creating groups:
1. Right-click project → **New Group with Folder**
2. This creates actual folders on disk
3. Files moved here will be in physical folders too

## 📊 Step 5: Verify Git Changes

### Review Changes
```bash
git status
```

You should see:
- Modified `.xcodeproj` file (contains group structure)
- No modified source files (just their organization changed)

### Commit
```bash
git add .
git commit -m "Reorganize project structure into feature-based groups"
```

## 🎨 Step 6: Optional Refactoring

Now that files are organized, consider these improvements:

### 6.1 Extract Large View Components

**HomeFeedView.swift** contains several components that could be separate files:

```swift
// Extract to Views/Home/TransactionRow.swift
struct TransactionRow: View {
    // ... existing code
}

// Extract to Views/Home/SafeToSpendCard.swift
struct SafeToSpendCard: View {
    // ... existing code
}

// Extract to Views/Home/EmptyStateView.swift
struct EmptyStateView: View {
    // ... existing code
}
```

### 6.2 Add Service Protocols

Make services more testable:

```swift
// Services/Protocols.swift
protocol ReceiptScannerProtocol {
    func scanReceipt(_ image: UIImage) async throws -> (amount: Decimal?, date: Date?)
}

protocol NotificationServiceProtocol {
    var isEnabled: Bool { get set }
    func requestPermissions()
    func scheduleDaily(at date: Date)
}

// Then conform your services to these protocols
extension ReceiptScannerService: ReceiptScannerProtocol { }
extension NotificationService: NotificationServiceProtocol { }
```

### 6.3 Add Documentation

Add Swift documentation to public APIs:

```swift
/// Scans a receipt image and extracts financial information using OCR.
/// 
/// This service uses Vision framework's text recognition to identify
/// amounts and dates from receipt photos.
///
/// - Parameter image: The receipt image to scan
/// - Returns: A tuple containing the extracted amount and date (if found)
/// - Throws: `ReceiptScanError` if scanning fails
func scanReceipt(_ image: UIImage) async throws -> (amount: Decimal?, date: Date?)
```

## ✅ Completion Checklist

- [ ] All groups created
- [ ] All files moved to appropriate groups
- [ ] Target membership verified for all files
- [ ] Project builds without errors
- [ ] All tests pass
- [ ] App runs successfully on simulator/device
- [ ] Key features tested and working
- [ ] Git changes committed
- [ ] (Optional) File system synced with groups
- [ ] (Optional) Large components extracted
- [ ] (Optional) Service protocols added
- [ ] (Optional) Documentation added

## 🎉 Benefits You'll See

After reorganization:

1. **Faster Navigation**: Use Cmd+Shift+O to quickly find files by feature
2. **Better PRs**: Changes grouped by feature are easier to review
3. **Easier Onboarding**: New developers can understand structure quickly
4. **Scalability**: Adding new features has a clear pattern
5. **Maintenance**: Related files are together, making changes easier

## 🆘 Troubleshooting

### Problem: "File not found" errors after moving

**Solution**: 
1. Clean build folder (Shift + Cmd + K)
2. Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Rebuild

### Problem: Imports not working

**Solution**: Swift modules are project-wide, so imports shouldn't be affected. If issues occur:
1. Make sure files are in the correct target
2. Check for duplicate file names
3. Rebuild

### Problem: Git shows all files as deleted/added

**Solution**: This is normal. Xcode stores file references in the `.xcodeproj` file. As long as actual source files haven't changed content (check with `git diff`), you're good.

### Problem: Tests can't find files

**Solution**:
1. Select test file
2. Check Target Membership includes test target
3. For @testable imports, ensure app target is properly set

## 📚 Resources

- [Apple: Organizing Your Code](https://developer.apple.com/documentation/xcode/organizing-your-code)
- [iOS Project Structure Best Practices](https://developer.apple.com/videos/play/wwdc2021/10104/)
- [Swift Style Guide](https://google.github.io/swift/)

## 🎯 What's Next?

After reorganization, consider:

1. **Add README per feature** - Document complex features in their folders
2. **Setup code review guidelines** - Use structure for better reviews
3. **CI/CD improvements** - Leverage organization for better test coverage reports
4. **Modularization** - Eventually extract features into Swift Packages

Your project is now structured for growth! 🚀
