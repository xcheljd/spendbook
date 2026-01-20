import SwiftUI

/// Toggle button for enabling/disabling privacy blur in the list view.
struct PrivacyBlurToggle: View {
    @Environment(\.colorScheme) private var colorScheme

    private var privacyBlurState: PrivacyBlurState { PrivacyBlurState.shared }
    private var theme: Theme { Theme(colorScheme) }

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                privacyBlurState.toggle()
            }
        }) {
            Image(systemName: privacyBlurState.isEnabled ? "eye.slash.fill" : "eye")
                .foregroundStyle(theme.blue)
        }
        .animation(.easeInOut(duration: 0.2), value: privacyBlurState.isEnabled)
        .accessibilityLabel(privacyBlurState.isEnabled ? "Show amounts" : "Hide amounts")
        .accessibilityHint(privacyBlurState.isEnabled ? "Tap to reveal expense amounts" : "Tap to hide expense amounts")
    }
}

#Preview {
    PrivacyBlurToggle()
}
