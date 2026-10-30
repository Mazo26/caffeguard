import SwiftUI

/// Radio list of the cameras Caffeguard may use. iPhones are never offered.
struct CameraPicker: View {
    @Binding var selection: String?
    @State private var cameras = Cameras.available

    var body: some View {
        if cameras.isEmpty {
            Text("No camera found. Connect a webcam and reopen this window.")
                .foregroundStyle(.secondary)
        } else {
            Picker("Camera", selection: $selection) {
                ForEach(cameras, id: \.uniqueID) { camera in
                    Text(camera.localizedName).tag(Optional(camera.uniqueID))
                }
            }
            .pickerStyle(.radioGroup)
        }
    }
}
