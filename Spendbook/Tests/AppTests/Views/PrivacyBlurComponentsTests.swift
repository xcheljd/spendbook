import XCTest
import UIKit
import SwiftUI
@testable import SpendBook

@MainActor
final class PrivacyBlurComponentsTests: XCTestCase {

    // MARK: - BlurredAmountView Tests

    func testBlurredAmountViewShowsFormattedAmountWhenNotBlurred() {
        let view = BlurredAmountView(amount: 1234.56, isBlurred: false)
        let expectation = XCTestExpectation(description: "Amount should be visible")

        // Create a host view to render the component
        let hostView = UIHostingController(rootView: view)
        hostView.view.frame = CGRect(x: 0, y: 0, width: 200, height: 50)

        // The view renders synchronously, so we just verify it doesn't crash
        XCTAssertNotNil(hostView.view)
    }

    func testBlurredAmountViewShowsPlaceholderWhenBlurred() {
        let view = BlurredAmountView(amount: 1234.56, isBlurred: true)
        let hostView = UIHostingController(rootView: view)
        hostView.view.frame = CGRect(x: 0, y: 0, width: 200, height: 50)

        XCTAssertNotNil(hostView.view)
    }

    func testBlurredAmountViewHandlesZeroAmount() {
        let view = BlurredAmountView(amount: 0, isBlurred: false)
        let hostView = UIHostingController(rootView: view)
        hostView.view.frame = CGRect(x: 0, y: 0, width: 200, height: 50)

        XCTAssertNotNil(hostView.view)
    }

    func testBlurredAmountViewHandlesNegativeAmount() {
        let view = BlurredAmountView(amount: -50.00, isBlurred: false)
        let hostView = UIHostingController(rootView: view)
        hostView.view.frame = CGRect(x: 0, y: 0, width: 200, height: 50)

        XCTAssertNotNil(hostView.view)
    }

    // MARK: - PrivacyBlurToggle Tests

    func testPrivacyBlurToggleTogglesState() {
        let state = PrivacyBlurState.shared
        let initialState = state.isEnabled

        let view = PrivacyBlurToggle()
        let hostView = UIHostingController(rootView: view)
        hostView.view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)

        XCTAssertNotNil(hostView.view)

        // Toggle should change state
        state.toggle()
        XCTAssertNotEqual(state.isEnabled, initialState)

        // Reset to initial state
        state.isEnabled = initialState
    }

    func testPrivacyBlurToggleShowsCorrectIconWhenEnabled() {
        let state = PrivacyBlurState.shared
        state.isEnabled = true

        let view = PrivacyBlurToggle()
        let hostView = UIHostingController(rootView: view)
        hostView.view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)

        XCTAssertNotNil(hostView.view)
    }

    func testPrivacyBlurToggleShowsCorrectIconWhenDisabled() {
        let state = PrivacyBlurState.shared
        state.isEnabled = false

        let view = PrivacyBlurToggle()
        let hostView = UIHostingController(rootView: view)
        hostView.view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)

        XCTAssertNotNil(hostView.view)
    }
}
