# Plan: Implement Privacy Shield (Biometrics)

## Phase 1: Authentication Logic
- [x] Create `SecurityService`
    - Implement `canAuthenticate()` check.
    - Implement `authenticate() async -> Bool` using `LAContext`.
- [x] Implement App Shield Logic
    - Create a `SecurityManager` (Observable) to track `isUnlocked` state and `lastForegroundTime`.

## Phase 2: UI Implementation
- [x] Create `AppLockView`
    - A simple, branded screen with a "Unlock with FaceID" button.
- [x] Update `SpendbookApp`
    - Wrap the root view in a conditional that shows `AppLockView` if biometrics are enabled and the app is locked.

## Phase 3: Settings Integration
- [x] Update `SettingsView`
    - Add "Security" section.
    - Add "Require Biometrics" toggle (Persisted via `AppStorage`).

## Phase 4: Verification
- [x] Manual Verification
    - Enable biometrics in Settings.
    - Kill and restart app.
    - Move app to background and resume (test grace period).
- [x] [checkpoint: f78dca8] Checkpoint Phase 4
