/// `UserDefaults` keys shared by the settings views (`@AppStorage`) and `Sentry`.
enum Preference {
    static let cameraID = "cameraID"
    static let idleMinutes = "idleMinutes"
    static let defaultIdleMinutes = 5
    static let idleMinuteChoices = [1, 2, 5, 10, 15, 30]
}
