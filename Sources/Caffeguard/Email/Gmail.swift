import Foundation

/// Sends a raw email through Gmail's SMTP server with the system `curl`.
nonisolated enum Gmail {
    struct SendFailed: LocalizedError {
        let errorDescription: String?
    }

    static func send(_ email: Data, from address: String, appPassword: String) async throws {
        let file = FileManager.default.temporaryDirectory.appending(path: "Caffeguard-\(UUID().uuidString).eml")
        try email.write(to: file)
        defer { try? FileManager.default.removeItem(at: file) }

        let curl = Process()
        curl.executableURL = URL(filePath: "/usr/bin/curl")
        curl.arguments = [
            "--silent", "--show-error", "--ssl-reqd", "--max-time", "60",
            "--url", "smtps://smtp.gmail.com:465",
            "--mail-from", address, "--mail-rcpt", address,
            "--upload-file", file.path,
            "--config", "-",
        ]
        // The password goes through stdin, never the command line, where `ps` would show it.
        let input = Pipe(), errors = Pipe()
        curl.standardInput = input
        curl.standardError = errors
        // Google shows app passwords as "abcd efgh ijkl mnop"; the spaces are not part of it.
        let password = appPassword.filter { !$0.isWhitespace }
        let config = "user = \"\(escaped(address)):\(escaped(password))\"\n"

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            curl.terminationHandler = { curl in
                guard curl.terminationStatus != 0 else { return continuation.resume() }
                let message = String(decoding: errors.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
                continuation.resume(throwing: SendFailed(errorDescription: friendly(message)))
            }
            do {
                try curl.run()
                input.fileHandleForWriting.write(Data(config.utf8))
                try input.fileHandleForWriting.close()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private static func escaped(_ value: String) -> String {
        value.replacing("\\", with: "\\\\").replacing("\"", with: "\\\"")
    }

    private static func friendly(_ curlError: String) -> String {
        curlError.contains("Login denied")
            ? "Gmail rejected the address or app password."
            : curlError.replacing("curl: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
