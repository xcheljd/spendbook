# Track: Refine and Integrate OCR Receipt Scanning

## Context
The `ReceiptScannerService` exists in the codebase, but the user experience for adding an entry via scanning needs refinement. Users should be able to snap a photo and have the Amount and Date pre-filled, reducing friction while maintaining the "confirmation" step.

## Goal
Integrate the Vision Framework-based scanner into the "Add Entry" flow as a primary option.

## Requirements

### 1. Scanning Interface
- Add a "Scan Receipt" button to the `AddEntryAmountScreen` (or the initial FAB menu).
- Present a Camera View (using `VisionKit`'s `DataScannerViewController` or custom `AVFoundation` setup if targeting older iOS, but iOS 18 supports the new generic document scanner).

### 2. Intelligence
- **Text Recognition:** Extract text from the image.
- **Parsing:** Heuristics to identify the "Total" amount (highest dollar value usually) and the Transaction Date.

### 3. User Confirmation
- After scanning, navigate to the Entry screen with:
    - Amount pre-filled.
    - Date pre-filled.
    - Photo attached.
- User *must* confirm or edit the values (Human-in-the-loop).

## Technical Considerations
- Enhance `ReceiptScannerService.swift` with regex patterns for Prices and Dates.
- Use `VNRecognizeTextRequest` if not using `DataScannerViewController`.
- Ensure performance is snappy.
