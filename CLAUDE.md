# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Spendbook is an iOS 18+ expense tracking app built with Swift 6 and SwiftUI. It emphasizes privacy (local-first with optional iCloud sync) and manual entry for self-accountability. The app uses SwiftData for persistence with CloudKit integration.

## Build & Test Commands

This is a native iOS Xcode project. No Package.swift or .xcodeproj files are committed - open the project in Xcode.

```bash
# Build (from command line)
xcodebuild -scheme Spendbook -destination 'platform=iOS Simulator,name=iPhone 16'

# Run tests
xcodebuild test -scheme Spendbook -destination 'platform=iOS Simulator,name=iPhone 16'

# Run a single test file
xcodebuild test -scheme Spendbook -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:SpendbookTests/DataManagerTests
```

## Architecture

### Data Layer
- **SwiftData models** in `Sources/App/Models/`: `Expense`, `Tag`, `BudgetGoal`, `RecurringExpense`, `FilterSettings`
- **Tags are hierarchical** with parent-child relationships for nested categories (e.g., "Food > Dining Out")
- **App group** `group.com.spendbook.data` enables widget data access
- CloudKit sync is private (`.private` database)

### Service Layer
Services in `Sources/App/Services/` handle business logic:
- `DataManager`: SwiftData CRUD operations
- `SecurityManager`: Singleton managing biometric lock with 30-second grace period
- `AccountabilityService`: Safe-to-spend calculations and budget math
- `StreakService`: Consecutive day tracking algorithms
- `ReceiptScannerService`: Vision framework OCR with currency pattern matching
- `ChartDataService`: Data aggregation for Swift Charts

### View Layer
- Entry point: `SpendbookApp.swift` → OnboardingView → AppLockView (if enabled) → HomeFeedView
- Reusable components in `Sources/App/Views/Components/`
- **Catppuccin theme**: Mocha (dark) / Latte (light) via `Color+Catppuccin.swift`

### Widgets
- `Sources/Widgets/`: Quick-log widget using App Intents (`LogOneDollarIntent`)
- `WidgetDataProvider` accesses shared data container

## Testing Patterns

Tests use in-memory SwiftData containers for isolation:

```swift
let config = ModelConfiguration(isStoredInMemoryOnly: true)
modelContainer = try ModelContainer(for: Expense.self, Tag.self, configurations: config)
```

Test files mirror source structure in `Tests/AppTests/` (Models, Services, Views, Components).

## Conductor Documentation

The `conductor/` directory contains project meta-documentation:
- `product.md`: Product vision and features
- `tech-stack.md`: Technology decisions
- `workflow.md`: Development workflow and TDD requirements
- `product-guidelines.md`: Catppuccin color scheme, UX principles
- `plan.md`: Task tracking (mark `[ ]` → `[~]` → `[x]`)

## Key Conventions

- **TDD workflow**: Write failing tests first, then implement
- **Code coverage target**: >80%
- **Commit format**: `<type>(<scope>): <description>` (e.g., `feat(goals): Add weekly budget limits`)
- **MainActor**: Services and tests that touch SwiftData require `@MainActor`
- **Async patterns**: Use `async/await` with proper continuation patterns
