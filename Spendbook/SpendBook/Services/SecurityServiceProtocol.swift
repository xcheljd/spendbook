import Foundation
import LocalAuthentication

@MainActor
protocol SecurityServiceProtocol {
    var hasBiometrics: Bool { get }
    var hasPasscode: Bool { get }
    var biometryType: LABiometryType { get }
    
    var authenticationMethod: AuthenticationMethod { get set }
    
    func canAuthenticate() -> Bool
    func authenticate() async -> Bool
}
