import AVFoundation
import SwiftUI

struct SettingsView: View {
    @AppStorage(Preference.cameraID) private var cameraID: String?
    @AppStorage(Preference.idleMinutes) private var idleMinutes = Preference.defaultIdleMinutes
    @AppStorage(Preference.emailAlerts) private var emailAlerts = false
    @AppStorage(Preference.gmailAddress) private var gmailAddress = ""
    @State private var appPassword = Keychain.appPassword ?? ""
    @State private var testResult: LocalizedStringKey?
    @State private var isSendingTest = false

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

            Section {
                Toggle("Email me a photo of each intrusion", isOn: $emailAlerts)
                Group {
                    TextField("Gmail address", text: $gmailAddress, prompt: Text(verbatim: "you@gmail.com"))
                        .textContentType(.username)
                    SecureField("App password", text: $appPassword, prompt: Text("16 letters from Google"))
                        .onChange(of: appPassword) { Keychain.appPassword = appPassword }
                    LabeledContent {
                        Button("Send Test Email", action: sendTest)
                            .disabled(gmailAddress.isEmpty || appPassword.isEmpty || isSendingTest)
                    } label: {
                        if isSendingTest {
                            ProgressView().controlSize(.small)
                        } else if let testResult {
                            Text(testResult).foregroundStyle(.secondary)
                        }
                    }
                }
                .disabled(!emailAlerts)
            } header: {
                Text("Email Alerts")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gmail sends the photo from your address to itself. The app password is stored in your keychain.")
                    Link("Create an app password…", destination: URL(string: "https://myaccount.google.com/apppasswords")!)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 440)
        .fixedSize()
    }

    private func sendTest() {
        isSendingTest = true
        Task {
            do {
                try await Gmail.send(Email.test(to: gmailAddress), from: gmailAddress, appPassword: appPassword)
                testResult = "Sent. Check your inbox."
            } catch {
                testResult = "\(error.localizedDescription)"
            }
            isSendingTest = false
        }
    }
}
