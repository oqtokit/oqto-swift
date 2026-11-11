# oqto for iOS

The Swift SDK for [oqto](https://github.com/oqtokit): push notifications and retention for iOS apps.
It registers your app's APNs device token with oqto, so you can send test pushes from the dashboard
and notifications from your server.

- iOS 16+, Swift 5.9+
- No third-party dependencies

## Install

In Xcode choose **File → Add Package Dependencies…**, paste

```
https://github.com/oqtokit/oqto-swift
```

choose **Up to Next Major Version** from `0.1.0`, and add the `Oqto` product to your app target.
Then add the **Push Notifications** capability (target → Signing & Capabilities).

## Use

```swift
import SwiftUI
import UserNotifications
import Oqto

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    var body: some Scene { WindowGroup { ContentView() } }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Oqto.configure(apiKey: "pk_test_YOUR_PUBLISHABLE_KEY", baseURL: URL(string: "https://YOUR_OQTO_API")!)

        // People who already allowed notifications get a fresh token on every launch, with no prompt.
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            if [.authorized, .provisional, .ephemeral].contains(settings.authorizationStatus) {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Oqto.registerDeviceToken(deviceToken)
    }
}
```

Ask for permission when the value is clear to the person, not on the first screen:

```swift
Button("Turn on notifications") {
    Task { await Oqto.requestPermission() }
}
```

Optionally, learn the end user ID oqto assigned, to send to this person from your server:

```swift
Oqto.shared.onDeviceRegistered = { registration in
    print(registration.deviceID, registration.endUserID)
}
```

The full guide, an AI integration prompt for Cursor or Claude Code, and the server API are in the
**Docs** section of the oqto dashboard. The exact API base URL and your publishable key are there too.

## Keys

Use a **publishable** key (`pk_…`) in the app: it can only register devices and record consent.
**Secret** keys (`sk_…`) send notifications and belong on your server, never in an app.

## Privacy

The SDK sends the APNs device token, a random install ID (stored in the Keychain), the app and OS
version, the time zone and the locale. It collects nothing else today, and it never reads IDFA.

## License

MIT. See [LICENSE](LICENSE).
