import AVFoundation
import SwiftUI

/// First-launch window: choose the camera Caffeguard will always use, and grant access to it.
struct SetupView: View {
    @AppStorage(Preference.cameraID) private var cameraID: String?
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var selection = Cameras.available.first?.uniqueID
    @State private var accessDenied = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint)

            VStack(spacing: 8) {
                Text("Welcome to Caffeguard")
                    .font(.title.bold())
                Text("When an app keeps your Mac awake and you step away, Caffeguard photographs anyone who sits down at it.")
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)

            GroupBox {
                CameraPicker(selection: $selection)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
            } label: {
                Text("Choose the camera to use")
            }

            if accessDenied {
                VStack(spacing: 4) {
                    Text("Caffeguard needs access to the camera.")
                    Link("Open Privacy & Security Settings",
                         destination: URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera")!)
                }
                .font(.callout)
            }

            Button("Continue", action: finish)
                .keyboardShortcut(.defaultAction)
                .controlSize(.large)
                .disabled(selection == nil)
        }
        .padding(32)
        .frame(width: 440)
        .onAppear { NSApp.activate() }
    }

    private func finish() {
        Task {
            guard await AVCaptureDevice.requestAccess(for: .video) else {
                accessDenied = true
                return
            }
            cameraID = selection
            dismissWindow()
        }
    }
}
