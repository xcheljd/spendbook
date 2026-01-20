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

    // MARK: - Properties

    /// Whether blur is currently enabled in the list view.
    var isEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.isEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.isEnabled)
        }
    }

    /// The default blur state when the app launches.
    /// - Note: This is applied on app launch if the user has never manually toggled.
    var defaultEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.defaultEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.defaultEnabled)
        }
    }

    /// Whether detail view should auto-reveal amounts or require manual toggle.
    var detailAutoReveal: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.detailAutoReveal)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.detailAutoReveal)
        }
    }

    /// Whether blur should automatically enable when the app enters the background.
    var autoEnableOnBackground: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.autoEnableOnBackground)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.autoEnableOnBackground)
        }
    }

    // MARK: - Initialization

    private init() {
        // Initialize isEnabled with default value on first launch
        if UserDefaults.standard.object(forKey: Keys.isEnabled) == nil {
            isEnabled = defaultEnabled
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
}
