import CoreGraphics
import Foundation

/// The two facts that arm Caffeguard: the Mac is kept awake, and nobody is using it.
enum SystemActivity {
    /// True while a `caffeinate` process is running.
    static var isCaffeinated: Bool {
        let pgrep = Process()
        pgrep.executableURL = URL(filePath: "/usr/bin/pgrep")
        pgrep.arguments = ["-x", "caffeinate"]
        pgrep.standardOutput = FileHandle.nullDevice
        guard (try? pgrep.run()) != nil else { return false }
        pgrep.waitUntilExit()
        return pgrep.terminationStatus == 0
    }

    /// Seconds since the last keyboard, mouse or trackpad input.
    static var idleTime: TimeInterval {
        // An event type of ~0 means "any input".
        CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: CGEventType(rawValue: ~0)!)
    }
}
