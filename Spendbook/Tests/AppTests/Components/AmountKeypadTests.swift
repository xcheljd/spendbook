import XCTest
import SwiftUI
@testable import Spendbook

final class AmountKeypadTests: XCTestCase {
    
    // Simulating the logic that will be in the View or a ViewModel
    func testKeypadInputAppend() {
        var currentAmount = "0"
        
        // Simulating tap "1"
        currentAmount = appendKey("1", to: currentAmount)
        XCTAssertEqual(currentAmount, "1")
        
        // Simulating tap "2"
        currentAmount = appendKey("2", to: currentAmount)
        XCTAssertEqual(currentAmount, "12")
    }
    
    func testDecimalInput() {
        var currentAmount = "12"
        
        // Simulating tap "."
        currentAmount = appendKey(".", to: currentAmount)
        XCTAssertEqual(currentAmount, "12.")
        
        // Simulating tap "." again (should be ignored)
        currentAmount = appendKey(".", to: currentAmount)
        XCTAssertEqual(currentAmount, "12.")
        
        // Simulating tap "5"
        currentAmount = appendKey("5", to: currentAmount)
        XCTAssertEqual(currentAmount, "12.5")
    }
    
    func testMaxDecimalPlaces() {
        var currentAmount = "1.99"
        
        // Try adding a 3rd decimal place (should be blocked for currency)
        currentAmount = appendKey("9", to: currentAmount)
        XCTAssertEqual(currentAmount, "1.99")
    }
    
    func testDeleteKey() {
        var currentAmount = "12.5"
        
        currentAmount = deleteKey(from: currentAmount)
        XCTAssertEqual(currentAmount, "12.")
        
        currentAmount = deleteKey(from: currentAmount)
        XCTAssertEqual(currentAmount, "12")
        
        currentAmount = deleteKey(from: currentAmount)
        XCTAssertEqual(currentAmount, "1")
        
        currentAmount = deleteKey(from: currentAmount)
        XCTAssertEqual(currentAmount, "0")
    }
    
    // Helper logic mirroring implementation
    private func appendKey(_ key: String, to current: String) -> String {
        if key == "." {
            if current.contains(".") { return current }
            return current + key
        }
        
        // Max 2 decimal places check
        if let dotIndex = current.firstIndex(of: ".") {
            let distance = current.distance(from: dotIndex, to: current.endIndex)
            if distance > 2 { return current }
        }
        
        if current == "0" {
            return key
        }
        
        return current + key
    }
    
    private func deleteKey(from current: String) -> String {
        if current.count <= 1 { return "0" }
        return String(current.dropLast())
    }
}
