import SwiftUI

struct SafeToSpendCard: View {
    let amount: Decimal
    var currencyService = CurrencyService.shared
    var isBlurred: Bool = false

    @State private var shake = false

    private var isNegative: Bool { amount < 0 }

    private var cardColor: Color {
        isNegative ? Color.Catppuccin.red : Color.Catppuccin.blue
    }

    private var iconName: String {
        isNegative ? "exclamationmark.triangle.fill" : "checkmark.shield.fill"
    }

    private var title: String {
        isNegative ? "Over Budget Today" : "Safe to Spend Today"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.Catppuccin.base)

                BlurredAmountView(amount: abs(amount), isBlurred: isBlurred)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.Catppuccin.base)
                    .contentTransition(.numericText())
                    .animation(.spring, value: amount)
            }
            Spacer()
            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundStyle(Color.Catppuccin.base.opacity(0.5))
                .symbolEffect(.bounce, value: isNegative)
        }
        .padding()
        .background(cardColor)
        .cornerRadius(20)
        .shadow(color: cardColor.opacity(0.2), radius: 8, x: 0, y: 4)
        .modifier(ShakeEffect(shake: shake))
        .onChange(of: isNegative) { _, newValue in
            if newValue {
                withAnimation(.default) {
                    shake = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    shake = false
                }
            }
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var shake: Bool
    var animatableData: CGFloat {
        get { shake ? 1 : 0 }
        set { }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        guard shake else { return ProjectionTransform(.identity) }
        let offset = sin(animatableData * .pi * 4) * 6
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}
