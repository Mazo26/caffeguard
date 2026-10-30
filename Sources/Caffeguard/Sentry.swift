import AppKit
import AVFoundation
import Observation
import os

/// Arms when something keeps the Mac awake and it is idle, watches the chosen camera, and raises the
/// alert when someone faces it. It keeps watching behind the alert, so everyone who sits
/// down is photographed, until the owner unlocks the alert.
@Observable
final class Sentry {
    enum Status {
        case setupNeeded, paused, cameraAccessNeeded, waitingForKeepAwake, waitingForIdle, cameraUnavailable, watching, intruded
    }

    private(set) var status = Status.waitingForKeepAwake
    private(set) var lastPhoto = Evidence.latest
    var isEnabled = true {
        didSet { tick() }
    }

    private var watcher: IntrusionWatcher?
    private let alert = IntrusionAlert()
    private let logger = Logger(subsystem: "com.hamzaplojovic.Caffeguard", category: "Sentry")

    private var idleDelay: TimeInterval {
        TimeInterval(max(1, UserDefaults.standard.integer(forKey: Preference.idleSeconds)))
    }

    init() {
        let defaults = UserDefaults.standard
        // 1.0.5 and earlier stored the delay in minutes. Migrate before registering defaults,
        // because a registered default would make the new key look already set.
        if defaults.object(forKey: Preference.idleSeconds) == nil, defaults.object(forKey: "idleMinutes") != nil {
            defaults.set(defaults.integer(forKey: "idleMinutes") * 60, forKey: Preference.idleSeconds)
            defaults.removeObject(forKey: "idleMinutes")
        }
        defaults.register(defaults: [Preference.idleSeconds: Preference.defaultIdleSeconds])
        alert.onUnlock = { [weak self] in self?.stopWatching(.waitingForIdle) }
        // A Caffeguard that silently cannot see is worse than a prompt while the owner is here.
        if defaults.string(forKey: Preference.cameraID) != nil,
           AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            Task { _ = await AVCaptureDevice.requestAccess(for: .video) }
        }
        // Read once at launch: if macOS asks to allow keychain access after an update,
        // the owner is here to answer, not hidden behind the red screen.
        _ = Keychain.appPassword
        Task {
            while true {
                tick()
                // The tolerance lets macOS fold this wake-up into others, so a check costs almost nothing.
                try? await Task.sleep(for: .seconds(1), tolerance: .milliseconds(500))
            }
        }
    }

    private func tick() {
        guard isEnabled else { return stopWatching(.paused) }
        guard let cameraID = UserDefaults.standard.string(forKey: Preference.cameraID) else {
            return stopWatching(.setupNeeded)
        }
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            return stopWatching(.cameraAccessNeeded)
        }
        let keptAwake = SystemActivity.isKeptAwake
        if watcher != nil {
            // Typing does not disarm, because that is what an intruder does. Letting the Mac sleep
            // again does, unless the alert is up: then only unlocking it does (a timer may expire).
            if !keptAwake && !alert.isShowing { stopWatching(.waitingForKeepAwake) }
            return
        }
        guard keptAwake else { setStatus(.waitingForKeepAwake); return }
        guard SystemActivity.idleTime >= idleDelay else { setStatus(.waitingForIdle); return }
        arm(cameraID: cameraID)
    }

    private func arm(cameraID: String) {
        // Looked up through `Cameras.available`, so a saved ID can never resolve to an iPhone.
        guard let device = Cameras.available.first(where: { $0.uniqueID == cameraID })
        else { setStatus(.cameraUnavailable); return }

        do {
            let watcher = try IntrusionWatcher(device: device) { [weak self] jpeg in
                Task { @MainActor in self?.intruded(jpeg) }
            }
            watcher.start()
            self.watcher = watcher
            setStatus(.watching)
            logger.info("Armed with \(device.localizedName, privacy: .public)")
        } catch {
            setStatus(.cameraUnavailable)
            logger.error("Could not open \(device.localizedName, privacy: .public): \(error)")
        }
    }

    /// Asks for camera access, or opens its Privacy setting once macOS has stopped asking.
    func requestCameraAccess() {
        NSApp.activate()
        if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            Task {
                _ = await AVCaptureDevice.requestAccess(for: .video)
                tick()
            }
        } else {
            NSWorkspace.shared.open(Cameras.privacySettings)
        }
    }

    private func intruded(_ jpeg: Data) {
        let firstSighting = !alert.isShowing
        setStatus(.intruded)
        let photo: URL?
        do {
            photo = try Evidence.save(jpeg)
            lastPhoto = photo
            logger.notice("Intrusion photographed: \(photo?.path ?? "", privacy: .public)")
        } catch {
            photo = nil
            logger.error("Could not save the intrusion photo: \(error)")
        }
        alert.show()
        if firstSighting && UserDefaults.standard.bool(forKey: Preference.lockScreen) {
            // A few seconds first, so the intruder reads the screen before the login window hides it.
            Task {
                try? await Task.sleep(for: .seconds(3))
                ScreenLock.lockNow()
            }
        }
        sendAlerts(jpeg, photo: photo)
    }

    private func sendAlerts(_ jpeg: Data, photo: URL?) {
        let defaults = UserDefaults.standard
        let macName = Host.current().localizedName ?? "your Mac"

        if defaults.bool(forKey: Preference.emailAlerts),
           let address = defaults.string(forKey: Preference.gmailAddress), !address.isEmpty,
           let password = Keychain.appPassword {
            let email = Email.intrusion(to: address, photo: jpeg, filename: photo?.lastPathComponent ?? "Intrusion.jpg", macName: macName)
            deliver("email") { try await Gmail.send(email, from: address, appPassword: password) }
        }
        if defaults.bool(forKey: Preference.iMessageAlerts),
           let handle = defaults.string(forKey: Preference.iMessageHandle), !handle.isEmpty {
            deliver("iMessage") { try await IMessage.send("Caffeguard: someone sat down at \(macName).", photo: photo, to: handle) }
        }
    }

    private func deliver(_ channel: String, _ send: @escaping () async throws -> Void) {
        Task { [logger] in
            do {
                try await send()
                logger.notice("Sent the \(channel, privacy: .public) alert")
            } catch {
                logger.error("Could not send the \(channel, privacy: .public) alert: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private func stopWatching(_ newStatus: Status) {
        watcher?.stop()
        watcher = nil
        setStatus(newStatus)
    }

    /// Ticks run every second; assigning an unchanged status would still redraw the menu bar.
    private func setStatus(_ newStatus: Status) {
        if status != newStatus { status = newStatus }
    }
}

extension Sentry.Status {
    var title: LocalizedStringResource {
        switch self {
        case .setupNeeded: "Choose a Camera in Settings"
        case .paused: "Paused"
        case .cameraAccessNeeded: "Camera Access Needed"
        case .waitingForKeepAwake: "Waiting for Caffeination"
        case .waitingForIdle: "Arms When You’re Away"
        case .cameraUnavailable: "Camera Unavailable"
        case .watching: "Watching"
        case .intruded: "Intrusion Detected"
        }
    }

    var symbol: String {
        switch self {
        case .setupNeeded, .paused, .cameraAccessNeeded, .cameraUnavailable: "shield.slash"
        case .waitingForKeepAwake, .waitingForIdle: "shield"
        case .watching: "shield.fill"
        case .intruded: "exclamationmark.shield.fill"
        }
    }
}
