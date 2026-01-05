# Track: Implement Onboarding Experience

## Context
Spendbook's philosophy of "Radical Accountability" and "Manual Entry" is unique. New users need to be introduced to these concepts and guided through their initial setup (budgeting and permissions) to ensure they start building the habit immediately.

## Goal
Create a smooth, slide-based onboarding flow that educates users and sets the initial state of the app.

## Requirements

### 1. Value Proposition Carousel
- **Slide 1: Radical Accountability.** Explain that manual entry is a feature, not a missing sync.
- **Slide 2: Private by Design.** emphasize that data stays on device or in private iCloud.
- **Slide 3: Build the Habit.** Show how streaks and notifications keep you on track.

### 2. Initial Configuration
- **Set Monthly Budget:** A simple input field to create the first `BudgetGoal`.
- **Request Permissions:** Gracefully prompt for Notification and Camera access on the final slide.

### 3. Root Flow Management
- Use `AppStorage` to track `hasCompletedOnboarding`.
- If false, the app launches into `OnboardingView`.
- Upon completion, transition smoothly to `HomeFeedView`.

## Technical Considerations
- Use a `TabView` with `PageTabStyle` for the carousel.
- Trigger permission requests using `NotificationService` and `ReceiptScannerService` (or similar).
