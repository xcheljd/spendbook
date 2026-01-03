import Foundation
import SwiftUI

@Observable
class CurrencyService {
    static let shared = CurrencyService()
    
    var selectedCurrencyCode: String {
        get {
            UserDefaults.standard.string(forKey: "selectedCurrencyCode") ?? "USD"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedCurrencyCode")
        }
    }
    
    /// Returns a list of common currency codes.
    var commonCurrencies: [String] {
        ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "BRL", "INR"]
    }
    
    /// Formats a decimal amount according to the selected currency and current locale.
    func format(_ amount: Decimal) -> String {
        amount.formatted(.currency(code: selectedCurrencyCode))
    }
    
    /// Returns the decimal separator for the current locale.
    var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }
}
