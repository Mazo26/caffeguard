import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("General", systemImage: "gearshape") { GeneralSettings() }
            Tab("Intrusion Screen", systemImage: "exclamationmark.shield") { AlertSettings() }
            Tab("Email", systemImage: "envelope") { EmailSettings() }
        }
    }
}
