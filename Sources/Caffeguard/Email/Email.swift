import Foundation

/// Builds the raw emails Caffeguard sends: the owner mails themselves through Gmail.
nonisolated enum Email {
    /// Safe as a fixed string: the parts are our own text and base64, which never contains "-".
    private static let boundary = "Caffeguard-Boundary"

    static func intrusion(to address: String, photo: Data, filename: String, macName: String, date: Date = .now) -> Data {
        message(
            to: address,
            subject: "Caffeguard: someone is at \(macName)",
            text: "Someone sat down at \(macName) at \(date.formatted(date: .abbreviated, time: .standard)). Their photo is attached.",
            attachment: (filename, photo),
            date: date
        )
    }

    static func test(to address: String) -> Data {
        message(
            to: address,
            subject: "Caffeguard test email",
            text: "Email alerts work. Caffeguard will send a photo here when someone sits down at your Mac.",
            attachment: nil,
            date: .now
        )
    }

    private static func message(to address: String, subject: String, text: String, attachment: (name: String, data: Data)?, date: Date) -> Data {
        var lines = [
            "From: Caffeguard <\(address)>",
            "To: \(address)",
            // RFC 2047, so names like "Hamza’s MacBook Pro" survive mail headers.
            "Subject: =?UTF-8?B?\(Data(subject.utf8).base64EncodedString())?=",
            "Date: \(headerDate.string(from: date))",
            "MIME-Version: 1.0",
            "Content-Type: multipart/mixed; boundary=\"\(boundary)\"",
            "",
            "--\(boundary)",
            "Content-Type: text/plain; charset=utf-8",
            "",
            text,
        ]
        if let attachment {
            lines += [
                "--\(boundary)",
                "Content-Type: image/jpeg",
                "Content-Disposition: attachment; filename=\"\(attachment.name)\"",
                "Content-Transfer-Encoding: base64",
                "",
                attachment.data.base64EncodedString(options: [.lineLength76Characters, .endLineWithCarriageReturn, .endLineWithLineFeed]),
            ]
        }
        lines.append("--\(boundary)--")
        return Data((lines.joined(separator: "\r\n") + "\r\n").utf8)
    }

    private static let headerDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter
    }()
}
