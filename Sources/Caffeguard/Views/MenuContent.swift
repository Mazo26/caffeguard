import SwiftUI

struct MenuContent: View {
    @Environment(Sentry.self) private var sentry
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        @Bindable var sentry = sentry

        Text(sentry.status.title)
        if sentry.status == .cameraAccessNeeded {
            Button("Allow Camera Access…", action: sentry.requestCameraAccess)
        }
        Divider()

        if let photo = sentry.lastPhoto {
            Section("Last Intrusion") {
                Button {
                    NSWorkspace.shared.open(photo)
                } label: {
                    Label {
                        Text(Self.when(photo))
                    } icon: {
                        Image(nsImage: Self.thumbnail(photo))
                    }
                }
            }
            Divider()
        }

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

    private static func when(_ photo: URL) -> String {
        let date = (try? photo.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .now
        return date.formatted(.relative(presentation: .named)).capitalized(with: .current)
    }

    private static func thumbnail(_ photo: URL) -> NSImage {
        let image = NSImage(contentsOf: photo) ?? NSImage()
        // Menu items draw their image at its stated size; 16:9 at menu text height.
        image.size = NSSize(width: 32, height: 18)
        return image
    }
}
