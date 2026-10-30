import SwiftUI

/// The colors, typeface, symbol and words of the intrusion screen. The layout never changes.
struct Theme: Identifiable {
    enum Typeface {
        case system(Font.Design)
        case named(title: String, body: String)
    }

    let id: String
    let name: String
    /// Background, top to bottom.
    let colors: [Color]
    let foreground: Color
    let accent: Color
    let typeface: Typeface
    let symbol: String
    let title: String
    let message: String

    func titleFont(_ size: CGFloat) -> Font {
        switch typeface {
        case .system(let design): .system(size: size, weight: .bold, design: design)
        case .named(let title, _): .custom(title, fixedSize: size)
        }
    }

    func bodyFont(_ size: CGFloat) -> Font {
        switch typeface {
        case .system(let design): .system(size: size, design: design)
        case .named(_, let body): .custom(body, fixedSize: size)
        }
    }

    static var current: Theme {
        let id = UserDefaults.standard.string(forKey: Preference.theme)
        return all.first { $0.id == id } ?? all[0]
    }
}

extension Theme {
    static let all: [Theme] = [
        Theme(id: "classic", name: "Classic", colors: [.hex(0xFF3B30)], foreground: .white, accent: .white,
              typeface: .system(.default), symbol: "exclamationmark.shield.fill",
              title: "Intrusion Detected", message: "This Mac is protected. A photo has been taken."),
        Theme(id: "espresso", name: "Espresso", colors: [.hex(0x2B2118), .hex(0x120D09)], foreground: .hex(0xF6EFE6), accent: .hex(0xF7B34A),
              typeface: .named(title: "Didot-Bold", body: "Didot"), symbol: "cup.and.saucer.fill",
              title: "This Mac Is Brewing Something", message: "And it isn’t for you. Your photo has been taken."),
        Theme(id: "terminal", name: "Terminal", colors: [.black], foreground: .hex(0x33FF66), accent: .hex(0x33FF66),
              typeface: .named(title: "Menlo-Bold", body: "Menlo-Regular"), symbol: "terminal.fill",
              title: "ACCESS DENIED", message: "$ capture --intruder\nphoto saved. owner notified."),
        Theme(id: "crime-scene", name: "Crime Scene", colors: [.hex(0xFFD400)], foreground: .hex(0x111111), accent: .hex(0x111111),
              typeface: .named(title: "Impact", body: "Futura-Medium"), symbol: "camera.fill",
              title: "DO NOT CROSS", message: "This workstation is under surveillance. Smile, you’re on camera."),
        Theme(id: "say-cheese", name: "Say Cheese", colors: [.hex(0xFFD6E0), .hex(0xFFB3C7)], foreground: .hex(0x5A1E35), accent: .hex(0xE0457B),
              typeface: .system(.rounded), symbol: "face.smiling.inverse",
              title: "Say Cheese!", message: "You’ve just been photographed. The owner will see this soon."),
        Theme(id: "noir", name: "Noir", colors: [.hex(0x1A1A1A), .black], foreground: .white, accent: .hex(0xBBBBBB),
              typeface: .named(title: "Didot-Bold", body: "Didot"), symbol: "eye",
              title: "Caught.", message: "Every face tells a story. Yours was just saved."),
        Theme(id: "haunted", name: "Haunted", colors: [.hex(0x2A1446), .hex(0x0E0618)], foreground: .hex(0xE9DDFF), accent: .hex(0xB18CFF),
              typeface: .named(title: "Chalkduster", body: "Chalkduster"), symbol: "moon.stars.fill",
              title: "Boo.", message: "This Mac is haunted by its owner, and they saw you."),
        Theme(id: "arcade", name: "Arcade", colors: [.hex(0x14002B), .black], foreground: .hex(0x00F0FF), accent: .hex(0xFF2BD6),
              typeface: .system(.monospaced), symbol: "gamecontroller.fill",
              title: "GAME OVER", message: "INSERT OWNER TO CONTINUE\nYOUR FACE IS ON THE HIGH SCORE TABLE"),
        Theme(id: "vault", name: "Vault", colors: [.hex(0x5B6470), .hex(0x2A2F36)], foreground: .hex(0xF2F4F7), accent: .hex(0xC9D1DB),
              typeface: .system(.monospaced), symbol: "lock.shield.fill",
              title: "Vault Sealed", message: "Owner verification required. Unauthorized face recorded."),
        Theme(id: "polite", name: "Polite", colors: [.hex(0xDDEBDD), .hex(0xC5DCC6)], foreground: .hex(0x23412A), accent: .hex(0x3E7C4F),
              typeface: .system(.rounded), symbol: "hand.raised.fill",
              title: "Excuse Me", message: "This isn’t your Mac. Its owner has your photo now."),
        Theme(id: "siren", name: "Siren", colors: [.hex(0x0A1F6B), .hex(0x020818)], foreground: .white, accent: .hex(0xFF3B30),
              typeface: .named(title: "Futura-Bold", body: "Futura-Medium"), symbol: "light.beacon.max.fill",
              title: "Alarm Triggered", message: "Your photo has been taken. Please step away from the Mac."),
        Theme(id: "royal-decree", name: "Royal Decree", colors: [.hex(0x5C0F1E), .hex(0x2E0610)], foreground: .hex(0xF3E3B5), accent: .hex(0xD4AF37),
              typeface: .named(title: "Copperplate-Bold", body: "Baskerville"), symbol: "crown.fill",
              title: "By Order of the Owner", message: "Thou shalt not touch this Mac.\nThy likeness hath been recorded."),
        Theme(id: "zen", name: "Zen", colors: [.hex(0xF4EFE6), .hex(0xE8E0D2)], foreground: .hex(0x3D3A35), accent: .hex(0x7A8B6F),
              typeface: .named(title: "Optima-Bold", body: "Optima-Regular"), symbol: "leaf.fill",
              title: "Breathe. Step Away.", message: "This Mac belongs to someone else. They have your photo now."),
        Theme(id: "biohazard", name: "Biohazard", colors: [.hex(0x101010)], foreground: .hex(0xC6FF00), accent: .hex(0xC6FF00),
              typeface: .named(title: "Impact", body: "Menlo-Bold"), symbol: "exclamationmark.triangle.fill",
              title: "DANGER", message: "OWNER’S PROPERTY. FACE SCANNED. CONTAMINATION LOGGED."),
        Theme(id: "sticky-note", name: "Sticky Note", colors: [.hex(0xFFF59D), .hex(0xFFEB6E)], foreground: .hex(0x3A3220), accent: .hex(0x3A3220),
              typeface: .named(title: "MarkerFelt-Wide", body: "MarkerFelt-Thin"), symbol: "note.text",
              title: "Nope.", message: "Not your laptop. Photo taken.\n— the owner"),
        Theme(id: "mission-control", name: "Mission Control", colors: [.hex(0x0B1026), .black], foreground: .hex(0xE6ECFF), accent: .hex(0x6EA8FF),
              typeface: .named(title: "AvenirNext-Heavy", body: "AvenirNext-Medium"), symbol: "antenna.radiowaves.left.and.right",
              title: "Houston, We Have a Problem", message: "Unidentified life form at the keyboard. Image captured."),
        Theme(id: "judgy-cat", name: "Judgy Cat", colors: [.hex(0xFFB25B), .hex(0xFF8A3D)], foreground: .hex(0x3B1F0B), accent: .hex(0x3B1F0B),
              typeface: .system(.rounded), symbol: "cat.fill",
              title: "The Cat Saw You", message: "This Mac is guarded by a very judgmental cat. It took your picture."),
        Theme(id: "extra-extra", name: "Extra! Extra!", colors: [.hex(0xF5F1E8)], foreground: .hex(0x111111), accent: .hex(0x111111),
              typeface: .named(title: "Baskerville-Bold", body: "Baskerville"), symbol: "newspaper.fill",
              title: "INTRUDER CAUGHT", message: "Local snoop photographed red-handed at an unattended Mac. More at eleven."),
        Theme(id: "neon", name: "Neon", colors: [.hex(0x1B0221), .hex(0x09000C)], foreground: .hex(0xFF4FD8), accent: .hex(0xFF4FD8),
              typeface: .named(title: "Futura-Bold", body: "Futura-Medium"), symbol: "heart.slash.fill",
              title: "Not Yours, Babe", message: "Hands off. The owner already has your photo."),
        Theme(id: "minimal", name: "Minimal", colors: [.white], foreground: .black, accent: .black,
              typeface: .named(title: "HelveticaNeue-UltraLight", body: "HelveticaNeue-Light"), symbol: "lock",
              title: "Locked.", message: "Photographed."),
    ]
}

private extension Color {
    static func hex(_ rgb: UInt32) -> Color {
        Color(red: Double(rgb >> 16 & 0xFF) / 255, green: Double(rgb >> 8 & 0xFF) / 255, blue: Double(rgb & 0xFF) / 255)
    }
}
