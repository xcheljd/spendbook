# Spendbook Project Structure Guide

This document outlines the current project structure for Spendbook. The project follows a modern, feature-based organization managed by **XcodeGen**.

## 📁 Final Folder Structure

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
│   │   ├── TransactionRow.swift (Extracted)
│   │   ├── SafeToSpendCard.swift (Extracted)
│   │   ├── StreakSummaryCard.swift
│   │   ├── ForecastingView.swift
│   │   ├── FilteredExpenseList.swift
│   │   └── EmptyStateView.swift (Extracted)
│   │
│   ├── AddEntry/
│   │   ├── AddEntryAmountScreen.swift
│   │   ├── AddEntryContextScreen.swift
│   │   ├── AmountKeypadView.swift
│   │   └── ScannerView.swift
│   │
│   └── [Other View Folders...]
│
├── Services/
│   ├── Protocols/ (Internal Protocols)
│   │   ├── ReceiptScannerProtocol.swift
│   │   ├── NotificationServiceProtocol.swift
│   │   └── SecurityServiceProtocol.swift
│   │
│   ├── ReceiptScannerService.swift
│   ├── NotificationService.swift
│   ├── SecurityService.swift
│   ├── SecurityManager.swift
│   └── [Other Services...]
│
├── Extensions/
│   └── Color+Catppuccin.swift
│
├── Utilities/
│   └── Theme.swift
│
├── Widgets/
│   ├── SpendBookWidget.swift
│   └── Info.plist (Fixed CFBundleVersion)
│
└── Tests/
    └── AppTests/ (With Info.plist generation)
```

## 📋 Modern Architecture Highlights

### Concurrency (Swift 6)
All services and managers are isolated to the `@MainActor` to ensure UI thread safety and prevent data races. Protocols are also marked `@MainActor` to maintain consistency during dependency injection.

### Project Management
The project uses `xcodegen` (`project.yml`). 
- **Physical Folders**: Xcode groups now strictly match the physical folder structure on disk.
- **Automatic Linking**: Files added to folders are automatically linked to targets upon running `xcodegen generate`.

### Testing Strategy
- **Test Host**: The main app target is used as the test host.
- **Info.plist**: `SpendBookTests` auto-generates its Info.plist to avoid "Multiple commands produce" errors while maintaining correct bundle metadata.

## 🔒 Required Permissions

### Implemented Permissions (App/Info.plist)
1. **Camera Access** (`NSCameraUsageDescription`)
2. **Photo Library Access** (`NSPhotoLibraryUsageDescription`)
3. **Face ID/Touch ID** (`NSFaceIDUsageDescription`) - Verified for Privacy Shield.

## 📦 Implementation Checklist ✅ COMPLETED

- [x] **Phase 1: Structure Reorganization**
- [x] **Phase 2: Modern Tooling (XcodeGen)**
- [x] **Phase 3: Swift 6 Concurrency Fixes**
- [x] **Phase 4: Component Extraction**
- [x] **Phase 5: Service Protocol Abstraction**

---

**Last Updated**: January 17, 2026
