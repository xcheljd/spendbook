import Foundation
import SwiftUI

enum PaymentMethodType: String, CaseIterable, Identifiable, Codable {
    case cash
    case creditCard
    case debitCard
    case applePay
    case paypal

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cash: return "Cash"
        case .creditCard: return "Credit Card"
        case .debitCard: return "Debit Card"
        case .applePay: return "Apple Pay"
        case .paypal: return "PayPal"
        }
    }

    var requiresLastDigits: Bool {
        switch self {
        case .cash, .applePay, .paypal: return false
        case .creditCard, .debitCard: return true
        }
    }

    var lastDigitsCount: Int? {
        switch self {
        case .cash, .applePay, .paypal: return nil
        case .creditCard: return 4
        case .debitCard: return 4
        }
    }

    var iconName: String {
        switch self {
        case .cash: return "banknote"
        case .creditCard: return "creditcard"
        case .debitCard: return "creditcard"
        case .applePay: return "applelogo"
        case .paypal: return "p.circle"
        }
    }

    var color: Color {
        switch self {
        case .cash: return Color.Catppuccin.green
        case .creditCard: return Color.Catppuccin.red
        case .debitCard: return Color.Catppuccin.blue
        case .applePay: return Color.Catppuccin.mauve
        case .paypal: return Color.Catppuccin.sapphire
        }
    }
}
