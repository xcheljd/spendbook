import XCTest
import SwiftData
@testable import SpendBook

@MainActor
final class PaymentMethodTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: PaymentMethod.self, Expense.self, configurations: config)
        modelContext = modelContainer.mainContext
    }

    func testPaymentMethodInitialization() throws {
        let method = PaymentMethod(nickname: "My Card", methodType: .creditCard)
        modelContext.insert(method)

        XCTAssertNotNil(method.persistentModelID)
        XCTAssertEqual(method.nickname, "My Card")
        XCTAssertEqual(method.methodType, .creditCard)
        XCTAssertNil(method.lastDigits)
    }

    func testPaymentMethodWithLastDigits() throws {
        let method = PaymentMethod(nickname: "Visa", lastDigits: "1234", methodType: .debitCard)
        modelContext.insert(method)

        XCTAssertEqual(method.nickname, "Visa")
        XCTAssertEqual(method.lastDigits, "1234")
        XCTAssertEqual(method.methodType, .debitCard)
    }

    func testPaymentMethodCash() throws {
        let method = PaymentMethod(nickname: "Cash", methodType: .cash)
        modelContext.insert(method)

        XCTAssertEqual(method.methodType, .cash)
        XCTAssertNil(method.lastDigits)
    }

    func testPaymentMethodExpenseRelationship() throws {
        let method = PaymentMethod(nickname: "Amex", lastDigits: "12345", methodType: .creditCard)
        let expense = Expense(
            amount: 50.00,
            date: Date(),
            vendor: "Amazon",
            paymentMethod: method
        )

        modelContext.insert(method)
        modelContext.insert(expense)

        XCTAssertEqual(expense.paymentMethod?.nickname, "Amex")
        XCTAssertEqual(method.expenseCount, 1)
    }

    func testPaymentMethodDisplayName() throws {
        let card = PaymentMethod(nickname: "My Visa", lastDigits: "4321", methodType: .creditCard)
        modelContext.insert(card)

        XCTAssertEqual(card.displayName, "My Visa ••••4321")
    }

    func testPaymentMethodDisplayNameNoLastDigits() throws {
        let applePay = PaymentMethod(nickname: "Apple Pay", methodType: .applePay)
        modelContext.insert(applePay)

        XCTAssertEqual(applePay.displayName, "Apple Pay")
    }

    func testPaymentMethodTypeRequirements() throws {
        let creditCard = PaymentMethodType.creditCard
        let cash = PaymentMethodType.cash
        let applePay = PaymentMethodType.applePay

        XCTAssertTrue(creditCard.requiresLastDigits)
        XCTAssertEqual(creditCard.lastDigitsCount, 4)

        XCTAssertFalse(cash.requiresLastDigits)
        XCTAssertNil(cash.lastDigitsCount)

        XCTAssertFalse(applePay.requiresLastDigits)
        XCTAssertNil(applePay.lastDigitsCount)
    }
}
