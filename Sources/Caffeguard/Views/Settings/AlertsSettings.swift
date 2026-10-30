import SwiftUI

/// Where intrusion photos are sent: Gmail and iMessage.
struct AlertsSettings: View {
    @AppStorage(Preference.emailAlerts) private var emailAlerts = false
    @AppStorage(Preference.gmailAddress) private var gmailAddress = ""
    @State private var appPassword = Keychain.appPassword ?? ""
    @State private var testResult: LocalizedStringKey?
    @State private var isSendingTest = false
    @AppStorage(Preference.iMessageAlerts) private var iMessageAlerts = false
    @AppStorage(Preference.iMessageHandle) private var iMessageHandle = ""
    @State private var messageResult: LocalizedStringKey?
    @State private var isSendingMessage = false

    var body: some View {
        Form {
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
                Text("Email")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gmail sends the photo from your address to itself. The app password is stored in your keychain.")
                    Link("Create an app password…", destination: URL(string: "https://myaccount.google.com/apppasswords")!)
                }
            }

            Section {
                Toggle("Text me a photo of each intrusion", isOn: $iMessageAlerts)
                Group {
                    TextField("Phone number or Apple ID", text: $iMessageHandle, prompt: Text(verbatim: "+49 151 23456789"))
                    LabeledContent {
                        Button("Send Test Message", action: sendTestMessage)
                            .disabled(iMessageHandle.isEmpty || isSendingMessage)
                    } label: {
                        if isSendingMessage {
                            ProgressView().controlSize(.small)
                        } else if let messageResult {
                            Text(messageResult).foregroundStyle(.secondary)
                        }
                    }
                }
                .disabled(!iMessageAlerts)
            } header: {
                Text("iMessage")
            } footer: {
                Text("Sent from this Mac’s Messages app, usually to your own number. The first time, macOS asks to let Caffeguard control Messages.")
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .fixedSize()
    }

    private func sendTestMessage() {
        isSendingMessage = true
        Task {
            do {
                try await IMessage.send("Caffeguard test message. Intrusion photos will arrive here.", photo: nil, to: iMessageHandle)
                messageResult = "Sent. Check Messages."
            } catch {
                messageResult = "\(error.localizedDescription)"
            }
            isSendingMessage = false
        }
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
