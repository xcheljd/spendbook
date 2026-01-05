# Technology Stack

## Core Platform
- **Language:** **Swift 6** (Leveraging modern concurrency and safety features).
- **Framework:** **SwiftUI** (Declarative UI for a native, high-performance experience).
- **Target OS:** iOS 18.0+ (To utilize the latest SwiftData and SwiftUI enhancements).

## Data & Storage
- **Primary Database:** **SwiftData** (Modern, schema-driven data persistence).
- **Cloud Synchronization:** **CloudKit** (Integrated with SwiftData for private, secure iCloud sync).
- **Local Security:** **Keychain Services** for any sensitive configuration or small secrets, and **LocalAuthentication** for biometric security.

## Media & Intelligence
- **Text Recognition:** **Vision Framework** (On-device OCR for receipt scanning).
- **Image Handling:** **PhotosUI** & **SwiftUI.Image** for photo selection and display.
- **Camera Access:** **AVFoundation** for capturing receipts within the app.

## UI & Architecture
- **Framework:** **Swift Charts** (For data visualization and spending insights).
- **Architecture:** **MVVM (Model-View-ViewModel)** or the newer **Observation** pattern in Swift 5.9+.
- **Theming:** Custom SwiftUI `EnvironmentValues` and `Color` extensions to implement the **Catppuccin Mocha/Latte** palettes.
- **Dependency Management:** **Swift Package Manager (SPM)** for minimal, trusted third-party libraries (if any).
