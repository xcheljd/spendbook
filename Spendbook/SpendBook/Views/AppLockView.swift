import SwiftUI
import LocalAuthentication

struct AppLockView: View {
    @State private var securityManager = SecurityManager.shared
    private let securityService = SecurityService.shared
    
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
                        Image(systemName: securityService.biometryType == .faceID ? "faceid" : "touchid")
                        Text("Authenticate")
                    }
                    .font(.headline)
                    .foregroundColor(Color.Catppuccin.base)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 32)
                    .background(Color.Catppuccin.blue)
                    .cornerRadius(16)
                    .shadow(color: Color.Catppuccin.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
            unlock()
        }
    }
    
    private func unlock() {
        Task {
            let success = await securityService.authenticate()
            if success {
                withAnimation(.spring()) {
                    securityManager.unlock()
                }
            }
        }
    }
}
