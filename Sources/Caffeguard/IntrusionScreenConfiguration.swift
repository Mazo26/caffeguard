import Foundation

enum IntrusionScreenStyle: String, CaseIterable, Identifiable {
    case redWarning, darkWarning, minimal

    var id: Self { self }

    var title: String {
        switch self {
        case .redWarning: "Red Warning"
        case .darkWarning: "Dark Warning"
        case .minimal: "Minimal"
        }
    }
}

enum IntrusionUnlockTrigger: String, CaseIterable, Identifiable {
    case doubleClick, anyKey, doubleClickOrAnyKey

    enum Interaction {
        case doubleClick, keyPress
    }

    var id: Self { self }

    var title: String {
        switch self {
        case .doubleClick: "Double-click"
        case .anyKey: "Any key"
        case .doubleClickOrAnyKey: "Double-click or any key"
        }
    }

    var instruction: String {
        switch self {
        case .doubleClick: "Double-click to verify with Touch ID or your Mac password."
        case .anyKey: "Press any key to verify with Touch ID or your Mac password."
        case .doubleClickOrAnyKey: "Double-click or press any key to verify with Touch ID or your Mac password."
        }
    }

    func accepts(_ interaction: Interaction) -> Bool {
        switch (self, interaction) {
        case (.doubleClick, .doubleClick), (.anyKey, .keyPress), (.doubleClickOrAnyKey, _): true
        default: false
        }
    }
}

struct IntrusionScreenConfiguration {
    static let defaultMessage = "This Mac is protected. A photo has been taken."

    var style: IntrusionScreenStyle = .redWarning
    var message = defaultMessage
    var unlockTrigger: IntrusionUnlockTrigger = .doubleClickOrAnyKey

    var displayMessage: String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? Self.defaultMessage : trimmed
    }
}

extension IntrusionScreenConfiguration {
    init(defaults: UserDefaults) {
        style = defaults.string(forKey: Preference.intrusionScreenStyle)
            .flatMap(IntrusionScreenStyle.init(rawValue:)) ?? .redWarning
        message = defaults.string(forKey: Preference.intrusionMessage) ?? Self.defaultMessage
        unlockTrigger = defaults.string(forKey: Preference.intrusionUnlockTrigger)
            .flatMap(IntrusionUnlockTrigger.init(rawValue:)) ?? .doubleClickOrAnyKey
    }
}
