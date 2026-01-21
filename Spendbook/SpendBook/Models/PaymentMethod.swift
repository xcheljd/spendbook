import Foundation
import SwiftData

@Model
final class PaymentMethod: Identifiable {
    var id: PersistentIdentifier { persistentModelID }
    var nickname: String
    var lastDigits: String?
    var methodTypeRaw: String
    /// When true, this payment method is hidden from pickers but preserved for historical transactions.
    var isArchived: Bool = false

    @Relationship(inverse: \Expense.paymentMethod)
    var expenses: [Expense]?

    init(nickname: String, lastDigits: String? = nil, methodType: PaymentMethodType) {
        self.nickname = nickname
        self.lastDigits = lastDigits
        self.methodTypeRaw = methodType.rawValue
    }

    var methodType: PaymentMethodType {
        get {
            PaymentMethodType(rawValue: methodTypeRaw) ?? .cash
        }
        set {
            methodTypeRaw = newValue.rawValue
        }
    }

    var displayName: String {
        if let lastDigits = lastDigits, methodType.requiresLastDigits {
            return "\(nickname) ••••\(lastDigits)"
        }
        return nickname
    }

    var expenseCount: Int {
        expenses?.count ?? 0
    }

    var hasExpenses: Bool {
        expenseCount > 0
    }
}
