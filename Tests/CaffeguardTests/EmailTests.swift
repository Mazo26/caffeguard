import Foundation
import Testing
@testable import Caffeguard

struct EmailTests {
    private let photo = Data((0..<200).map { UInt8($0) })

    private func intrusion() -> String {
        let data = Email.intrusion(
            to: "me@gmail.com", photo: photo, filename: "Intrusion 2026-10-30 at 17.29.39.jpg",
            macName: "Hamza’s MacBook Pro", date: Date(timeIntervalSince1970: 0)
        )
        return String(decoding: data, as: UTF8.self)
    }

    @Test func itIsSentFromAndToTheOwnersAddress() {
        #expect(intrusion().contains("From: Caffeguard <me@gmail.com>\r\n"))
        #expect(intrusion().contains("To: me@gmail.com\r\n"))
    }

    @Test func aSubjectWithACurlyApostropheIsEncodedForMailHeaders() {
        let encoded = Data("Caffeguard: someone is at Hamza’s MacBook Pro".utf8).base64EncodedString()
        #expect(intrusion().contains("Subject: =?UTF-8?B?\(encoded)?=\r\n"))
    }

    @Test func thePhotoIsAttachedIntactInLinesOfAtMost76Characters() throws {
        let mail = intrusion()
        #expect(mail.contains("filename=\"Intrusion 2026-10-30 at 17.29.39.jpg\""))
        let body = try #require(mail.components(separatedBy: "Content-Transfer-Encoding: base64\r\n\r\n").last)
        let lines = body.components(separatedBy: "\r\n").prefix { !$0.hasPrefix("--") && !$0.isEmpty }
        #expect(lines.allSatisfy { $0.count <= 76 })
        #expect(Data(base64Encoded: lines.joined()) == photo)
    }

    @Test func theTestEmailHasNoAttachment() {
        let mail = String(decoding: Email.test(to: "me@gmail.com"), as: UTF8.self)
        #expect(!mail.contains("Content-Disposition: attachment"))
    }
}
