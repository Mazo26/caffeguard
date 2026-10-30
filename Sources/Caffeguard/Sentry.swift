import AVFoundation
import Observation
import os

/// Arms when something keeps the Mac awake and it is idle, watches the chosen camera, and raises the
/// alert when someone faces it. It keeps watching behind the alert, so everyone who sits
/// down is photographed, until the owner unlocks the alert.
@Observable
final class Sentry {
    enum Status {
        case setupNeeded, paused, waitingForKeepAwake, waitingForIdle, cameraUnavailable, watching, intruded
    }

    private(set) var status = Status.waitingForKeepAwake
    var isEnabled = true {
        didSet { tick() }
    }

    private var watcher: IntrusionWatcher?
    private let alert = IntrusionAlert()
    private let logger = Logger(subsystem: "com.hamzaplojovic.Caffeguard", category: "Sentry")

    private var idleDelay: TimeInterval {
        TimeInterval(UserDefaults.standard.integer(forKey: Preference.idleMinutes) * 60)
    }

    init() {
        UserDefaults.standard.register(defaults: [Preference.idleMinutes: Preference.defaultIdleMinutes])
        alert.onUnlock = { [weak self] in self?.stopWatching(.waitingForIdle) }
        // Read once at launch: if macOS asks to allow keychain access after an update,
        // the owner is here to answer, not hidden behind the red screen.
        _ = Keychain.appPassword
        Task {
            while true {
                tick()
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    private func tick() {
        guard isEnabled else { return stopWatching(.paused) }
        guard let cameraID = UserDefaults.standard.string(forKey: Preference.cameraID) else {
            return stopWatching(.setupNeeded)
        }
        let keptAwake = SystemActivity.isKeptAwake
        if watcher != nil {
            // Typing does not disarm, because that is what an intruder does. Letting the Mac sleep
            // again does, unless the alert is up: then only unlocking it does (a timer may expire).
            if !keptAwake && !alert.isShowing { stopWatching(.waitingForKeepAwake) }
            return
        }
        guard keptAwake else { status = .waitingForKeepAwake; return }
        guard SystemActivity.idleTime >= idleDelay else { status = .waitingForIdle; return }
        arm(cameraID: cameraID)
    }

    private func arm(cameraID: String) {
        // Looked up through `Cameras.available`, so a saved ID can never resolve to an iPhone.
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized,
              let device = Cameras.available.first(where: { $0.uniqueID == cameraID })
        else { status = .cameraUnavailable; return }

        do {
            let watcher = try IntrusionWatcher(device: device) { [weak self] jpeg in
                Task { @MainActor in self?.intruded(jpeg) }
            }
            watcher.start()
            self.watcher = watcher
            status = .watching
            logger.info("Armed with \(device.localizedName, privacy: .public)")
        } catch {
            status = .cameraUnavailable
            logger.error("Could not open \(device.localizedName, privacy: .public): \(error)")
        }
    }

    private func intruded(_ jpeg: Data) {
        status = .intruded
        let filename: String
        do {
            let url = try Evidence.save(jpeg)
            filename = url.lastPathComponent
            logger.notice("Intrusion photographed: \(url.path, privacy: .public)")
        } catch {
            filename = "Intrusion.jpg"
            logger.error("Could not save the intrusion photo: \(error)")
        }
        alert.show()
        emailIfEnabled(jpeg, filename: filename)
    }

    private func emailIfEnabled(_ jpeg: Data, filename: String) {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: Preference.emailAlerts),
              let address = defaults.string(forKey: Preference.gmailAddress), !address.isEmpty,
              let password = Keychain.appPassword
        else { return }

        let email = Email.intrusion(to: address, photo: jpeg, filename: filename, macName: Host.current().localizedName ?? "your Mac")
        Task { [logger] in
            do {
                try await Gmail.send(email, from: address, appPassword: password)
                logger.notice("Emailed \(filename, privacy: .public)")
            } catch {
                logger.error("Could not email \(filename, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private func stopWatching(_ newStatus: Status) {
        watcher?.stop()
        watcher = nil
        status = newStatus
    }
}

extension Sentry.Status {
    var title: LocalizedStringResource {
        switch self {
        case .setupNeeded: "Choose a Camera in Settings"
        case .paused: "Paused"
        case .waitingForKeepAwake: "Waiting for Caffeination"
        case .waitingForIdle: "Arms When You’re Away"
        case .cameraUnavailable: "Camera Unavailable"
        case .watching: "Watching"
        case .intruded: "Intrusion Detected"
        }
    }

    var symbol: String {
        switch self {
        case .setupNeeded, .paused, .cameraUnavailable: "shield.slash"
        case .waitingForKeepAwake, .waitingForIdle: "shield"
        case .watching: "shield.fill"
        case .intruded: "exclamationmark.shield.fill"
        }
    }
}
