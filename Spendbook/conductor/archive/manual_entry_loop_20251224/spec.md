# Specification: Manual Entry Loop

## Overview
This track implements the foundational user journey of Spendbook: manually recording an expense. It focuses on a high-speed, multi-step entry flow that supports the project's goals of reflection and data sovereignty.

## User Stories
- **Amount First:** As a user, I want to enter the amount immediately upon opening the "Add" screen so I don't lose focus.
- **Contextual Details:** As a user, I want to categorize my expense with tags and set the date so my records are organized.
- **Visual Record:** As a user, I want the *option* to take a photo of my receipt to enhance the accountability of the entry.
- **Persistence:** As a user, I want my data saved locally and securely so I have a reliable history of my spending.

## Functional Requirements
- **Keypad Entry:** A custom numeric keypad for rapid currency input.
- **Tag Selection:** A searchable/selectable list of hierarchical tags.
- **Photo Capture:** Integration with the camera/photo library to attach one image per expense.
- **Data Model:**
    - `Expense`: Amount, Date, Note (Optional), Category/Tags, Photo (Optional).
    - `Tag`: Name, Color, Parent (Optional).

## Technical Constraints
- **Framework:** SwiftUI for all UI components.
- **Storage:** SwiftData for local persistence.
- **Theme:** Catppuccin Mocha (Dark) and Latte (Light) palettes as per `product-guidelines.md`.
- **Privacy:** All photos and data must be stored locally on the device.

## Acceptance Criteria
- User can successfully save an expense with just an amount.
- User can successfully save an expense with amount, multiple tags, and a photo.
- Data persists across app restarts.
- UI adheres to the "sleek, compact" guidelines.
