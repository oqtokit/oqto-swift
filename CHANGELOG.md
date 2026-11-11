# Changelog

All notable changes to the oqto Swift SDK. Versions follow [Semantic Versioning](https://semver.org).

## 0.1.0

First public release.

- `Oqto.configure(apiKey:baseURL:)` with a publishable key.
- `Oqto.requestPermission()` shows the notification prompt and registers for remote notifications.
- `Oqto.registerDeviceToken(_:)` registers the APNs token with oqto (random install ID kept in the Keychain).
- `Oqto.shared.onDeviceRegistered` reports the device and end user IDs.
