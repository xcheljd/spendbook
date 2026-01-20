import SwiftUI

/// A view that displays a monetary amount with optional blur effect.
/// When blur is enabled, shows "$••••" placeholder with blur filter.
struct BlurredAmountView: View {
    let amount: Decimal
    let isBlurred: Bool

    private let currencyService = CurrencyService.shared

    private var formattedAmount: String {
        currencyService.format(abs(amount))
    }

    private var currencySymbol: String {
        let formatted = currencyService.format(0)
        let cleaned = formatted.replacingOccurrences(of: "0", with: "").trimmingCharacters(in: .whitespaces)
        return cleaned.isEmpty ? "$" : cleaned
    }

    var body: some View {
        Group {
            if isBlurred {
                HStack(spacing: 2) {
                    Text(currencySymbol)
                    Text("••••")
                }
                .foregroundStyle(.secondary)
                .accessibilityLabel("Amount hidden")
                .accessibilityHidden(false)
            } else {
                Text(formattedAmount)
                    .foregroundStyle(.primary)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isBlurred)
    }
}

#Preview {
    VStack(spacing: 20) {
        BlurredAmountView(amount: 1234.56, isBlurred: false)
        BlurredAmountView(amount: 1234.56, isBlurred: true)
    }
    .padding()
    .background(Color.Catppuccin.base)
}
