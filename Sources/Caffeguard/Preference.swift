/// `UserDefaults` keys shared by the settings views (`@AppStorage`) and `Sentry`.
enum Preference {
    static let cameraID = "cameraID"
    static let idleSeconds = "idleSeconds"
    static let defaultIdleSeconds = 300
    static let idleChoices = [10, 30, 60, 120, 300, 600, 900, 1800]
    static let theme = "theme"
    static let emailAlerts = "emailAlerts"
    static let gmailAddress = "gmailAddress"
    // The Gmail app password lives in `Keychain`, not here.
}
