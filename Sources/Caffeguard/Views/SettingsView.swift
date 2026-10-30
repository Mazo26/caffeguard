import AVFoundation
import SwiftUI

struct SettingsView: View {
    @AppStorage(Preference.cameraID) private var cameraID: String?
    @AppStorage(Preference.idleMinutes) private var idleMinutes = Preference.defaultIdleMinutes

    var body: some View {
        Form {
            Section {
                CameraPicker(selection: $cameraID)
                    // Covers choosing a camera here after skipping the welcome window.
                    .onChange(of: cameraID) { Task { await AVCaptureDevice.requestAccess(for: .video) } }
            } footer: {
                Text("iPhone cameras are never used.")
            }

            Section {
                Picker("Arm after", selection: $idleMinutes) {
                    ForEach(Preference.idleMinuteChoices, id: \.self) { minutes in
                        Text(Duration.seconds(minutes * 60), format: .units(allowed: [.minutes], width: .wide))
                            .tag(minutes)
                    }
                }
            } footer: {
                Text("Caffeguard arms while caffeinate is running and your Mac has had no input for this long.")
            }
        }
        .formStyle(.grouped)
        .frame(width: 440)
        .fixedSize()
    }
}
