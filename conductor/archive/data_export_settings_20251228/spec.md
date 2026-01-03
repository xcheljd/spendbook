# Track: Implement Data Export & Settings

## Context
Spendbook promises "Data Sovereignty" and "Local-First Architecture". Users need a way to manage their data, including exporting it for external analysis (CSV/JSON) and managing their privacy settings (e.g., clearing data). Currently, there is no centralized Settings area.

## Goal
Implement a `SettingsView` that provides data management tools and app configuration.

## Requirements

### 1. Settings Interface
- Create a new top-level view `SettingsView`.
- Access: Add a "Gear" icon to the `HomeFeedView` toolbar (leading position).

### 2. Data Export Feature
- **Formats:** CSV and JSON.
- **Content:** All `Expense` records, including tags and notes.
- **Action:** "Export Data" button that generates the file and presents a native Share Sheet.

### 3. Data Management
- **Clear Data:** A "Erase All Content" button (Red, with confirmation alert) to wipe the database.

### 4. About & Info
- Version number.
- Simple "About Spendbook" section.

## Technical Considerations
- Use `ShareLink` in SwiftUI for exporting files.
- Use `Codable` for JSON export.
- Manually construct CSV string with proper header row.
- Use `ModelContext` to fetch all data for export and to perform batch delete.
