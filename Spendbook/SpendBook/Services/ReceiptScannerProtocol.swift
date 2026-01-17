import Foundation
import UIKit

/// Protocol defining the interface for receipt scanning capabilities
@MainActor
protocol ReceiptScannerProtocol {
    /// Scans an image for receipt data
    /// - Parameter image: The image to process
    /// - Returns: A tuple containing the extracted amount and date, if found
    func scanReceipt(_ image: UIImage) async throws -> (amount: Decimal?, date: Date?)
    
    /// Extract amount from raw text (exposed for testing)
    func extractAmount(from text: String) -> Decimal?
    
    /// Extract date from raw text (exposed for testing)
    func extractDate(from text: String) -> Date?
}
