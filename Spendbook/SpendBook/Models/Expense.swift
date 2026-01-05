import Foundation
import SwiftData

@Model
final class Expense {
    var amount: Decimal
    var date: Date
    var note: String?
    @Attribute(.externalStorage) var photoData: Data?
    
    @Relationship
    var tags: [Tag]?

    init(amount: Decimal, date: Date, note: String? = nil, photoData: Data? = nil, tags: [Tag] = []) {
        self.amount = amount
        self.date = date
        self.note = note
        self.photoData = photoData
        self.tags = tags
    }
}
