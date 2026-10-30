import AVFoundation
import SwiftUI

struct SettingsView: View {
    @AppStorage(Preference.cameraID) private var cameraID: String?
    @AppStorage(Preference.idleMinutes) private var idleMinutes = Preference.defaultIdleMinutes
    @AppStorage(Preference.intrusionScreenStyle) private var intrusionScreenStyle = IntrusionScreenStyle.redWarning
    @AppStorage(Preference.intrusionMessage) private var intrusionMessage = IntrusionScreenConfiguration.defaultMessage
    @AppStorage(Preference.intrusionUnlockTrigger) private var intrusionUnlockTrigger = IntrusionUnlockTrigger.doubleClickOrAnyKey
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
                Text("Caffeguard arms while something keeps your Mac awake, like caffeinate or Amphetamine, and it has had no input for this long.")
            }

            Section {
                Picker("Screen style", selection: $intrusionScreenStyle) {
                    ForEach(IntrusionScreenStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                TextField("Message", text: $intrusionMessage, axis: .vertical)
                    .lineLimit(2...4)
                Picker("Start verification", selection: $intrusionUnlockTrigger) {
                    ForEach(IntrusionUnlockTrigger.allCases) { trigger in
                        Text(trigger.title).tag(trigger)
                    }
                }
                IntrusionScreenPreview(configuration: IntrusionScreenConfiguration(
                    style: intrusionScreenStyle, message: intrusionMessage, unlockTrigger: intrusionUnlockTrigger
                ))
            } header: {
                Text("Intrusion Screen")
            } footer: {
                Text("Leave the message blank to use the default. Touch ID or your Mac password is always required to dismiss the alert.")
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
        .frame(width: 480, height: 640)
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
