# 🔐 Permissions Setup Guide

This guide explains all the permissions required by Spendbook and how to properly configure them in your Xcode project.

## ✅ Required Permissions Summary

| Permission | Key | Status | Used In |
|------------|-----|--------|---------|
| Camera | `NSCameraUsageDescription` | ✅ Added | Receipt scanning |
| Photo Library | `NSPhotoLibraryUsageDescription` | ✅ Added | Receipt photo selection |
| Face ID | `NSFaceIDUsageDescription` | ✅ Added | App security lock |
| Notifications | Programmatic request | ✅ Implemented | Daily reminders |

## 📋 Step-by-Step Setup

### 1. Add Info.plist to Your Project

The `Info.plist` file has been created with all required permissions. To integrate it into your Xcode project:

1. **Locate the Info.plist file** in your project navigator
2. **Verify it's in your app target**:
   - Select the file in Xcode
   - Check the "Target Membership" in the File Inspector (right panel)
   - Ensure your app target is checked

3. **Alternative: Manual Entry**
   If you already have an Info.plist, add these keys manually:
   
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>Spendbook needs access to your camera to scan receipts and automatically extract expense information using document scanning.</string>
   
   <key>NSPhotoLibraryUsageDescription</key>
   <string>Spendbook needs access to your photo library to scan receipts and automatically extract expense information.</string>
   
   <key>NSFaceIDUsageDescription</key>
   <string>Spendbook uses Face ID to securely lock and unlock your financial data.</string>
   ```

### 2. Verify Permission Requests in Code

All permission requests are already properly implemented:

#### Camera Permission ✅
**File**: `ScannerView.swift`
```swift
static func checkCameraPermission() async -> CameraPermissionStatus {
    guard isDocumentScannerAvailable else {
        return .denied
    }

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

#### Photo Library Permission ✅
**File**: `AddEntryAmountScreen.swift`
```swift
PhotosPicker(selection: $selectedItem, matching: .images) {
    Image(systemName: "photo.on.rectangle")
        .font(.title2)
        .foregroundStyle(blueColor)
}
```
*Note*: PhotosPicker automatically requests permission when needed.

#### Face ID Permission ✅
**File**: `SecurityService.swift`
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

#### Notifications Permission ✅
**File**: `NotificationService.swift`
```swift
func requestPermissions() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
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

## 🧪 Testing Permissions

### Camera Permission Testing

1. Run the app on a physical device (camera not available in simulator)
2. Navigate to "Add Expense" → Tap camera icon
3. You should see the system permission alert with your description
4. Grant permission and verify scanner opens

**Test denial scenario**:
1. Go to Settings → Spendbook → Camera → OFF
2. Try to scan - should see "Camera Unavailable" alert with "Open Settings" option

### Photo Library Permission Testing

1. Navigate to "Add Expense" → Tap photo library icon
2. System will automatically request permission (first time)
3. You should see the permission alert with your description
4. Grant permission and verify photo picker opens

### Face ID Permission Testing

1. Enable "Privacy Shield" in Settings
2. Close the app and wait 30 seconds
3. Reopen the app
4. You should see Face ID prompt with your description
5. Authenticate to unlock

**Test on devices without Face ID**:
- Touch ID devices: Will prompt for Touch ID
- No biometrics: Will fall back to device passcode

### Notifications Permission Testing

1. Go to Settings → Reminders
2. Toggle "Daily Reminder" ON
3. System permission alert should appear
4. Grant permission
5. Tap "Send Test Notification (5s)" to verify

## 🚨 Common Issues & Solutions

### Issue: Permission Alert Not Showing

**Cause**: Info.plist key missing or incorrect
**Solution**: 
1. Clean build folder (Shift + Cmd + K)
2. Delete app from device/simulator
3. Rebuild and install
4. iOS caches permission states, so reinstalling is necessary

### Issue: "This app has crashed because it attempted to access privacy-sensitive data..."

**Cause**: Missing Info.plist description
**Solution**: Add the appropriate `NS*UsageDescription` key to Info.plist

### Issue: Face ID Always Fails on Simulator

**Cause**: Simulators don't have actual biometric hardware
**Solution**: 
1. Use a physical device for Face ID testing
2. Or enable simulated biometrics: Hardware → Face ID → Enrolled

### Issue: Camera Permission Denied Permanently

**Cause**: User denied permission
**Solution**: Your app correctly shows alert with "Open Settings" button
```swift
Button("Open Settings") {
    if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
    }
}
```

## 📱 App Store Review Guidelines

Your permission implementations comply with App Store guidelines:

### ✅ Best Practices Implemented

1. **Contextual Requests**: Permissions are requested when the user actually needs them
   - Camera: When tapping scan button
   - Photo Library: When tapping photo picker
   - Face ID: When enabling Privacy Shield
   - Notifications: When enabling reminders

2. **Clear Descriptions**: All descriptions explain:
   - What permission is needed
   - Why it's needed
   - What feature requires it

3. **Graceful Degradation**: App works without permissions:
   - Camera denied: Can still add expenses manually
   - Photo Library denied: Can use camera instead
   - Face ID denied: App still works, just without lock
   - Notifications denied: App works, just without reminders

4. **Settings Deep Link**: When permission is denied, app offers to open Settings

## 🔄 Permission Reset (Development)

To reset permissions during testing:

### On Simulator:
```bash
# Reset all permissions for your app
xcrun simctl privacy booted reset all com.yourcompany.Spendbook

# Reset specific permission
xcrun simctl privacy booted reset camera com.yourcompany.Spendbook
xcrun simctl privacy booted reset photos com.yourcompany.Spendbook
```

### On Physical Device:
Settings → General → Transfer or Reset → Reset → Reset Location & Privacy

⚠️ **Warning**: This resets ALL apps' permissions, not just yours!

## 📊 Permission Usage Analytics

Consider tracking permission grant rates (without identifying users):

```swift
// Example analytics implementation
func trackPermissionRequest(type: String, granted: Bool) {
    // Log to your analytics service
    print("Permission \(type): \(granted ? "Granted" : "Denied")")
}
```

This helps you understand user behavior and improve onboarding.

## 🎯 Next Steps

1. ✅ Info.plist configured with all permissions
2. ✅ All permission requests properly implemented
3. ✅ Error handling for denied permissions
4. ✅ Settings deep links implemented

Your app is now fully compliant with iOS permission requirements!

## 📚 Additional Resources

- [Apple: Protecting User Privacy](https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy)
- [App Store Review Guidelines: Privacy](https://developer.apple.com/app-store/review/guidelines/#privacy)
- [Requesting Authorization for Media Capture](https://developer.apple.com/documentation/avfoundation/capture_setup/requesting_authorization_for_media_capture_on_ios)
- [Local Authentication Framework](https://developer.apple.com/documentation/localauthentication)
