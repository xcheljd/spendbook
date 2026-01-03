# Plan: Implement Data Export & Settings

## Phase 1: Data Export Logic
- [x] Create `DataExportService`
    - Implement `generateCSV() -> String`: Fetches all expenses and formats them as CSV.
    - Implement `generateJSON() -> Data`: Fetches all expenses and encodes them to JSON.
    - Define a tailored `ExportableExpense` struct (Codable) to ensure clean JSON output (handling Dates, Tag names instead of objects).

## Phase 2: Settings UI Construction
- [x] Create `SettingsView`
    - Form-based layout.
    - Section: "Data Sovereignty"
        - Row: "Export as CSV" (ShareLink)
        - Row: "Export as JSON" (ShareLink)
    - Section: "Danger Zone"
        - Button: "Erase All Data" (with Alert).
    - Section: "About"
        - App Version.
- [x] Implement "Erase All Data" Logic
    - Function to delete all `Expense`, `Tag`, and `BudgetGoal` objects from `modelContext`.

## Phase 3: Integration
- [x] Update `HomeFeedView`
    - Add toolbar button (Gear icon) to the leading edge.
    - Present `SettingsView` as a sheet or navigation push.

## Phase 4: Verification
- [x] Logic Tests
    - Verify CSV generation format (headers, data mapping).
    - Verify JSON encoding.
- [x] Manual Verification
    - Export CSV and open in a text editor/spreadsheet.
    - Export JSON and verify structure.
    - Use "Erase All Data" and verify `HomeFeedView` is empty.
- [x] [checkpoint: c89b8c7] Checkpoint Phase 4
