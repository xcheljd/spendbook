# Specification: On-Device OCR for Receipt Scanning

## Overview
This track implements "Local Intelligence" by using Apple's Vision Framework to scan receipt photos. The goal is to reduce the friction of manual entry by automatically suggesting the "Amount" and "Date" from a captured or selected photo, while still requiring user confirmation to maintain the "accountability moment."

## User Stories
- **Scan to Start:** As a user, I want to start an entry by taking a picture of a receipt, so the app can do the heavy lifting of typing.
- **Smart Suggestions:** As a user, I want the app to populate the "Amount" field automatically if it detects a clear price on the receipt.
- **Privacy First:** As a user, I want this scanning to happen entirely on my device without sending my receipt to a cloud server.

## Functional Requirements
- **OCR Service:** A service that accepts a `UIImage` or `Data` and returns recognized text strings.
- **Parsing Logic:** Algorithms to identify potential currency amounts and dates from the raw text.
- **UI Integration:**
    - Add a "Scan Receipt" button to the `AddEntryAmountScreen` (or a pre-step).
    - When a receipt is scanned, pre-fill the `AmountKeypad` with the detected value but allow editing.

## Technical Constraints
- **Framework:** `Vision` (Apple Native).
- **Privacy:** strict on-device processing.
- **Performance:** Scanning should not freeze the UI; use Swift Concurrency (`async/await`).

## Acceptance Criteria
- User can select an image, and the app correctly identifies the total amount (e.g., finding the largest currency format number).
- The detected amount is filled into the input field.
- If no amount is found, the user is prompted to enter it manually.
