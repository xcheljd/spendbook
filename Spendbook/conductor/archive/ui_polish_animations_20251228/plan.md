# Plan: Implement UI Polish & Micro-interactions

## Phase 1: Tactile Keypad & Haptics
- [x] Update `AmountKeypadView`
    - Add scale effect on button press.
    - Integrate `.sensoryFeedback(.impact, trigger: ...)` for every digit tap.

## Phase 2: Animated Goals & Header
- [x] Update `GoalProgressCard`
    - Use an `onAppear` animation to transition the progress bar width from 0 to current.
- [x] Update `HomeFeedView` Header
    - Apply `.contentTransition(.numericText())` to amount displays.
    - Ensure currency changes animate smoothly.

## Phase 3: Streak Delight
- [x] Update `StreakItem`
    - Implement a repeating pulse animation (`scaleEffect`) for the flame icon.
- [x] Implement Milestone Celebration
    - Create a simple logic to detect a *newly reached* milestone and trigger a one-time "pop" animation.

## Phase 4: Filter Polish
- [x] Update `ActiveFiltersView`
    - Ensure `FilterChip` additions/removals are wrapped in `withAnimation(.spring)`.

## Phase 5: Verification
- [x] Manual Verification
    - Test keypad feel on device (Haptics).
    - Verify progress bars animate when opening the Goals dashboard.
    - Verify the flame pulses in the header.
- [x] [checkpoint: 0046f98] Checkpoint Phase 5
