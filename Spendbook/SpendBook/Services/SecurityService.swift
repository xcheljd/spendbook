import Foundation
import LocalAuthentication

@MainActor
class SecurityService: SecurityServiceProtocol {
    static let shared = SecurityService()

    private let context = LAContext()

    /// Current authentication method preference (from SecurityManager)
    var authenticationMethod: AuthenticationMethod {
        get {
            SecurityManager.shared.authenticationMethod
        }
        set {
            SecurityManager.shared.authenticationMethod = newValue
        }
    }

    /// Check if device has biometric capability
    var hasBiometrics: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    /// Check if device has passcode set up
    var hasPasscode: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    /// Get the appropriate biometry type
    var biometryType: LABiometryType {
        let _ = hasBiometrics // Update type
        return context.biometryType
    }

    func canAuthenticate() -> Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    /// Authenticate using the configured method
    /// Returns true if authentication succeeds, false otherwise
    func authenticate() async -> Bool {
        switch authenticationMethod {
        case .pinOnly:
            return await authenticateWithPasscode()

        case .faceIDOnly:
            return await authenticateWithBiometrics()

        case .faceIDWithPINFallback:
            let biometricSuccess = await authenticateWithBiometrics()
            if biometricSuccess {
                return true
            }
            return hasPasscode ? await authenticateWithPasscode() : false
        }
    }

    /// Authenticate using Face ID / Touch ID only
    private func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        print("🔒 Attempting biometric authentication...")
        print("🔒 Biometry type: \(context.biometryType.rawValue)")
        print("🔒 Can evaluate biometric policy: \(context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil))")

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authorize to view your financial data."
            )
            print("✅ Biometric authentication succeeded")
            return success
        } catch {
            print("❌ Biometric authentication failed: \(error)")
            print("❌ Error code: \(error._code)")
            return false
        }
    }

    /// Authenticate using device passcode
    private func authenticateWithPasscode() async -> Bool {
        let context = LAContext()
        print("🔐 Attempting device passcode authentication...")
        print("🔐 Can evaluate device policy: \(context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil))")

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Enter your device passcode to unlock."
            )
            print("✅ Passcode authentication succeeded")
            return success
        } catch {
            print("❌ Passcode authentication failed: \(error)")
            print("❌ Error code: \(error._code)")
            return false
        }
    }
}
