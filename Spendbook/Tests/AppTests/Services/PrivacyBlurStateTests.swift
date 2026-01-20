import XCTest
@testable import SpendBook

@MainActor
final class PrivacyBlurStateTests: XCTestCase {

    override func setUpWithError() throws {
        // Reset singleton state before each test
        PrivacyBlurState.shared.resetForTesting()
    }

    override func tearDownWithError() throws {
        // Clean up after each test
        PrivacyBlurState.shared.resetForTesting()
    }

    // MARK: - isEnabled Tests

    func testIsEnabledCanBeToggled() {
        let state = PrivacyBlurState.shared
        state.isEnabled = false
        XCTAssertFalse(state.isEnabled)

        state.isEnabled = true
        XCTAssertTrue(state.isEnabled)

        state.isEnabled = false
        XCTAssertFalse(state.isEnabled)
    }

    // MARK: - defaultEnabled Tests

    func testDefaultEnabledCanBeSet() {
        let state = PrivacyBlurState.shared
        state.defaultEnabled = false
        XCTAssertFalse(state.defaultEnabled)

        state.defaultEnabled = true
        XCTAssertTrue(state.defaultEnabled)
    }

    // MARK: - detailAutoReveal Tests

    func testDetailAutoRevealCanBeSet() {
        let state = PrivacyBlurState.shared
        state.detailAutoReveal = true
        XCTAssertTrue(state.detailAutoReveal)

        state.detailAutoReveal = false
        XCTAssertFalse(state.detailAutoReveal)
    }

    // MARK: - autoEnableOnBackground Tests

    func testAutoEnableOnBackgroundCanBeSet() {
        let state = PrivacyBlurState.shared
        state.autoEnableOnBackground = false
        XCTAssertFalse(state.autoEnableOnBackground)

        state.autoEnableOnBackground = true
        XCTAssertTrue(state.autoEnableOnBackground)
    }

    // MARK: - Method Tests

    func testToggleSwitchesState() {
        let state = PrivacyBlurState.shared
        state.isEnabled = false
        state.toggle()
        XCTAssertTrue(state.isEnabled)

        state.toggle()
        XCTAssertFalse(state.isEnabled)
    }

    func testApplyDefaultStateSetsIsEnabledToDefaultEnabled() {
        let state = PrivacyBlurState.shared

        // When defaultEnabled is true, isEnabled should become true
        state.defaultEnabled = true
        state.isEnabled = false
        state.applyDefaultState()
        XCTAssertTrue(state.isEnabled)

        // When defaultEnabled is false, isEnabled should become false
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

    func testResetToDefaultsSetsExpectedValues() {
        let state = PrivacyBlurState.shared

        // Set non-default values
        state.isEnabled = true
        state.defaultEnabled = true
        state.detailAutoReveal = false
        state.autoEnableOnBackground = true

        // Reset
        state.resetToDefaults()

        // Verify reset values (isEnabled = defaultEnabled, detailAutoReveal = true, autoEnableOnBackground = false)
        XCTAssertEqual(state.isEnabled, state.defaultEnabled)
        XCTAssertTrue(state.detailAutoReveal)
        XCTAssertFalse(state.autoEnableOnBackground)
    }

    // MARK: - Persistence Tests

    func testValuesPersistedToUserDefaults() {
        let state = PrivacyBlurState.shared

        state.isEnabled = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "privacyBlurEnabled"))

        state.defaultEnabled = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "privacyBlurDefaultEnabled"))

        state.detailAutoReveal = false
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "privacyBlurDetailAutoReveal"))

        state.autoEnableOnBackground = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "privacyBlurAutoEnableOnBackground"))
    }
}
