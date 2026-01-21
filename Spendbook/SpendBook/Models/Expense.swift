import Foundation
import SwiftData

@Model
final class Expense: Identifiable {
    var id: PersistentIdentifier { persistentModelID }

    var amount: Decimal
    var date: Date
    /// Vendor/merchant name. Defaults to "Unknown" for migrated expenses created before vendor field was added.
    var vendor: String = "Unknown"
    var note: String?
    @Attribute(.externalStorage) var photoData: Data?

    @Relationship
    var tags: [Tag]?

    @Relationship
    var paymentMethod: PaymentMethod?

    init(amount: Decimal, date: Date, vendor: String, note: String? = nil, photoData: Data? = nil, tags: [Tag] = [], paymentMethod: PaymentMethod? = nil) {
        self.amount = amount
        self.date = date
        self.vendor = vendor
        self.note = note
        self.photoData = photoData
        self.tags = tags
        self.paymentMethod = paymentMethod
    }
}
