import SwiftUI

extension Color {
    struct Catppuccin {
        // Mocha (Dark) Palette
        static let base = Color(hex: "1E1E2E")
        static let mantlet = Color(hex: "181825")
        static let crust = Color(hex: "11111B")
        
        static let text = Color(hex: "CDD6F4")
        static let subtext0 = Color(hex: "A6ADC8")
        static let overlay0 = Color(hex: "6C7086")
        
        static let blue = Color(hex: "89B4FA")
        static let lavender = Color(hex: "B4BEFE")
        static let sapphire = Color(hex: "74C7EC")
        static let mauve = Color(hex: "CBA6F7")
        static let red = Color(hex: "F38BA8")
        static let peach = Color(hex: "FAB387")
        static let green = Color(hex: "A6E3A1")
        static let yellow = Color(hex: "F9E2AF")
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
