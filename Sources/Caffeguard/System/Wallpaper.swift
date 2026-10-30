import AppKit

/// An optional picture behind the intrusion screen, copied into Application Support so it
/// survives the original being moved or deleted.
enum Wallpaper {
    private static let url = URL.applicationSupportDirectory.appending(path: "Caffeguard/Wallpaper")

    static var image: NSImage? { NSImage(contentsOf: url) }

    static func set(from source: URL) throws {
        let accessing = source.startAccessingSecurityScopedResource()
        defer { if accessing { source.stopAccessingSecurityScopedResource() } }
        guard NSImage(contentsOf: source) != nil else { throw CocoaError(.fileReadCorruptFile) }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? FileManager.default.removeItem(at: url)
        try FileManager.default.copyItem(at: source, to: url)
    }

    static func remove() {
        try? FileManager.default.removeItem(at: url)
    }
}
