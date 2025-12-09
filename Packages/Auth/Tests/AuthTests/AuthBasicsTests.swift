import XCTest
@testable import Auth
@testable import AuthImplementation

final class AuthBasicsTests: XCTestCase {
    func testBiometryAllowedPropertyReflectsAssociatedValue() {
        XCTAssertTrue(Auth.Business.Model.BiometryType.face(allowed: true).allowed)
        XCTAssertFalse(Auth.Business.Model.BiometryType.touch(allowed: false).allowed)
    }
}
