import AppKit
import SwiftUI

/// Covers every display in red, above the menu bar and full-screen apps, until dismissed.
final class IntrusionAlert {
    private var windows: [NSWindow] = []
    private var previousApp: NSRunningApplication?

    func show() {
        guard windows.isEmpty else { return }
        previousApp = NSWorkspace.shared.frontmostApplication
        windows = NSScreen.screens.map { screen in
            let window = AlertWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.isReleasedWhenClosed = false
            window.onCancel = { [weak self] in self?.dismiss() }
            window.contentView = NSHostingView(rootView: IntrusionAlertView { [weak self] in self?.dismiss() })
            window.setFrame(screen.frame, display: true)
            window.orderFrontRegardless()
            return window
        }
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

/// A borderless window that can take keyboard focus, so Esc reaches it.
private final class AlertWindow: NSWindow {
    var onCancel: () -> Void = {}
    override var canBecomeKey: Bool { true }
    override func cancelOperation(_ sender: Any?) { onCancel() }
}

private struct IntrusionAlertView: View {
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: 128))
            Text("Intrusion Detected")
                .font(.system(size: 64, weight: .bold))
            Text("This Mac is protected. A photo has been taken.")
                .font(.title)
            Text("Press Esc or click to dismiss.")
                .font(.title3)
                .opacity(0.7)
                .padding(.top, 24)
        }
        .foregroundStyle(.white)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.red)
        .contentShape(.rect)
        .onTapGesture(perform: dismiss)
    }
}
