# Track: Implement UI Polish & Micro-interactions

## Context
While Spendbook is fully functional, the user interface currently lacks the "delight" factor that makes a habit-building app engaging. Subtle animations and micro-interactions will provide better feedback and make the app feel more premium.

## Goal
Enhance the user experience through polished animations, smooth transitions, and tactile feedback.

## Requirements

### 1. Interactive Keypad
- Add a subtle scale animation (e.g., 0.95x) to `AmountKeypadView` buttons when pressed.
- Implement standard haptic feedback on keypad taps.

### 2. Animated Progress & Values
- **Goal Bars:** Animate the progress bars in `GoalsDashboardView` from 0% to the actual percentage whenever the view appears.
- **Header Numbers:** Use smooth transitions (like `.contentTransition(.numericText)`) for the "Safe to Spend" and "Total Spent" values in the `HomeFeedView`.

### 3. Streak & Milestone Celebrations
- **Pulsing Flame:** If a streak is active, the flame icon in the `StreakSummaryCard` should have a subtle, continuous pulse animation.
- **Milestone Pop:** When a user hits a milestone (7, 30, 100 days), show a celebratory "pop" or scale effect on the streak card.

### 4. Smooth Feed Transitions
- Ensure the active filter chips slide in and out smoothly when added or removed.

## Technical Considerations
- Use SwiftUI's `withAnimation` and `animation(_:value:)` modifiers.
- Utilize `SensoryFeedback` (iOS 17+) for haptics.
- Keep animations subtle (usually 0.2s - 0.4s duration) to maintain the "efficiency first" UX principle.
