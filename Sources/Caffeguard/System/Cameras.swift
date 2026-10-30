import AVFoundation

enum Cameras {
    static let privacySettings = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera")!

    /// Cameras Caffeguard may use: built-in and USB webcams. Never an iPhone (Continuity Camera).
    static var available: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )
        // A Continuity Camera iPhone reports itself as `.external`, so filter it explicitly.
        .devices.filter { !$0.isContinuityCamera }
    }
}
