# Plan: Manual Entry Loop

This plan follows the TDD workflow and phase verification protocols defined in `conductor/workflow.md`.

## Phase 1: Foundation - Data Models & SwiftData Setup [checkpoint: e125866]
- [x] Task: Define the `Expense` and `Tag` SwiftData models. 826305a
    - [x] Sub-task: Write unit tests for model initialization and relationships.
    - [x] Sub-task: Implement the models and SwiftData container configuration.
- [x] Task: Implement a basic Data Manager for CRUD operations. 3b83fa5
    - [x] Sub-task: Write unit tests for saving and fetching expenses.
    - [x] Sub-task: Implement the Data Manager logic.
- [x] Task: Conductor - User Manual Verification 'Phase 1: Foundation' (Protocol in workflow.md)

## Phase 2: Amount Entry UI [checkpoint: fe49f75]
- [x] Task: Create the `AmountKeypadView` component. 0d23721
    - [x] Sub-task: Write tests for keypad input logic (decimal handling, deletion).
    - [x] Sub-task: Implement the UI using the Catppuccin palette.
- [x] Task: Create the `AddEntryAmountScreen`. d570792
    - [x] Sub-task: Write tests for amount validation.
    - [x] Sub-task: Implement the screen layout and navigation to the next step.
- [x] Task: Conductor - User Manual Verification 'Phase 2: Amount Entry UI' (Protocol in workflow.md)

## Phase 3: Context & Tagging UI [checkpoint: bd215f0]
- [x] Task: Create the `TagPickerView`. 4b98e84
    - [x] Sub-task: Write tests for tag selection and hierarchical display.
    - [x] Sub-task: Implement the UI with color-coded tags.
- [x] Task: Create the `AddEntryContextScreen`. ef4e9e0
    - [x] Sub-task: Write tests for saving logic and integration with Data Manager.
    - [x] Sub-task: Implement the screen including Date selection and Tagging.
- [x] Task: Conductor - User Manual Verification 'Phase 3: Context & Tagging UI' (Protocol in workflow.md)

## Phase 4: Optional Photo Capture [checkpoint: 67e252f]
- [x] Task: Implement `PhotoPickerService` using PhotosUI. 1d1f1f0
    - [x] Sub-task: Write tests for image handling and compression.
    - [x] Sub-task: Implement the service logic.
- [x] Task: Integrate `PhotoCaptureView` into the `AddEntryContextScreen`. d2aa0d9
    - [x] Sub-task: Write UI tests for photo attachment/removal.
    - [x] Sub-task: Implement the UI button and preview.
- [x] Task: Conductor - User Manual Verification 'Phase 4: Optional Photo Capture' (Protocol in workflow.md)

## Phase 5: Home Feed & Navigation [checkpoint: d94edb0]
- [x] Task: Create the `HomeFeedView`. 471c253
    - [x] Sub-task: Write tests for fetching and displaying the transaction list.
    - [x] Sub-task: Implement the feed with Catppuccin styling.
- [x] Task: Implement the "Add" navigation flow. 7ac47ad
    - [x] Sub-task: Write tests for the modal transition and state cleanup.
    - [x] Sub-task: Implement the main navigation structure.
- [x] Task: Conductor - User Manual Verification 'Phase 5: Home Feed & Navigation' (Protocol in workflow.md)
