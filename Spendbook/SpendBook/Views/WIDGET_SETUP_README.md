# SpendBook Widget Setup Guide

This guide will help you integrate the SpendBook widgets into your Xcode project.

## Overview

The implementation includes two widgets:
1. **SpendBook Widget** - Shows spending summaries (Small, Medium, Large)
2. **Quick Add Widget** - Quick button to add expenses (Small only)

## Setup Instructions

### 1. Create Widget Extension Target

1. In Xcode, go to **File > New > Target**
2. Select **Widget Extension**
3. Configure the extension:
   - Product Name: `SpendBookWidgetExtension`
   - Bundle Identifier: `{your-bundle-id}.SpendBookWidgetExtension`
   - Include Configuration Intent: **No** (we're using App Intents)
   - Uncheck "Include Live Activity"
4. Click **Finish**
5. When prompted, click **Activate** to activate the scheme

### 2. Add Widget Files

1. Add the following files to your Widget Extension target:
   - `SpendBookWidget.swift`
   - `QuickAddWidget.swift`

2. **Important:** Also add these existing files to the Widget Extension target:
   - `Expense.swift`
   - `Tag.swift`
   - `BudgetGoal.swift`
   - `CurrencyService.swift`
   - `Color+Catppuccin.swift` (your Catppuccin color extensions)

   To do this:
   - Select each file in the Project Navigator
   - In the File Inspector (right panel), check the box next to your Widget Extension target

### 3. Configure App Groups (Required for Data Sharing)

Widgets run in a separate process and need shared access to your data.

#### Option A: Continue with File-based Storage (Simpler)
The current implementation uses `URL.documentsDirectory`, which works but the data is in the app's container. For widgets to access it, you'll need to use App Groups:

1. In your main app target's Signing & Capabilities:
   - Click **+ Capability**
   - Add **App Groups**
   - Create a group: `group.{your-bundle-id}.spendbook`

2. Do the same for the Widget Extension target

3. Update the storage location in both `SpendbookApp.swift` and `SpendBookWidget.swift`:

```swift
// Replace this:
let url = URL.documentsDirectory.appendingPathComponent("Spendbook.sqlite")

// With this:
let url = FileManager.default
    .containerURL(forSecurityApplicationGroupIdentifier: "group.{your-bundle-id}.spendbook")!
    .appendingPathComponent("Spendbook.sqlite")
```

### 4. Update Info.plist

Replace the auto-generated Info.plist for the widget extension with the provided `WidgetExtension-Info.plist` file.

### 5. Update Build Settings (if needed)

1. Ensure the Widget Extension target has:
   - iOS Deployment Target: iOS 17.0 or later (for App Intents)
   - Swift Language Version: Swift 5.9 or later

### 6. Build and Run

1. Select your main app scheme
2. Build and run on a device or simulator
3. Long-press on the home screen
4. Tap the **+** button in the top-left
5. Search for "SpendBook"
6. Add the widgets!

## Widget Features

### SpendBook Widget

**Small Widget:**
- Shows today's spending total
- Displays current date

**Medium Widget:**
- Today's spending
- Monthly spending
- Budget progress bar (if budget is set)

**Large Widget:**
- Detailed view with today's spending
- Monthly spending with budget breakdown
- Remaining budget calculation
- Visual progress indicators

**Configuration:**
- Users can toggle budget display on/off in widget settings

### Quick Add Widget

- Small widget with a quick-add button
- Taps open the app to the add expense screen
- Uses deep linking (`spendbook://add`)

## Deep Linking

The widgets use the following URL schemes:
- `spendbook://home` - Opens app to home feed
- `spendbook://add` - Opens app to add expense screen

These are already implemented in your `SpendbookApp.swift` file!

## Timeline Updates

- **SpendBook Widget**: Updates at midnight each day to refresh daily totals
- **Quick Add Widget**: Static widget, updates daily
- Both widgets also update when the app is opened or when expenses are added

## Troubleshooting

### Widget not updating with new data
- Ensure App Groups are configured correctly
- Verify both targets use the same App Group identifier
- Check that the database path is correct in both app and widget

### Widget shows $0.00
- Make sure you've added expenses in the app first
- Verify the database is accessible from the widget extension
- Check that Expense, Tag, and BudgetGoal models are added to the widget target

### Build errors
- Ensure all required files are added to the widget extension target
- Check that Swift Data models are properly shared
- Verify deployment target is iOS 17.0+

### Widget preview not working
- Widget previews require the actual model container
- Use the preview timeline with sample data provided in the code

## Customization

### Colors
The widgets use your existing Catppuccin color scheme. Make sure `Color+Catppuccin.swift` is included in the widget target.

### Currency
Widgets automatically use the currency setting from `CurrencyService.shared`.

### Layout
You can customize the widget layouts by modifying:
- `SpendBookWidgetSmallView`
- `SpendBookWidgetMediumView`
- `SpendBookWidgetLargeView`

## Future Enhancements

Potential additions:
- Streak counter widget
- Category breakdown widget
- Weekly spending chart widget
- Interactive buttons (iOS 17+)
- Live Activities for expense tracking

## Support

If you encounter issues:
1. Check the Xcode console for error messages
2. Verify all files are added to the correct targets
3. Ensure App Groups are configured
4. Try cleaning the build folder (Cmd+Shift+K)
5. Delete the app and widget, then reinstall
