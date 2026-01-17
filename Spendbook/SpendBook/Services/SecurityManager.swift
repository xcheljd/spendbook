import Foundation
import SwiftUI
import os.log

private let log = OSLog(subsystem: "com.spendbook.app", category: "Security")

/// Lock timeout options (in seconds)
enum LockTimeout: Int, CaseIterable, Identifiable {
    case immediate = 0
    case fifteenSeconds = 15
    case thirtySeconds = 30
    case oneMinute = 60
    case fiveMinutes = 300

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .immediate: return "Immediately"
        case .fifteenSeconds: return "15 seconds"
        case .thirtySeconds: return "30 seconds"
        case .oneMinute: return "1 minute"
        case .fiveMinutes: return "5 minutes"
        }
    }
}

/// Authentication method options
enum AuthenticationMethod: Int, CaseIterable, Identifiable {
    case faceIDOnly = 0
    case pinOnly = 1
    case faceIDWithPINFallback = 2

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .faceIDOnly: return "Face ID / Touch ID"
        case .pinOnly: return "Device Passcode"
        case .faceIDWithPINFallback: return "Face ID with Passcode Fallback"
        }
    }

    var description: String {
        switch self {
        case .faceIDOnly: return "Use Face ID or Touch ID to unlock"
        case .pinOnly: return "Use your device passcode to unlock"
        case .faceIDWithPINFallback: return "Use Face ID, with passcode fallback"
        }
    }

    var iconName: String {
        switch self {
        case .faceIDOnly: return "faceid"
        case .pinOnly: return "lock.fill"
        case .faceIDWithPINFallback: return "faceid"
        }
    }
}

@MainActor
@Observable
class SecurityManager {
    static let shared = SecurityManager()

    var isUnlocked: Bool = false

    // MARK: - Settings (Stored Properties for Observation)
    
    /// Master toggle for privacy features
    var isShieldEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isShieldEnabled, forKey: "isShieldEnabled")
            if !isShieldEnabled {
                isUnlocked = true
            }
        }
    }

    /// Time before locking in background
    var lockTimeout: LockTimeout {
        didSet {
            UserDefaults.standard.set(lockTimeout.rawValue, forKey: "lockTimeout")
        }
    }
    
    /// Preferred authentication method
    var authenticationMethod: AuthenticationMethod {
        didSet {
            UserDefaults.standard.set(authenticationMethod.rawValue, forKey: "authenticationMethod")
        }
    }

    private var lastBackgroundTime: Date?

    init() {
        // Load from UserDefaults
        self.isShieldEnabled = UserDefaults.standard.bool(forKey: "isShieldEnabled")
        
        let timeoutVal = UserDefaults.standard.integer(forKey: "lockTimeout")
        self.lockTimeout = LockTimeout(rawValue: timeoutVal) ?? .thirtySeconds
        
        let authMethodVal = UserDefaults.standard.integer(forKey: "authenticationMethod")
        // Auto-select appropriate default if not set or invalid
        if let method = AuthenticationMethod(rawValue: authMethodVal) {
            self.authenticationMethod = method
        } else {
            self.authenticationMethod = .faceIDOnly
        }
        
        // App starts locked if shield is enabled
        self.isUnlocked = !self.isShieldEnabled
    }

    func lock() {
        guard isShieldEnabled else {
            os_log("🔒 lock() called but shield disabled, ignoring", log: log, type: .info)
            return
        }
        os_log("🔒🔒🔒 SecurityManager.lock() called - setting isUnlocked to false 🔒🔒🔒", log: log, type: .info)
        os_log("🔒 Call stack: %{public}@", log: log, type: .info, Thread.callStackSymbols.prefix(5).joined(separator: "\n🔒 "))
        isUnlocked = false
        os_log("🔒 After lock: isUnlocked = %{public}d", log: log, type: .info, isUnlocked)
    }

    func unlock() {
        os_log("🔓 SecurityManager.unlock() called - setting isUnlocked to true", log: log, type: .info)
        isUnlocked = true
        os_log("🔓 After unlock: isUnlocked = %{public}d", log: log, type: .info, isUnlocked)
    }

    func handleAppResignActive() {
        os_log("📱 App going to background", log: log, type: .info)
        lastBackgroundTime = Date()
    }

    /// Check if the app should lock based on timeout
    func shouldLock() -> Bool {
        guard isShieldEnabled else { return false }
        
        if let lastBackgroundTime = lastBackgroundTime {
            let elapsed = Date().timeIntervalSince(lastBackgroundTime)
            return elapsed > Double(lockTimeout.rawValue)
        }
        
        // Cold start or no background time recorded
        return true
    }

    func handleAppBecomeActive() {
        os_log("⚡ handleAppBecomeActive() called", log: log, type: .info)
        guard isShieldEnabled else {
            os_log("⚡ Shield disabled, auto-unlocking", log: log, type: .info)
            isUnlocked = true
            return
        }

        if let lastBackgroundTime = lastBackgroundTime {
            let elapsed = Date().timeIntervalSince(lastBackgroundTime)
            os_log("⚡ Last background: %{public}@, elapsed: %{public}f seconds", log: log, type: .info, String(describing: lastBackgroundTime), elapsed)
            os_log("⚡ Lock timeout: %{public}d seconds", log: log, type: .info, lockTimeout.rawValue)
            if elapsed > Double(lockTimeout.rawValue) {
                os_log("⚡⚡⚡ Lock timeout exceeded (%{public}d)s, locking app ⚡⚡⚡", log: log, type: .info, lockTimeout.rawValue)
                os_log("⚡ Call stack: %{public}@", log: log, type: .info, Thread.callStackSymbols.prefix(5).joined(separator: "\n⚡ "))
                isUnlocked = false
            } else {
                os_log("⚡ Within lock timeout, keeping unlocked", log: log, type: .info)
            }
        } else {
            // Cold start
            os_log("⚡⚡⚡ Cold start (no lastBackgroundTime), locking app ⚡⚡⚡", log: log, type: .info)
            os_log("⚡ Call stack: %{public}@", log: log, type: .info, Thread.callStackSymbols.prefix(5).joined(separator: "\n⚡ "))
            isUnlocked = false
        }
        os_log("⚡ After handleAppBecomeActive: isUnlocked = %{public}d", log: log, type: .info, isUnlocked)
    }
}
