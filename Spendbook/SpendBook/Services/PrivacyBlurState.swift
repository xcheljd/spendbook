import Foundation
import SwiftUI

/// Service responsible for managing privacy blur state and user preferences.
@MainActor
@Observable
final class PrivacyBlurState {
    static let shared = PrivacyBlurState()

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let isEnabled = "privacyBlurEnabled"
        static let defaultEnabled = "privacyBlurDefaultEnabled"
        static let detailAutoReveal = "privacyBlurDetailAutoReveal"
        static let autoEnableOnBackground = "privacyBlurAutoEnableOnBackground"
    }

    // MARK: - Stored Properties (tracked by @Observable)

    /// Whether blur is currently enabled in the list view.
    var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: Keys.isEnabled) }
    }

    /// The default blur state when the app launches.
    var defaultEnabled: Bool {
        didSet { UserDefaults.standard.set(defaultEnabled, forKey: Keys.defaultEnabled) }
    }

    /// Whether detail view should auto-reveal amounts or require manual toggle.
    var detailAutoReveal: Bool {
        didSet { UserDefaults.standard.set(detailAutoReveal, forKey: Keys.detailAutoReveal) }
    }

    /// Whether blur should automatically enable when the app enters the background.
    var autoEnableOnBackground: Bool {
        didSet { UserDefaults.standard.set(autoEnableOnBackground, forKey: Keys.autoEnableOnBackground) }
    }

    // MARK: - Initialization

    private init() {
        // Register sensible defaults for first launch
        UserDefaults.standard.register(defaults: [
            Keys.isEnabled: false,
            Keys.defaultEnabled: false,
            Keys.detailAutoReveal: true,
            Keys.autoEnableOnBackground: false
        ])

        // Load persisted values into stored properties
        self.isEnabled = UserDefaults.standard.bool(forKey: Keys.isEnabled)
        self.defaultEnabled = UserDefaults.standard.bool(forKey: Keys.defaultEnabled)
        self.detailAutoReveal = UserDefaults.standard.bool(forKey: Keys.detailAutoReveal)
        self.autoEnableOnBackground = UserDefaults.standard.bool(forKey: Keys.autoEnableOnBackground)

        // Apply default on first launch
        if UserDefaults.standard.object(forKey: Keys.isEnabled) == nil {
            self.isEnabled = self.defaultEnabled
        }
    }

    // MARK: - Methods

    /// Resets all privacy settings to their default values.
    func resetToDefaults() {
        isEnabled = defaultEnabled
        detailAutoReveal = true
        autoEnableOnBackground = false
    }

    /// Toggles the current blur state.
    func toggle() {
        isEnabled.toggle()
    }

    /// Applies the default blur state (called on app launch).
    func applyDefaultState() {
        isEnabled = defaultEnabled
    }

    /// Enables blur when app enters background (called by scene delegate).
    func enableOnBackground() {
        if autoEnableOnBackground {
            isEnabled = true
        }
    }

    #if DEBUG
    /// Resets state to registered defaults. For testing only.
    func resetForTesting() {
        // Clear persisted values
        UserDefaults.standard.removeObject(forKey: Keys.isEnabled)
        UserDefaults.standard.removeObject(forKey: Keys.defaultEnabled)
        UserDefaults.standard.removeObject(forKey: Keys.detailAutoReveal)
        UserDefaults.standard.removeObject(forKey: Keys.autoEnableOnBackground)

        // Re-register defaults (in case they were cleared)
        UserDefaults.standard.register(defaults: [
            Keys.isEnabled: false,
            Keys.defaultEnabled: false,
            Keys.detailAutoReveal: true,
            Keys.autoEnableOnBackground: false
        ])

        // Reload stored properties from defaults
        isEnabled = false
        defaultEnabled = false
        detailAutoReveal = true
        autoEnableOnBackground = false
    }
    #endif
}
