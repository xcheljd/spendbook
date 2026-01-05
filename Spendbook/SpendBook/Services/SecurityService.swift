import Foundation
import LocalAuthentication

class SecurityService {
    static let shared = SecurityService()
    
    private let context = LAContext()
    
    func canAuthenticate() -> Bool {
        var error: NSError?
        let canEval = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return canEval
    }
    
    func authenticate() async -> Bool {
        let context = LAContext() // Use a new context for each attempt to avoid cached states
        
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
    
    var biometryType: LABiometryType {
        let _ = canAuthenticate() // Update type
        return context.biometryType
    }
}
