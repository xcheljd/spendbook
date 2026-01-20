import XCTest
@testable import SpendBook

@MainActor
final class PrivacyBlurStateTests: XCTestCase {

    override func setUpWithError() throws {
        // Reset UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "privacyBlurEnabled")
        UserDefaults.standard.removeObject(forKey: "privacyBlurDefaultEnabled")
        UserDefaults.standard.removeObject(forKey: "privacyBlurDetailAutoReveal")
        UserDefaults.standard.removeObject(forKey: "privacyBlurAutoEnableOnBackground")
    }

    override func tearDownWithError() throws {
        // Clean up after each test
        UserDefaults.standard.removeObject(forKey: "privacyBlurEnabled")
        UserDefaults.standard.removeObject(forKey: "privacyBlurDefaultEnabled")
        UserDefaults.standard.removeObject(forKey: "privacyBlurDetailAutoReveal")
        UserDefaults.standard.removeObject(forKey: "privacyBlurAutoEnableOnBackground")
    }

    // MARK: - isEnabled Tests

    func testIsEnabledDefaultIsFalseWhenDefaultEnabledIsFalse() {
        let state = PrivacyBlurState.shared
        XCTAssertFalse(state.isEnabled)
    }

    func testIsEnabledCanBeSet() {
        let state = PrivacyBlurState.shared
        state.isEnabled = true
        XCTAssertTrue(state.isEnabled)
        state.isEnabled = false
        XCTAssertFalse(state.isEnabled)
    }

    // MARK: - defaultEnabled Tests

    func testDefaultEnabledDefaultIsFalse() {
        let state = PrivacyBlurState.shared
        XCTAssertFalse(state.defaultEnabled)
    }

    func testDefaultEnabledCanBeSet() {
        let state = PrivacyBlurState.shared
        state.defaultEnabled = true
        XCTAssertTrue(state.defaultEnabled)
    }

    // MARK: - detailAutoReveal Tests

    func testDetailAutoRevealDefaultIsFalse() {
        let state = PrivacyBlurState.shared
        // UserDefaults.bool returns false when key is not set
        XCTAssertFalse(state.detailAutoReveal)
    }

    func testDetailAutoRevealCanBeSet() {
        let state = PrivacyBlurState.shared
        state.detailAutoReveal = false
        XCTAssertFalse(state.detailAutoReveal)
    }

    // MARK: - autoEnableOnBackground Tests

    func testAutoEnableOnBackgroundDefaultIsFalse() {
        let state = PrivacyBlurState.shared
        XCTAssertFalse(state.autoEnableOnBackground)
    }

    func testAutoEnableOnBackgroundCanBeSet() {
        let state = PrivacyBlurState.shared
        state.autoEnableOnBackground = true
        XCTAssertTrue(state.autoEnableOnBackground)
    }

    // MARK: - Method Tests

    func testToggleSwitchesState() {
        let state = PrivacyBlurState.shared
        let initialState = state.isEnabled
        state.toggle()
        XCTAssertEqual(state.isEnabled, !initialState)
    }

    func testApplyDefaultStateSetsIsEnabledToDefaultEnabled() {
        let state = PrivacyBlurState.shared
        state.defaultEnabled = true
        state.isEnabled = false
        state.applyDefaultState()
        XCTAssertTrue(state.isEnabled)

        state.defaultEnabled = false
        state.isEnabled = true
        state.applyDefaultState()
        XCTAssertFalse(state.isEnabled)
    }

    func testEnableOnBackgroundEnablesWhenSettingIsTrue() {
        let state = PrivacyBlurState.shared
        state.autoEnableOnBackground = true
        state.isEnabled = false
        state.enableOnBackground()
        XCTAssertTrue(state.isEnabled)
    }

    func testEnableOnBackgroundDoesNotEnableWhenSettingIsFalse() {
        let state = PrivacyBlurState.shared
        state.autoEnableOnBackground = false
        state.isEnabled = false
        state.enableOnBackground()
        XCTAssertFalse(state.isEnabled)
    }

    func testResetToDefaultsResetsAllSettings() {
        let state = PrivacyBlurState.shared
        state.isEnabled = true
        state.detailAutoReveal = false
        state.autoEnableOnBackground = true

        state.resetToDefaults()

        XCTAssertFalse(state.isEnabled)
        XCTAssertTrue(state.detailAutoReveal)
        XCTAssertFalse(state.autoEnableOnBackground)
    }

    // MARK: - Initialization Tests

    func testApplyDefaultStateUsesDefaultEnabledValue() {
        // Uses shared instance since init is private
        let state = PrivacyBlurState.shared

        // Set default to true
        state.defaultEnabled = true
        state.isEnabled = false

        // Apply default state (simulates app restart behavior)
        state.applyDefaultState()

        // isEnabled should be set to defaultEnabled value
        XCTAssertTrue(state.isEnabled)
    }
}
