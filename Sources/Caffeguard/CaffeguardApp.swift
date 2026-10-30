import SwiftUI

@main
struct CaffeguardApp: App {
    @State private var sentry = Sentry()

    var body: some Scene {
        MenuBarExtra("Caffeguard", systemImage: sentry.status.symbol) {
            MenuContent()
                .environment(sentry)
        }

        Window("Welcome to Caffeguard", id: "setup") {
            SetupView()
        }
        .windowResizability(.contentSize)
        .restorationBehavior(.disabled)
        .defaultLaunchBehavior(
            UserDefaults.standard.string(forKey: Preference.cameraID) == nil ? .presented : .suppressed
        )

        Settings {
            SettingsView()
        }
    }
}
