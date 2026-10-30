import Testing
@testable import Caffeguard

struct KeepAwakeTests {
    @Test(arguments: [
        ("PreventUserIdleSystemSleep", "/usr/bin/caffeinate"),  // Terminal, Raycast, KeepingYouAwake
        ("PreventUserIdleSystemSleep", "/Applications/Amphetamine.app/Contents/MacOS/Amphetamine"),
        ("PreventUserIdleDisplaySleep", "/Applications/Lungo.app/Contents/MacOS/Lungo"),
        ("NoIdleSleepAssertion", "/Applications/Theine.app/Contents/MacOS/Theine"),
        ("PreventSystemSleep", "/Applications/Amphetamine.app/Contents/MacOS/Amphetamine"),
    ])
    func anAppPreventingIdleSleepKeepsTheMacAwake(type: String, path: String) {
        #expect(SystemActivity.keepsMacAwake(assertionType: type, processPath: path))
    }

    @Test(arguments: [
        // macOS holds this one whenever the display is on; it must not arm Caffeguard.
        ("PreventUserIdleSystemSleep", "/System/Library/CoreServices/powerd.bundle/powerd"),
        ("PreventUserIdleSystemSleep", "/usr/sbin/coreaudiod"),
        ("PreventUserIdleSystemSleep", "/usr/libexec/backupd"),
    ])
    func macOSItselfDoesNotCount(type: String, path: String) {
        #expect(!SystemActivity.keepsMacAwake(assertionType: type, processPath: path))
    }

    @Test(arguments: ["UserIsActive", "PreventDiskIdle", "InternalPreventDisplaySleep"])
    func otherKindsOfAssertionDoNotCount(type: String) {
        #expect(!SystemActivity.keepsMacAwake(assertionType: type, processPath: "/usr/bin/caffeinate"))
    }

    @Test func aProcessWhosePathIsUnknownDoesNotCount() {
        #expect(!SystemActivity.keepsMacAwake(assertionType: "PreventUserIdleSystemSleep", processPath: nil))
    }
}
