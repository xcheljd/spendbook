# Plan: Implement Onboarding Experience

## Phase 1: UI Construction
- [x] Create `OnboardingView`
    - Carousel with 3 slides.
    - Branded typography and Catppuccin colors.
- [x] Create `BudgetSetupView` (Slide 4)
    - Input for initial monthly budget.
    - "Finish" button to persist data.

## Phase 2: Logic & Persistence
- [x] Implement Permission Flow
    - Methods to trigger Notification and Camera prompts.
- [x] Implement Completion Logic
    - Save initial budget goal to SwiftData.
    - Set `hasCompletedOnboarding = true`.

## Phase 3: Integration
- [x] Update `SpendbookApp.swift`
    - Toggle between `OnboardingView` and `AppLockView` (or `HomeFeedView`) based on completion flag.

## Phase 4: Verification
- [x] Manual Verification
    - Wipe app data.
    - Verify carousel flow.
    - Verify budget goal is created in SwiftData.
    - Verify app starts at Home on next launch.
- [x] [checkpoint: 46ab768] Checkpoint Phase 4
