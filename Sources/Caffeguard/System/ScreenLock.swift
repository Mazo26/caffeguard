import Foundation

enum ScreenLock {
    /// Locks the Mac exactly like the Lock Screen menu item.
    ///
    /// shortcut: `SACLockScreenImmediate` is a private macOS function. If Apple removes it, this
    /// falls back to sleeping the display, which only locks when the Mac asks for the password
    /// right after the display sleeps.
    static func lockNow() {
        if let login = dlopen("/System/Library/PrivateFrameworks/login.framework/Versions/Current/login", RTLD_LAZY),
           let symbol = dlsym(login, "SACLockScreenImmediate") {
            typealias LockScreenImmediate = @convention(c) () -> Int32
            _ = unsafeBitCast(symbol, to: LockScreenImmediate.self)()
        } else {
            Task { try? await Subprocess.run("/usr/bin/pmset", ["displaysleepnow"]) }
        }
    }
}
