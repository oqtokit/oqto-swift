import Foundation
import UIKit
import UserNotifications
import os

/// The entry point to the oqto SDK.
///
/// Call ``configure(apiKey:baseURL:)`` once at launch, forward the APNs device token with
/// ``registerDeviceToken(_:)``, and ask for permission with ``requestPermission()`` when it
/// makes sense to your user. Use a publishable key (`pk_…`); secret keys never belong in an app.
public final class Oqto {
    /// The SDK version. Matches the release tag of the Swift package.
    public static let version = "0.1.0"

    /// The shared instance, for ``onDeviceRegistered``.
    public static let shared = Oqto()

    private let log = Logger(subsystem: "me.oqto.sdk", category: "Oqto")
    private var client: APIClient?

    /// Called on the main thread after oqto stored the device. Pass
    /// ``DeviceRegistration/endUserID`` to your backend to send to this person from your server.
    public var onDeviceRegistered: ((DeviceRegistration) -> Void)?

    private init() {}

    /// Configures the SDK. Call once in `application(_:didFinishLaunchingWithOptions:)`.
    /// - Parameters:
    ///   - apiKey: the app's publishable key (`pk_live_…` or `pk_test_…`) from the oqto dashboard.
    ///   - baseURL: the oqto API origin, e.g. `https://api.example.com`.
    public static func configure(apiKey: String, baseURL: URL) {
        shared.client = APIClient(baseURL: baseURL, apiKey: apiKey)
        shared.log.info("configured for \(baseURL.absoluteString)")
    }

    /// Shows the system notification prompt and, if the person allows it, registers for remote
    /// notifications. The token then arrives in your app delegate; forward it with
    /// ``registerDeviceToken(_:)``.
    /// - Returns: whether notifications are allowed.
    @MainActor
    @discardableResult
    public static func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }
            shared.log.info("permission granted=\(granted)")
            return granted
        } catch {
            shared.log.error("permission request failed: \(error.localizedDescription)")
            return false
        }
    }

    /// Sends the APNs device token to oqto. Call it from
    /// `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`.
    public static func registerDeviceToken(_ token: Data) {
        let hex = token.map { String(format: "%02x", $0) }.joined()
        Task { await shared.register(tokenHex: hex) }
    }

    /// "major.minor.patch" from ProcessInfo, which (unlike UIDevice) is not
    /// main-actor isolated, so it can be read from this nonisolated async context.
    private static var osVersion: String {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
    }

    private func register(tokenHex: String) async {
        guard let client else {
            log.error("registerDeviceToken called before configure")
            return
        }

        let payload = DeviceRegistrationRequest(
            anonymousID: AnonymousID.current(),
            token: tokenHex,
            platform: "ios",
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            osVersion: Self.osVersion,
            timezone: TimeZone.current.identifier,
            locale: Locale.current.identifier
        )

        do {
            let registration: DeviceRegistration = try await client.post("/v1/devices", body: payload)
            log.info("device registered: \(registration.deviceID)")
            await MainActor.run { onDeviceRegistered?(registration) }
        } catch {
            log.error("registration failed: \(error.localizedDescription)")
        }
    }
}
