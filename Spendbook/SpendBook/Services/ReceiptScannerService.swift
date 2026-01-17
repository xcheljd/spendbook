import Foundation
import Vision
import UIKit
import Combine

enum ReceiptScanError: LocalizedError {
    case invalidImage
    case ocrFailed(Error)
    case noTextFound

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Could not process the image. Please try another photo."
        case .ocrFailed(let error):
            return "Failed to read text from receipt: \(error.localizedDescription)"
        case .noTextFound:
            return "No text found in the image. Please try a clearer photo."
        }
    }
}

@MainActor
final class ReceiptScannerService: ObservableObject, ReceiptScannerProtocol {
    @Published var isScanning = false

    private static let maxImageDimension: CGFloat = 2048

    func scanReceipt(_ image: UIImage) async throws -> (amount: Decimal?, date: Date?) {
        isScanning = true
        defer { isScanning = false }

        let resizedImage = Self.resizeImageIfNeeded(image)
        let recognizedText = try await Self.performOCR(on: resizedImage)
        let amount = extractAmount(from: recognizedText)
        let date = extractDate(from: recognizedText)

        return (amount, date)
    }

    private static func resizeImageIfNeeded(_ image: UIImage) -> UIImage {
        let size = image.size
        guard size.width > maxImageDimension || size.height > maxImageDimension else {
            return image
        }

        let scale = maxImageDimension / max(size.width, size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    private nonisolated static func performOCR(on image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw ReceiptScanError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            var hasResumed = false

            let request = VNRecognizeTextRequest { request, error in
                guard !hasResumed else { return }
                hasResumed = true

                if let error = error {
                    continuation.resume(throwing: ReceiptScanError.ocrFailed(error))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                    continuation.resume(returning: "")
                    return
                }

                let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                continuation.resume(returning: text)
            }

            request.recognitionLevel = .accurate

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                guard !hasResumed else { return }
                hasResumed = true
                continuation.resume(throwing: ReceiptScanError.ocrFailed(error))
            }
        }
    }
    
    // Parsing Logic
    func extractAmount(from text: String) -> Decimal? {
        let lines = text.components(separatedBy: .newlines)
        
        // Keywords that likely indicate the final total
        let primaryKeywords = ["total", "amount due", "balance due", "grand total", "net amount"]
        
        // 1. Try to find lines with primary keywords
        for keyword in primaryKeywords {
            // Find lines that contain the keyword but NOT 'sub' (to avoid subtotal)
            let matchingLines = lines.filter { line in
                line.localizedCaseInsensitiveContains(keyword) && 
                !line.localizedCaseInsensitiveContains("sub")
            }
            
            // For these lines, extract the largest price-looking number
            let amounts = matchingLines.compactMap { parseNumber(from: $0) }
            if let maxAmount = amounts.max() {
                return maxAmount
            }
        }
        
        // 2. If no keyword match, find the largest price-looking number in the entire text
        // (Often the total is the largest number on the receipt)
        let allAmounts = lines.compactMap { parseNumber(from: $0) }
        return allAmounts.max()
    }
    
    func extractDate(from text: String) -> Date? {
        // Strategy 1: Data Detector (Standard formats)
        let types: NSTextCheckingResult.CheckingType = [.date]
        if let detector = try? NSDataDetector(types: types.rawValue) {
            let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            
            // Prefer dates that aren't today (receipts are often from the past or today, 
            // but OCR sometimes misinterprets phone numbers as dates)
            if let date = matches.first?.date {
                return date
            }
        }
        
        return nil
    }
    
    private func parseNumber(from string: String) -> Decimal? {
        // Pattern for prices: $? [digits] [.,] [2 digits]
        // We also handle cases where OCR might miss the dot if it's faint, 
        // but typically it's there.
        let pattern = #"\d+[.,]\d{2}"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let nsString = string as NSString
        let matches = regex.matches(in: string, range: NSRange(location: 0, length: nsString.length))
        
        let candidates = matches.compactMap { match -> Decimal? in
            let matchString = nsString.substring(with: match.range)
            let cleaned = matchString.replacingOccurrences(of: ",", with: ".")
            return Decimal(string: cleaned)
        }
        
        return candidates.max()
    }
}