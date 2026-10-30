import SwiftUI

struct MenuContent: View {
    @Environment(Sentry.self) private var sentry
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        @Bindable var sentry = sentry

        Text(sentry.status.title)
        Divider()
        Toggle("Enabled", isOn: $sentry.isEnabled)
        Button("Show Photos in Finder", action: Evidence.showInFinder)
        Divider()
        Button("Settings…") {
            // A menu bar app is never frontmost, so bring it forward or Settings opens behind.
            NSApp.activate()
            openSettings()
        }
        .keyboardShortcut(",")
        Button("Quit Caffeguard") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}
