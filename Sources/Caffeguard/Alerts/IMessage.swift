import Foundation

/// Sends a text, and optionally a photo, through this Mac's Messages app.
nonisolated enum IMessage {
    // The handle, text and photo path arrive as arguments, never spliced into the script.
    private static let script = """
        on run argv
            tell application "Messages"
                set target to participant (item 1 of argv) of (1st account whose service type = iMessage)
                send (item 2 of argv) to target
                if (count of argv) > 2 then send (POSIX file (item 3 of argv)) to target
            end tell
        end run
        """

    static func send(_ text: String, photo: URL?, to handle: String) async throws {
        do {
            try await Subprocess.run("/usr/bin/osascript", ["-e", script, handle, text] + (photo.map { [$0.path] } ?? []))
        } catch let failure as Subprocess.Failed {
            let message = failure.errorDescription ?? ""
            throw Subprocess.Failed(errorDescription: message.contains("-1743")
                ? "Allow Caffeguard to control Messages in System Settings → Privacy & Security → Automation."
                : message)
        }
    }
}
