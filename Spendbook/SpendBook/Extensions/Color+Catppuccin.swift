import SwiftUI

extension Color {
    struct Catppuccin {
        // MARK: - Mocha (Dark) Palette
        struct Mocha {
            static let base = Color(hex: "1E1E2E")
            static let mantle = Color(hex: "181825")
            static let crust = Color(hex: "11111B")

            static let text = Color(hex: "CDD6F4")
            static let subtext0 = Color(hex: "A6ADC8")
            static let overlay0 = Color(hex: "6C7086")
            static let overlay1 = Color(hex: "7F849C")

            static let blue = Color(hex: "89B4FA")
            static let lavender = Color(hex: "B4BEFE")
            static let sapphire = Color(hex: "74C7EC")
            static let mauve = Color(hex: "CBA6F7")
            static let red = Color(hex: "F38BA8")
            static let peach = Color(hex: "FAB387")
            static let green = Color(hex: "A6E3A1")
            static let yellow = Color(hex: "F9E2AF")
        }

        // MARK: - Latte (Light) Palette
        struct Latte {
            static let base = Color(hex: "EFF1F5")
            static let mantle = Color(hex: "E6E9EF")
            static let crust = Color(hex: "DCE0E8")

            static let text = Color(hex: "4C4F69")
            static let subtext0 = Color(hex: "6C6F85")
            static let overlay0 = Color(hex: "9CA0B0")
            static let overlay1 = Color(hex: "8C8FA1")

            static let blue = Color(hex: "1E66F5")
            static let lavender = Color(hex: "7287FD")
            static let sapphire = Color(hex: "209FB5")
            static let mauve = Color(hex: "8839EF")
            static let red = Color(hex: "D20F39")
            static let peach = Color(hex: "FE640B")
            static let green = Color(hex: "40A02B")
            static let yellow = Color(hex: "DF8E1D")
        }

        // MARK: - Legacy Static References (Dark Mode Default)
        // Kept for backward compatibility - prefer using Theme for adaptive colors
        static let base = Mocha.base
        static let mantle = Mocha.mantle
        static let crust = Mocha.crust

        static let text = Mocha.text
        static let subtext0 = Mocha.subtext0
        static let overlay0 = Mocha.overlay0
        static let overlay1 = Mocha.overlay1

        static let blue = Mocha.blue
        static let lavender = Mocha.lavender
        static let sapphire = Mocha.sapphire
        static let mauve = Mocha.mauve
        static let red = Mocha.red
        static let peach = Mocha.peach
        static let green = Mocha.green
        static let yellow = Mocha.yellow
    }
}

// MARK: - Adaptive Theme
/// Use this for views that should adapt to light/dark mode
struct Theme {
    let colorScheme: ColorScheme

    init(_ colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }

    private var isDark: Bool { colorScheme == .dark }

    // MARK: - Base Colors
    var base: Color { isDark ? Color.Catppuccin.Mocha.base : Color.Catppuccin.Latte.base }
    var mantle: Color { isDark ? Color.Catppuccin.Mocha.mantle : Color.Catppuccin.Latte.mantle }
    var crust: Color { isDark ? Color.Catppuccin.Mocha.crust : Color.Catppuccin.Latte.crust }

    // MARK: - Text Colors
    var text: Color { isDark ? Color.Catppuccin.Mocha.text : Color.Catppuccin.Latte.text }
    var subtext0: Color { isDark ? Color.Catppuccin.Mocha.subtext0 : Color.Catppuccin.Latte.subtext0 }
    var overlay0: Color { isDark ? Color.Catppuccin.Mocha.overlay0 : Color.Catppuccin.Latte.overlay0 }
    var overlay1: Color { isDark ? Color.Catppuccin.Mocha.overlay1 : Color.Catppuccin.Latte.overlay1 }

    // MARK: - Accent Colors
    var blue: Color { isDark ? Color.Catppuccin.Mocha.blue : Color.Catppuccin.Latte.blue }
    var lavender: Color { isDark ? Color.Catppuccin.Mocha.lavender : Color.Catppuccin.Latte.lavender }
    var sapphire: Color { isDark ? Color.Catppuccin.Mocha.sapphire : Color.Catppuccin.Latte.sapphire }
    var mauve: Color { isDark ? Color.Catppuccin.Mocha.mauve : Color.Catppuccin.Latte.mauve }
    var red: Color { isDark ? Color.Catppuccin.Mocha.red : Color.Catppuccin.Latte.red }
    var peach: Color { isDark ? Color.Catppuccin.Mocha.peach : Color.Catppuccin.Latte.peach }
    var green: Color { isDark ? Color.Catppuccin.Mocha.green : Color.Catppuccin.Latte.green }
    var yellow: Color { isDark ? Color.Catppuccin.Mocha.yellow : Color.Catppuccin.Latte.yellow }
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
