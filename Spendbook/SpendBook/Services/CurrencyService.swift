import Foundation
import SwiftUI

/// Service responsible for managing user currency preferences and formatting financial amounts.
@MainActor
@Observable
final class CurrencyService {
    static let shared = CurrencyService()
    
    /// The ISO 4217 currency code selected by the user (e.g., "USD", "EUR").
    var selectedCurrencyCode: String {
        get {
            UserDefaults.standard.string(forKey: "selectedCurrencyCode") ?? "USD"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedCurrencyCode")
        }
    }
    
    /// A list of commonly used ISO 4217 currency codes for quick selection.
    var commonCurrencies: [String] {
        ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "BRL", "INR"]
    }
    
    /// Formats a decimal amount into a localized currency string using the selected currency code.
    /// - Parameter amount: The numerical amount to format.
    /// - Returns: A string formatted for the current locale (e.g., "$1,234.56").
    func format(_ amount: Decimal) -> String {
        amount.formatted(.currency(code: selectedCurrencyCode))
    }
    
    /// The character used as a decimal separator in the current user locale (e.g., "." or ",").
    var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }
}
