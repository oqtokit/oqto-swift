import XCTest
@testable import Oqto

final class OqtoTests: XCTestCase {
    func testVersionIsSemver() {
        XCTAssertNotNil(Oqto.version.range(of: #"^\d+\.\d+\.\d+$"#, options: .regularExpression))
    }

    /// The backend reads snake_case keys; a renamed CodingKey would silently drop a field.
    func testDeviceRegistrationRequestUsesWireKeys() throws {
        let request = DeviceRegistrationRequest(
            anonymousID: "a1", token: "abcd", platform: "ios", appVersion: "1.2",
            osVersion: "18.0.0", timezone: "Europe/Belgrade", locale: "sr_RS"
        )
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(request)) as? [String: Any]
        )
        XCTAssertEqual(
            Set(object.keys),
            ["anonymous_id", "token", "platform", "app_version", "os_version", "timezone", "locale"]
        )
    }

    func testDecodesRegistrationAndErrorBodies() throws {
        let registration = try JSONDecoder().decode(
            DeviceRegistration.self,
            from: Data(#"{"device_id":"d1","end_user_id":"e1"}"#.utf8)
        )
        XCTAssertEqual(registration.deviceID, "d1")
        XCTAssertEqual(registration.endUserID, "e1")

        let error = try JSONDecoder().decode(
            APIErrorResponse.self,
            from: Data(#"{"error":{"code":"unauthorized","message":"invalid or revoked api key"}}"#.utf8)
        )
        XCTAssertEqual(error.error.code, "unauthorized")
    }
}
