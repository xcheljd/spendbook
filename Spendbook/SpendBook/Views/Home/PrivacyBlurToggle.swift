import SwiftUI

/// Toggle button for enabling/disabling privacy blur in the list view.
struct PrivacyBlurToggle: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var privacyBlurState = PrivacyBlurState.shared

    private var theme: Theme { Theme(colorScheme) }

    var body: some View {
        Button(action: {
            privacyBlurState.toggle()
        }) {
            Image(systemName: privacyBlurState.isEnabled ? "eye.slash" : "eye")
                .font(.title3)
                .foregroundStyle(theme.blue)
                .frame(width: 44, height: 44)
                .background(privacyBlurState.isEnabled ? theme.overlay0.opacity(0.3) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 22))
        }
        .accessibilityLabel(privacyBlurState.isEnabled ? "Hide amounts" : "Show amounts")
        .accessibilityHint(privacyBlurState.isEnabled ? "Tap to reveal expense amounts" : "Tap to hide expense amounts")
    }
}

#Preview {
    PrivacyBlurToggle()
        .background(Color.Catppuccin.base)
}
