# Spendbook Permissions Guide

This document explains all the permissions Spendbook requests, why they're needed, and how they're handled in the codebase.

## 📱 Required Permissions

### 1. Camera Access (NSCameraUsageDescription)
**Status**: ✅ Implemented

**Purpose**: Scan receipts using the device camera

**Implementation**:
- **File**: `ScannerView.swift`
- **Framework**: AVFoundation + VisionKit
- **Permission Check**: `AVCaptureDevice.authorizationStatus(for: .video)`
- **Request Method**: `AVCaptureDevice.requestAccess(for: .video)`

**Info.plist Entry**:
```xml
<key>NSCameraUsageDescription</key>
<string>Spendbook needs access to your camera to scan receipts and automatically extract expense information.</string>
```

**Code Implementation**:
```swift
static func checkCameraPermission() async -> CameraPermissionStatus {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
        return .authorized
    case .notDetermined:
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        return granted ? .authorized : .denied
    case .denied, .restricted:
        return .denied
    @unknown default:
        return .denied
    }
}
```

**User Experience**:
- Permission requested when user taps camera button in `AddEntryAmountScreen`
- Alert shown if permission denied with option to open Settings
- Graceful fallback to photo picker if camera unavailable

---

### 2. Photo Library Access (NSPhotoLibraryUsageDescription)
**Status**: ✅ Implemented

**Purpose**: Allow users to select receipt images from their photo library

**Implementation**:
- **File**: `AddEntryAmountScreen.swift`
- **Framework**: PhotosUI (SwiftUI)
- **Component**: `PhotosPicker`

**Info.plist Entry**:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Spendbook needs access to your photo library to scan receipts and automatically extract expense information.</string>
```

**Code Implementation**:
```swift
@State private var selectedItem: PhotosPickerItem?

PhotosPicker(selection: $selectedItem, matching: .images) {
    Image(systemName: "photo.on.rectangle")
        .font(.title2)
        .foregroundStyle(blueColor)
}

.onChange(of: selectedItem) { oldValue, newValue in
    Task {
        guard let newValue else { return }
        guard let data = try await newValue.loadTransferable(type: Data.self) else {
            showError("Could not load the selected photo.")
            return
        }
        guard let uiImage = UIImage(data: data) else {
            showError("Could not read the image.")
            return
        }
        processScannedImage(uiImage)
    }
}
```

**User Experience**:
- Permission requested automatically when user taps photo library button
- System handles permission UI
- Error handling for loading failures

---

### 3. Face ID / Biometric Authentication (NSFaceIDUsageDescription)
**Status**: ✅ Implemented

**Purpose**: Secure user's financial data with biometric authentication

**Implementation**:
- **Files**: `SecurityService.swift`, `SecurityManager.swift`
- **Framework**: LocalAuthentication
- **Component**: `LAContext`

**Info.plist Entry**:
```xml
<key>NSFaceIDUsageDescription</key>
<string>Spendbook uses Face ID to securely lock and unlock your financial data.</string>
```

**Code Implementation**:
```swift
func authenticate() async -> Bool {
    let context = LAContext()
    
    do {
        let success = try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Authorize to view your financial data."
        )
        return success
    } catch {
        print("Authentication failed: \(error.localizedDescription)")
        return false
    }
}
```

**User Experience**:
- Permission requested when user enables "Privacy Shield" in Settings
- App locks after 30 seconds in background
- Supports Face ID, Touch ID, or device passcode
- Optional feature - user can disable in Settings

---

### 4. Notifications (User Notifications)
**Status**: ✅ Implemented

**Purpose**: Send daily reminders and weekly budget reports

**Implementation**:
- **File**: `NotificationService.swift`
- **Framework**: UserNotifications
- **Component**: `UNUserNotificationCenter`

**Info.plist Entry**: ❌ Not required (requested programmatically)

**Code Implementation**:
```swift
func requestPermissions() {
    UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .badge, .sound]
    ) { success, error in
        DispatchQueue.main.async {
            if success {
                if self.isEnabled {
                    self.scheduleDaily(at: self.reminderTime)
                }
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
}
```

**User Experience**:
- Permission requested when user enables "Daily Reminder" in Settings
- System shows standard notification permission dialog
- Gracefully handles denial - toggles remain but notifications don't fire
- Test notification feature to preview reminder

---

## 🎯 Permission Request Timing

### Best Practices Followed:

1. **Contextual Timing**: Permissions requested when user attempts to use the feature
2. **Just-in-Time**: Camera/Photo requested at point of use, not at app launch
3. **Optional Features**: All permissions are for optional features; app works without them
4. **Clear Purpose**: Each permission has a clear, user-friendly explanation

### Permission Flow:

```
App Launch
    └─> (No permissions requested)

User taps "Scan Receipt"
    └─> Check Camera Permission
        ├─> Authorized → Show Camera
        ├─> Not Determined → Request → Show Camera or Alert
        └─> Denied → Show Alert with Settings Option

User taps "Photo Library"
    └─> PhotosPicker automatically handles permission
        └─> System shows picker or permission prompt

User enables "Privacy Shield"
    └─> Face ID used at next lock
        └─> Permission requested on first use

User enables "Daily Reminder"
    └─> Request Notification Permission
        └─> Schedule notifications if granted
```

---

## 🚨 Handling Permission Denial

### Camera Denial:
```swift
.alert("Camera Unavailable", isPresented: $showingPermissionAlert) {
    if ScannerView.isDocumentScannerAvailable {
        Button("Open Settings") {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }
    Button("Cancel", role: .cancel) {}
} message: {
    if ScannerView.isDocumentScannerAvailable {
        Text("Please enable camera access in Settings to scan receipts.")
    } else {
        Text("Document scanning requires a device with a camera. Use the photo picker instead.")
    }
}
```

**Features**:
- Helpful error messages
- Direct link to Settings
- Alternative methods suggested (photo picker)
- Device capability detection

### Photo Library Denial:
- PhotosPicker handles this automatically
- Users can grant permission through system picker UI

### Face ID Denial:
- App continues to work without biometric lock
- User can still use the app fully
- Privacy Shield setting can be toggled off

### Notification Denial:
- Reminders toggle remains but notifications don't fire
- App functions normally without notifications
- User can re-enable in system settings

---

## ✅ App Store Review Compliance

All permission strings follow Apple's guidelines:

1. **Clear and Concise**: Each explains what the permission does
2. **User Benefit**: Focuses on user benefit, not technical details
3. **Specific**: Mentions the specific feature requiring permission
4. **Professional**: Uses proper grammar and terminology

### Example Review Criteria Met:

- ✅ Permission descriptions are present for all used APIs
- ✅ Descriptions explain the purpose clearly
- ✅ App functions without granting permissions (degraded but usable)
- ✅ No misleading or deceptive permission requests
- ✅ Permissions requested at appropriate times

---

## 🔒 Privacy & Security

### Data Handling:

1. **Camera/Photos**:
   - Images processed locally using Vision framework
   - No data sent to servers
   - Images optionally attached to expenses (stored locally in SwiftData)
   - User controls data export

2. **Biometric Data**:
   - Never accessed directly by app
   - System handles all biometric processing
   - App only receives success/failure result

3. **Notifications**:
   - All scheduled locally on device
   - No remote notifications or push infrastructure
   - Content generated from local data

### SwiftData Storage:
```swift
let modelConfiguration = ModelConfiguration(
    schema: schema,
    url: url,
    cloudKitDatabase: .none  // Local storage only
)
```

---

## 📋 Testing Checklist

When testing permissions:

- [ ] Fresh app install - no permissions granted yet
- [ ] Camera permission: Deny → Verify alert → Open Settings
- [ ] Camera permission: Allow → Verify scanner works
- [ ] Photo library: Use PhotosPicker → Verify image loads
- [ ] Face ID: Enable Privacy Shield → Verify authentication
- [ ] Face ID: Deny → Verify app still works
- [ ] Notifications: Enable reminders → Verify permission prompt
- [ ] Notifications: Deny → Verify toggles work but no notifications
- [ ] App Store: Verify Info.plist has all required keys

---

## 🛠️ Troubleshooting

### "This app has crashed because it attempted to access privacy-sensitive data..."

**Cause**: Missing Info.plist permission key

**Solution**: Ensure all keys are present in Info.plist:
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription
- NSFaceIDUsageDescription

### Permission prompt not showing:

**Cause**: Permission already denied or restricted

**Solution**: 
1. Go to Settings → Privacy & Security
2. Find the relevant permission type
3. Find Spendbook and toggle permission

### Reset Permissions for Testing:

```bash
# Reset all permissions for your app
xcrun simctl privacy booted reset all com.yourcompany.spendbook

# Or use Settings app on device:
# Settings → General → Transfer or Reset → Reset Location & Privacy
```

---

## 📝 Summary

| Permission | Required | Requested When | Fallback |
|------------|----------|----------------|----------|
| Camera | No | Tap camera button | Photo picker |
| Photo Library | No | Tap photo button | Camera or manual entry |
| Face ID | No | Enable Privacy Shield | App works unlocked |
| Notifications | No | Enable reminders | App works without reminders |

**All permissions are optional and the app provides full functionality with degraded features if denied.**

## Step 4: Create Permission Best Practices Guide

<function_calls>
<invoke name="str_replace_based_edit_tool">
<parameter name="command">create
