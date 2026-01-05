# Plan: Refine and Integrate OCR Receipt Scanning

## Phase 1: Scanner Logic Refinement
- [x] Update `ReceiptScannerService`
    - Implement robust Regex for currency extraction (handling $ symbols, decimals).
    - Implement robust Date parsing (formats: MM/DD/YY, DD/MM/YY, text dates).
- [x] Create `ScannerView` Wrapper
    - Wrap `VNDocumentCameraViewController` or `DataScannerViewController` for SwiftUI.

## Phase 2: Integration into Add Flow
- [x] Update `AddEntryAmountScreen` (or parent flow)
    - Add "Scan" action.
    - Handle the callback from the scanner.
    - Populate the `@State` variables for amount and date.
    - Attach the scanned image to the `Expense` model.

## Phase 3: Verification
- [x] Logic Tests
    - Test regex against sample receipt text blocks.
- [x] Manual Verification
    - Scan real receipts.
    - Verify accuracy of Amount and Date detection.
    - Verify image attachment.
- [x] [checkpoint: a1fec5b] Checkpoint Phase 4
