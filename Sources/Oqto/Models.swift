import Foundation

struct DeviceRegistrationRequest: Encodable {
    let anonymousID: String
    let token: String
    let platform: String
    let appVersion: String?
    let osVersion: String?
    let timezone: String?
    let locale: String?

    enum CodingKeys: String, CodingKey {
        case anonymousID = "anonymous_id"
        case token, platform
        case appVersion = "app_version"
        case osVersion = "os_version"
        case timezone, locale
    }
}

/// The result of a successful device registration.
public struct DeviceRegistration: Decodable {
    /// oqto's ID for this device.
    public let deviceID: String
    /// oqto's ID for the person using this install. `POST /v1/send` addresses notifications to it.
    public let endUserID: String

    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case endUserID = "end_user_id"
    }
}

struct APIErrorResponse: Decodable {
    struct Body: Decodable {
        let code: String
        let message: String
    }
    let error: Body
}

/// Errors the SDK logs when a call to oqto fails.
public enum OqtoError: Error, LocalizedError {
    case notConfigured
    case invalidResponse
    case server(status: Int, code: String?, message: String?)

    public var errorDescription: String? {
        switch self {
        case .notConfigured: return "Oqto.configure must be called before use"
        case .invalidResponse: return "Invalid response from server"
        case let .server(status, code, message):
            return "Server error \(status): \(code ?? "unknown") – \(message ?? "")"
        }
    }
}