import SwiftUI

struct AmountKeypadView: View {
    @Binding var value: String
    @State private var feedbackTrigger = false
    var currencyService = CurrencyService.shared

    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    private var keys: [String] {
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", currencyService.decimalSeparator, "0", "<"]
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(keys, id: \.self) { key in
                Button(action: {
                    feedbackTrigger.toggle()
                    handleKeyPress(key)
                }) {
                    Text(key == "<" ? "⌫" : key)
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(Color.Catppuccin.text)
                        .frame(width: 80, height: 80)
                        .background(Color.Catppuccin.mantle)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.Catppuccin.overlay0.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(KeypadButtonStyle())
                .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: feedbackTrigger)
            }
        }
        .padding()
        .background(Color.Catppuccin.base)
    }
    
    private func handleKeyPress(_ key: String) {
        if key == "<" {
            deleteKey()
        } else {
            appendKey(key)
        }
    }
    
    private func appendKey(_ key: String) {
        let separator = currencyService.decimalSeparator
        
        if key == separator {
            if value.contains(".") || value.contains(",") { return }
            value += "." // We store internally with dot for Decimal conversion
            return
        }
        
        // Max 2 decimal places check (internal storage uses dot)
        if let dotIndex = value.firstIndex(of: ".") {
            let distance = value.distance(from: dotIndex, to: value.endIndex)
            if distance > 2 { return }
        }
        
        if value == "0" {
            value = key
        } else {
            value += key
        }
    }
    
    private func deleteKey() {
        if value.count <= 1 {
            value = "0"
        } else {
            value = String(value.dropLast())
        }
    }
}

struct KeypadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.Catppuccin.base.ignoresSafeArea()
        AmountKeypadView(value: .constant("12.50"))
    }
}
