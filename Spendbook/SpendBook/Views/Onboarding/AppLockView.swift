import SwiftUI
import LocalAuthentication

struct AppLockView: View {
    private let securityManager = SecurityManager.shared
    private let securityService = SecurityService.shared
    @State private var isAuthenticating = false
    @State private var authError: String?
    @Binding var hasAuthenticatedSinceLastActive: Bool

    var body: some View {
        ZStack {
            Color.Catppuccin.base.ignoresSafeArea()

            VStack(spacing: 30) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color.Catppuccin.blue)

                VStack(spacing: 12) {
                    Text("Spendbook Locked")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color.Catppuccin.text)

                    Text("Unlock to access your financial data")
                        .font(.subheadline)
                        .foregroundColor(Color.Catppuccin.subtext0)
                }

                Button(action: unlock) {
                    HStack {
                        Image(systemName: authenticationIcon)
                        Text(isAuthenticating ? "Authenticating..." : buttonText)
                    }
                    .font(.headline)
                    .foregroundColor(Color.Catppuccin.base)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 32)
                    .background(isAuthenticating ? Color.Catppuccin.subtext0 : Color.Catppuccin.blue)
                    .cornerRadius(16)
                    .shadow(color: Color.Catppuccin.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    .disabled(isAuthenticating)
                }
                .padding(.top, 20)

                if let error = authError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(Color.Catppuccin.red)
                        .padding(.top, 8)
                }
            }
        }
        .onAppear {
            unlock()
        }
    }

    private var authenticationMethod: AuthenticationMethod {
        securityService.authenticationMethod
    }

    private var authenticationIcon: String {
        authenticationMethod.iconName
    }

    private var buttonText: String {
        switch authenticationMethod {
        case .faceIDOnly:
            return "Unlock with \(biometricName)"
        case .pinOnly:
            return "Enter Passcode"
        case .faceIDWithPINFallback:
            return "Unlock with \(biometricName) or Passcode"
        }
    }

    private var biometricName: String {
        switch securityService.biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biometrics"
        }
    }

    private func unlock() {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        authError = nil

        Task {
            let success = await securityService.authenticate()

            await MainActor.run {
                isAuthenticating = false

                if success {
                    hasAuthenticatedSinceLastActive = true
                    withAnimation(.spring()) {
                        securityManager.unlock()
                    }
                } else {
                    authError = "Authentication failed. Please try again."
                }
            }
        }
    }
}
