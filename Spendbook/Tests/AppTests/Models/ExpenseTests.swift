import XCTest
import SwiftData
@testable import SpendBook

@MainActor
final class ExpenseTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Expense.self, Tag.self, PaymentMethod.self, configurations: config)
        modelContext = modelContainer.mainContext
    }

    func testExpenseInitialization() throws {
        let expense = Expense(
            amount: 12.50,
            date: Date(),
            vendor: "Test Vendor"
        )
        modelContext.insert(expense)

        XCTAssertNotNil(expense.persistentModelID)
        XCTAssertEqual(expense.amount, 12.50)
        XCTAssertEqual(expense.vendor, "Test Vendor")
    }

    func testExpenseTagRelationship() throws {
        let tag = Tag(name: "Food", colorHex: "#FF0000")
        let expense = Expense(
            amount: 20.00,
            date: Date(),
            vendor: "Restaurant"
        )

        modelContext.insert(tag)
        modelContext.insert(expense)

        expense.tags = [tag]

        XCTAssertEqual(expense.tags?.count, 1)
        XCTAssertEqual(expense.tags?.first?.name, "Food")
    }

    func testExpensePaymentMethodRelationship() throws {
        let method = PaymentMethod(nickname: "Visa", lastDigits: "1234", methodType: .creditCard)
        let expense = Expense(
            amount: 50.00,
            date: Date(),
            vendor: "Amazon",
            paymentMethod: method
        )

        modelContext.insert(method)
        modelContext.insert(expense)

        XCTAssertEqual(expense.paymentMethod?.nickname, "Visa")
        XCTAssertEqual(expense.paymentMethod?.lastDigits, "1234")
    }

    func testExpenseWithoutOptionalFields() throws {
        let expense = Expense(
            amount: 15.00,
            date: Date(),
            vendor: "Coffee Shop"
        )

        modelContext.insert(expense)

        XCTAssertNotNil(expense.persistentModelID)
        XCTAssertNil(expense.note)
        XCTAssertNil(expense.photoData)
        XCTAssertNil(expense.paymentMethod)
        XCTAssertEqual(expense.tags?.count, 0)
    }

}
