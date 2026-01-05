# Track: Implement Privacy Shield (Biometrics)

## Context
Spendbook users value privacy. To protect sensitive financial data from unauthorized access on a shared or unlocked device, the app should provide an optional biometric lock.

## Goal
Implement a biometric authentication layer (FaceID/TouchID) that secures the app on launch and resume.

## Requirements

### 1. Biometric Authentication
- Use the `LocalAuthentication` framework.
- Request authentication whenever the app enters the foreground (Launch or Resume from Background).
- Provide a clear reason string: "Authorize to view your financial data."

### 2. Settings Toggle
- Add a "Privacy Shield" section in `SettingsView`.
- Provide a toggle to enable/disable the lock.
- Only show the toggle if the device supports biometrics.

### 3. Grace Period
- Allow a short grace period (e.g., 30 seconds) so that switching apps briefly doesn't trigger a re-lock.

## Technical Considerations
- Handle `NSFaceIDUsageDescription` in `Info.plist` (or prepared documentation).
- Manage the "Unlocked" state in a global `@Observable` object or Environment variable.
- Ensure the app shows a blurred or "Shielded" view when locked to prevent data leakage in the app switcher.
