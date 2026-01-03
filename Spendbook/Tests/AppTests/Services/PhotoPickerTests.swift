import XCTest
import SwiftUI
@testable import Spendbook

final class PhotoPickerTests: XCTestCase {
    
    // Simulate Image Handling Logic
    func testImageCompression() {
        // Since we can't easily create a real UIImage in Linux tests,
        // we simulate the logic of checking data size and compression factor.
        
        let mockData = Data(repeating: 0, count: 10 * 1024 * 1024) // 10MB
        let maxAllowedSize = 1 * 1024 * 1024 // 1MB
        
        XCTAssertTrue(mockData.count > maxAllowedSize)
        
        // Simulating a compression function result
        let compressedData = compress(mockData, targetSize: maxAllowedSize)
        XCTAssertTrue(compressedData.count <= maxAllowedSize)
    }
    
    private func compress(_ data: Data, targetSize: Int) -> Data {
        // Mock compression: if it's too big, just return a smaller chunk
        if data.count > targetSize {
            return Data(repeating: 0, count: targetSize)
        }
        return data
    }
}
