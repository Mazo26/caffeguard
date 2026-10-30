import AppKit

/// Intrusion photos, saved to the chosen folder or ~/Pictures/Caffeguard by default.
enum Evidence {
    static let defaultFolder = URL.picturesDirectory.appending(path: "Caffeguard", directoryHint: .isDirectory)

    static func folder(defaults: UserDefaults = .standard) -> URL {
        guard let path = defaults.string(forKey: Preference.photoFolderPath), !path.isEmpty else {
            return defaultFolder
        }
        return URL(filePath: path, directoryHint: .isDirectory)
    }

    private static let fileDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd 'at' HH.mm.ss"
        return formatter
    }()

    static func save(_ jpeg: Data, defaults: UserDefaults = .standard) throws -> URL {
        let folder = folder(defaults: defaults)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appending(path: "Intrusion \(fileDate.string(from: .now)).jpg")
        try jpeg.write(to: url)
        return url
    }

    static func showInFinder() {
        let folder = folder()
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        NSWorkspace.shared.open(folder)
    }
}
