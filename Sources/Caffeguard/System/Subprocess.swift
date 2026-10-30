import Foundation

/// Runs a command-line tool without blocking the caller.
nonisolated enum Subprocess {
    struct Failed: LocalizedError {
        let errorDescription: String?
    }

    /// Throws `Failed` carrying the tool's error output when it exits with a non-zero status.
    static func run(_ path: String, _ arguments: [String], input: Data? = nil) async throws {
        let process = Process()
        process.executableURL = URL(filePath: path)
        process.arguments = arguments
        let stdin = Pipe(), stderr = Pipe()
        process.standardInput = stdin
        process.standardError = stderr
        process.standardOutput = FileHandle.nullDevice

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            process.terminationHandler = { process in
                guard process.terminationStatus != 0 else { return continuation.resume() }
                let message = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
                continuation.resume(throwing: Failed(errorDescription: message.trimmingCharacters(in: .whitespacesAndNewlines)))
            }
            do {
                try process.run()
                if let input { stdin.fileHandleForWriting.write(input) }
                try stdin.fileHandleForWriting.close()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
