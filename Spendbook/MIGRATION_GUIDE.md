# 📦 Project Reorganization Guide

This guide documents the reorganization of the Spendbook project into a clean, modern, and maintainable structure.

> **Status:** ✅ REORGANIZATION COMPLETE. The project now uses **XcodeGen** (`project.yml`) as the source of truth for the folder structure.

## 🎯 Final Goals Achieved

- **Modern Tooling**: Switched to `xcodegen` for project management.
- **Swift 6 Ready**: Fixed all concurrency and actor isolation warnings.
- **Clean Views**: Extracted massive UI blocks into reusable components.
- **Testable Services**: Decoupled concrete services using protocols.

## 🗂️ Current Structure

The project is organized into the following physical folders on disk:

```
Spendbook/
├── App/               # Entry point and Info.plist
├── Models/            # SwiftData Models
├── Views/             # SwiftUI Views (Grouped by feature)
│   ├── Home/          # Extracted components: TransactionRow, SafeToSpendCard
│   ├── AddEntry/      # Camera/Scanner views
│   └── ...
├── Services/          # Business logic and Protocols
├── Extensions/        # Color+Catppuccin and other helpers
├── Utilities/         # Theme management
├── Widgets/           # Widget Extension code
└── Tests/             # Unit and Integration tests
```

## 🛠 Project Management with XcodeGen

The `.xcodeproj` file is now managed by `project.yml`. 

### To add new files:
1. Create the file in the appropriate folder on disk.
2. Run `xcodegen generate` in the terminal.
3. The file will be automatically added to the correct group and target in Xcode.

## ⚙️ Build and Verify

### Build Verification
- **Build**: Cmd+B (Verified for iPhone 17 Simulator)
- **Tests**: Cmd+U (Test Info.plist generation fixed)
- **Widget**: Verified reliable launch with `_XCWidgetKind` env var.

## 🎨 Refactoring Applied

### Component Extraction
- `HomeFeedView.swift` was reduced by ~150 lines by extracting:
  - `TransactionRow.swift`
  - `SafeToSpendCard.swift`
  - `EmptyStateView.swift`

### Service Protocols
The following services now conform to `@MainActor` protocols:
- `ReceiptScannerService` -> `ReceiptScannerProtocol`
- `NotificationService` -> `NotificationServiceProtocol`
- `SecurityService` -> `SecurityServiceProtocol`

## ✅ Completion Status

- [x] Reorganized filesystem
- [x] Configured `project.yml`
- [x] Fixed Swift 6 concurrency errors
- [x] Resolved Widget versioning conflicts
- [x] Verified build and tests

---

**Last Updated**: January 17, 2026
