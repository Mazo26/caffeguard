import AppKit

/// Intrusion photos, saved to ~/Pictures/Caffeguard.
enum Evidence {
    static let folder = URL.picturesDirectory.appending(path: "Caffeguard", directoryHint: .isDirectory)

    private static let fileDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd 'at' HH.mm.ss"
        return formatter
    }()

    static func save(_ jpeg: Data) throws -> URL {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appending(path: "Intrusion \(fileDate.string(from: .now)).jpg")
        try jpeg.write(to: url)
        return url
    }

    static func showInFinder() {
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        NSWorkspace.shared.open(folder)
    }
}
