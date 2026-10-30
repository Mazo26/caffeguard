import Foundation

/// Sends a raw email through Gmail's SMTP server with the system `curl`.
nonisolated enum Gmail {
    static func send(_ email: Data, from address: String, appPassword: String) async throws {
        let file = FileManager.default.temporaryDirectory.appending(path: "Caffeguard-\(UUID().uuidString).eml")
        try email.write(to: file)
        defer { try? FileManager.default.removeItem(at: file) }

        // Google shows app passwords as "abcd efgh ijkl mnop"; the spaces are not part of it.
        let password = appPassword.filter { !$0.isWhitespace }
        // The password goes through stdin, never the command line, where `ps` would show it.
        let config = "user = \"\(escaped(address)):\(escaped(password))\"\n"
        do {
            try await Subprocess.run("/usr/bin/curl", [
                "--silent", "--show-error", "--ssl-reqd", "--max-time", "60",
                "--url", "smtps://smtp.gmail.com:465",
                "--mail-from", address, "--mail-rcpt", address,
                "--upload-file", file.path,
                "--config", "-",
            ], input: Data(config.utf8))
        } catch let failure as Subprocess.Failed {
            let message = failure.errorDescription ?? ""
            throw Subprocess.Failed(errorDescription: message.contains("Login denied")
                ? "Gmail rejected the address or app password."
                : message.replacing("curl: ", with: ""))
        }
    }

    private static func escaped(_ value: String) -> String {
        value.replacing("\\", with: "\\\\").replacing("\"", with: "\\\"")
    }
}
