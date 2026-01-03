# Plan: On-Device OCR for Receipt Scanning

This plan follows the TDD workflow and phase verification protocols defined in `conductor/workflow.md`.

## Phase 1: OCR Service Implementation [checkpoint: 5d3c2be]
- [x] Task: Create `ReceiptScannerService`. 69ca175
    - [x] Sub-task: Write unit tests for text recognition (mocking Vision results if possible, or testing the regex parsing logic).
    - [x] Sub-task: Implement the Vision Framework integration to extract text from images.
    - [x] Sub-task: Implement parsing logic to find "Total" amounts and Dates.
- [x] Task: Conductor - User Manual Verification 'Phase 1: OCR Service Implementation' (Protocol in workflow.md)

## Phase 2: UI Integration [checkpoint: fa98cdd]
- [x] Task: Add "Scan Receipt" action to `AddEntryAmountScreen`. ac516ad
    - [x] Sub-task: Update UI to include a camera button next to the amount display.
    - [x] Sub-task: Wire up the `ReceiptScannerService` to update the `inputAmount` state.
- [x] Task: Conductor - User Manual Verification 'Phase 2: UI Integration' (Protocol in workflow.md)
