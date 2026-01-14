# Spendbook Project Structure Guide

This document outlines the current and recommended project structure for Spendbook. The existing project already follows this layout; continue organizing files according to this structure for better maintainability and scalability.

## 📁 Recommended Folder Structure

```
Spendbook/
├── App/
│   ├── SpendbookApp.swift
│   └── Info.plist
│
├── Models/
│   ├── Expense.swift
│   ├── Tag.swift
│   ├── BudgetGoal.swift
│   ├── RecurringExpense.swift
│   └── FilterSettings.swift
│
├── Views/
│   ├── Home/
│   │   ├── HomeFeedView.swift
│   │   ├── TransactionRow.swift
│   │   ├── SafeToSpendCard.swift
│   │   ├── StreakSummaryCard.swift
│   │   ├── ForecastingView.swift
│   │   └── FilteredExpenseList.swift
│   │
│   ├── AddEntry/
│   │   ├── AddEntryAmountScreen.swift
│   │   ├── AddEntryContextScreen.swift
│   │   ├── AmountKeypadView.swift
│   │   └── ScannerView.swift
│   │
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── TagManagementView.swift
│   │   └── RecurringExpenseManagerView.swift
│   │
│   ├── Goals/
│   │   └── GoalsDashboardView.swift
│   │
│   ├── Insights/
│   │   ├── InsightsView.swift
│   │   └── StreakCalendarView.swift
│   │
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   └── AppLockView.swift
│   │
│   ├── Filters/
│   │   ├── FilterSheetView.swift
│   │   └── ActiveFiltersView.swift
│   │
│   ├── EmptyStates/
│   │   ├── EmptyStates.swift
│   │   └── TransactionsEmptyState.swift
│   │
│   └── RecurringExpenses/
│       └── RecurringDueCard.swift
│
├── Services/
│   ├── ReceiptScannerService.swift
│   ├── NotificationService.swift
│   ├── SecurityService.swift
│   ├── SecurityManager.swift
│   ├── CurrencyService.swift
│   ├── DataExportService.swift
│   ├── ChartDataService.swift
│   ├── StreakService.swift
│   ├── AccountabilityService.swift
│   └── RecurringExpenseService.swift
│
├── Extensions/
│   ├── Color+Catppuccin.swift
│   └── [Other extensions]
│
├── Utilities/
│   ├── Theme.swift
│   └── [Helper utilities]
│
├── Widgets/
│   ├── SpendBookWidget.swift
│   └── WIDGET_SETUP_README.md
│
└── Tests/
    ├── AddEntryContextTests.swift
    ├── DataExportServiceTests.swift
    ├── PhotoIntegrationTests.swift
    └── [Other tests]
```

## 📋 File Categories

### App Layer
- **SpendbookApp.swift**: Main app entry point, app lifecycle, deep link handling
- **Info.plist**: App permissions and configuration

### Models (SwiftData)
All `@Model` classes that represent your data layer:
- Expense, Tag, BudgetGoal, RecurringExpense
- FilterSettings (view model data)

### Views
Organized by feature/screen:
- **Home**: Main feed and dashboard components
- **AddEntry**: Expense entry flow and scanning
- **Settings**: App settings and management screens
- **Goals**: Budget goal tracking
- **Insights**: Analytics and visualizations
- **Onboarding**: First-run experience and security
- **Filters**: Expense filtering UI
- **EmptyStates**: Placeholder views
- **RecurringExpenses**: Recurring expense components

### Services
Business logic and system integrations:
- **ReceiptScannerService**: OCR and receipt processing
- **NotificationService**: Push notifications and reminders
- **SecurityService**: Biometric authentication
- **SecurityManager**: App lock state management
- **CurrencyService**: Currency formatting and conversion
- **DataExportService**: CSV/JSON export
- **ChartDataService**: Data preparation for charts
- **StreakService**: Streak calculation and tracking
- **AccountabilityService**: Budget accountability logic
- **RecurringExpenseService**: Recurring expense management

### Extensions
SwiftUI and Foundation extensions:
- Color themes (Catppuccin)
- View modifiers
- Type extensions

### Utilities
Helper types and utilities:
- Theme management
- Constants
- Helper functions

### Widgets
Widget extension and supporting files

### Tests
Unit and integration tests organized by feature

## 🎯 Benefits of This Structure

1. **Scalability**: Easy to add new features without cluttering existing folders
2. **Discoverability**: Quick to find files by feature or responsibility
3. **Collaboration**: Clear boundaries for team members working on different features
4. **Testing**: Organized tests mirror the app structure
5. **Maintainability**: Related files are grouped together

## 🔄 Migration Steps

To reorganize your existing project:

1. In Xcode, create new Groups (folders) matching the structure above
2. Drag and drop files into their appropriate groups
3. Ensure all files are still included in the target
4. Update imports if needed (Swift should handle this automatically)
5. Run the app to verify everything still works

## ⚠️ Important Notes

- **Groups in Xcode**: These can be virtual groups (not physical folders) or actual file system folders
- **Physical Folders**: Recommended to match Xcode groups to the file system for better version control
- **Target Membership**: Always verify files remain in the correct target after moving
- **Tests**: Keep test file structure mirroring the main app structure

## 📝 Naming Conventions

- **Views**: Descriptive nouns ending in "View" (e.g., `SettingsView`)
- **Services**: Descriptive nouns ending in "Service" or "Manager" (e.g., `NotificationService`)
- **Models**: Simple nouns (e.g., `Expense`, `Tag`)
- **Extensions**: `Type+Category.swift` (e.g., `Color+Catppuccin.swift`)

## 🔒 Required Permissions (Info.plist)

Your Info.plist must include all required permission descriptions:

### ✅ Implemented Permissions
1. **Camera Access** (`NSCameraUsageDescription`)
   - **Purpose**: Receipt scanning with document scanner
   - **Used in**: `ScannerView.swift`
   - **Description**: "Spendbook needs access to your camera to scan receipts and automatically extract expense information using document scanning."

2. **Photo Library Access** (`NSPhotoLibraryUsageDescription`)
   - **Purpose**: Selecting existing receipt photos
   - **Used in**: `AddEntryAmountScreen.swift` (PhotosPicker)
   - **Description**: "Spendbook needs access to your photo library to scan receipts and automatically extract expense information."

3. **Face ID/Touch ID** (`NSFaceIDUsageDescription`)
   - **Purpose**: Biometric authentication for app security
   - **Used in**: `SecurityService.swift`
   - **Description**: "Spendbook uses Face ID to securely lock and unlock your financial data."

4. **Notifications** (Requested programmatically)
   - **Purpose**: Daily reminders and weekly reports
   - **Used in**: `NotificationService.swift`
   - **Implementation**: `UNUserNotificationCenter.current().requestAuthorization()`
   - No Info.plist entry needed ✓

### 📱 Deep Link Support

The Info.plist includes URL scheme configuration:
- **Scheme**: `spendbook://`
- **Example**: `spendbook://add` - Opens add expense screen
- **Implementation**: Handled in `SpendbookApp.swift` via `.onOpenURL()`

### 🔐 Privacy Compliance

All permission descriptions:
- ✅ Are clear and user-friendly
- ✅ Explain the specific feature that requires the permission
- ✅ Comply with App Store Review Guidelines
- ✅ Are displayed at the moment of request, not before

## 📦 Implementation Checklist

### Phase 1: Add Info.plist ✅ COMPLETED
- [x] Create `Info.plist` in the App folder
- [x] Add `NSCameraUsageDescription`
- [x] Add `NSPhotoLibraryUsageDescription`
- [x] Add `NSFaceIDUsageDescription`
- [x] Configure URL scheme for deep links

### Phase 2: Organize Project Structure (NEXT STEP)

Follow these steps to reorganize your Xcode project:

1. **Create Folder Groups in Xcode**
   - Right-click on the project root
   - Select "New Group" for each major category
   - Name them: Models, Views, Services, Extensions, Utilities, Tests

2. **Create Sub-folders**
   - Under Views, create: Home, AddEntry, Settings, Goals, Insights, Onboarding, Filters, EmptyStates, RecurringExpenses
   - This matches the structure outlined above

3. **Move Files**
   - Drag and drop each file into its appropriate folder
   - Xcode will update references automatically
   - Verify each file remains in the target (check target membership)

4. **Verify Build**
   - Build the project (⌘+B)
   - Run tests (⌘+U)
   - Run the app on simulator to verify everything works

5. **Sync with File System** (Recommended)
   - Right-click each group → "Show in Finder"
   - Ensure Xcode groups match actual folder structure
   - This helps with version control

### Phase 3: Code Quality Improvements (OPTIONAL)

Consider these additional improvements:

1. **Extract View Components**
   - `HomeFeedView.swift` is large (200+ lines)
   - Extract `TransactionRow`, `EmptyStateView`, `SafeToSpendCard` into separate files
   - Already defined in the file, just need to move to separate files

2. **Service Improvements**
   - Add protocols for services to enable easier testing
   - Example: `protocol ReceiptScannerProtocol`

3. **Error Handling**
   - Centralize error handling with custom error types
   - Consider a dedicated `Errors/` folder

4. **Documentation**
   - Add Swift documentation comments to public APIs
   - Document complex algorithms (like streak calculation)

## 🎨 Architecture Notes

### Current Architecture Strengths
- ✅ Clear separation between UI (Views) and logic (Services)
- ✅ SwiftData for persistence with proper model relationships
- ✅ Observable pattern with `@Observable` and `@StateObject`
- ✅ Proper use of Swift Concurrency (async/await)
- ✅ Comprehensive service layer

### Patterns Used
- **MVVM**: Views + Observable Services
- **Repository Pattern**: SwiftData ModelContext
- **Dependency Injection**: Services passed via environment/initialization
- **Strategy Pattern**: Multiple export formats (CSV, JSON)

## 🧪 Testing Strategy

Your test coverage includes:
- Unit tests for services (`DataExportServiceTests.swift`)
- Context tests (`AddEntryContextTests.swift`)
- Integration tests (`PhotoIntegrationTests.swift`)

Consider adding:
- Tests for `ReceiptScannerService` OCR logic
- Tests for `AccountabilityService` calculations
- Tests for `StreakService` streak calculations
- UI tests for critical user flows

