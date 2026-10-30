import AppKit
import LocalAuthentication
import SwiftUI

/// Covers every display with the chosen screen, above the menu bar and full-screen apps,
/// until the owner unlocks it with Touch ID or the Mac's password.
final class IntrusionAlert {
    var onUnlock: () -> Void = {}
    var isShowing: Bool { !windows.isEmpty }

    private var windows: [NSWindow] = []
    private var previousApp: NSRunningApplication?
    private var isAuthenticating = false

    func show() {
        guard windows.isEmpty else { return }
        let configuration = IntrusionScreenConfiguration(defaults: .standard)
        previousApp = NSWorkspace.shared.frontmostApplication
        windows = NSScreen.screens.map { screen in
            let window = IntrusionAlertWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.isReleasedWhenClosed = false
            window.unlockTrigger = configuration.unlockTrigger
            window.onUnlockRequest = { [weak self] in self?.unlock() }
            window.contentView = NSHostingView(rootView: IntrusionScreenView(configuration: configuration))
            window.setFrame(screen.frame, display: true)
            window.orderFrontRegardless()
            return window
        }
        bringToFront()
    }

    private func unlock() {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        // The system Touch ID / password prompt shares the screen saver level; drop just below it.
        windows.forEach { $0.level = NSWindow.Level(NSWindow.Level.screenSaver.rawValue - 1) }
        Task {
            // Touch ID when the Mac has it, otherwise (or after a failed finger) the login password.
            let unlocked = (try? await LAContext().evaluatePolicy(
                .deviceOwnerAuthentication, localizedReason: "dismiss the intrusion alert"
            )) ?? false
            isAuthenticating = false
            if unlocked {
                dismiss()
                onUnlock()
            } else {
                windows.forEach { $0.level = .screenSaver }
                bringToFront()
            }
        }
    }

    private func bringToFront() {
        NSApp.activate()
        windows.first?.makeKey()
    }

    private func dismiss() {
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
        // Otherwise macOS hands focus to Finder when our last window closes.
        previousApp?.activate()
        previousApp = nil
    }
}

/// Routes input before the hosting view can consume it. Input only requests authentication.
final class IntrusionAlertWindow: NSWindow {
    var unlockTrigger: IntrusionUnlockTrigger = .doubleClickOrAnyKey
    var onUnlockRequest: () -> Void = {}
    override var canBecomeKey: Bool { true }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown {
            if !event.isARepeat, unlockTrigger.accepts(.keyPress) { onUnlockRequest() }
            return
        }
        if event.type == .leftMouseDown, event.clickCount == 2 {
            if unlockTrigger.accepts(.doubleClick) { onUnlockRequest() }
            return
        }
        super.sendEvent(event)
    }
}
