# Plan: Accountability Goals & "Safe-to-Spend" Metrics

This plan follows the TDD workflow and phase verification protocols defined in `conductor/workflow.md`.

## Phase 1: Budget Data Model [checkpoint: 6a731fe]
- [x] Task: Define the `BudgetGoal` SwiftData model. dde1edb
    - [x] Sub-task: Write unit tests for goal initialization and validation.
    - [x] Sub-task: Implement the model and relationship with `Tag`.
- [x] Task: Conductor - User Manual Verification 'Phase 1: Budget Data Model' (Protocol in workflow.md)

## Phase 2: Accountability Logic [checkpoint: 0cd03e8]
- [x] Task: Implement `AccountabilityService`. b287d31
    - [x] Sub-task: Write unit tests for "Safe-to-Spend" calculations.
    - [x] Sub-task: Write unit tests for Streak detection logic.
    - [x] Sub-task: Implement the service logic.
- [x] Task: Conductor - User Manual Verification 'Phase 2: Accountability Logic' (Protocol in workflow.md)

## Phase 3: Goals & Progress UI [checkpoint: 50c7863]
- [x] Task: Create `GoalsDashboardView`. f142680
    - [x] Sub-task: Write UI tests for goal progress bars.
    - [x] Sub-task: Implement the view showing all active goals and their current status.
- [x] Task: Create `SetGoalView` sheet. 353a3ad
    - [x] Sub-task: Write tests for goal creation and persistence.
    - [x] Sub-task: Implement the form to set Type, Period, and Amount.
- [x] Task: Conductor - User Manual Verification 'Phase 3: Goals & Progress UI' (Protocol in workflow.md)

## Phase 4: Home Screen Integration [checkpoint: 456cfb7]
- [x] Task: Update `HomeFeedView` Header. f170716
    - [x] Sub-task: Implement the "Safe-to-Spend" card with Catppuccin styling.
    - [x] Sub-task: Integrate behavioral streak indicators.
- [x] Task: Conductor - User Manual Verification 'Phase 4: Home Screen Integration' (Protocol in workflow.md)
