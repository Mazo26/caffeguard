import AppKit
import Testing
@testable import Caffeguard

struct ThemeTests {
    @Test func thereAreTwentyThemesWithUniqueIDs() {
        #expect(Theme.all.count == 20)
        #expect(Set(Theme.all.map(\.id)).count == Theme.all.count)
    }

    // A misspelled font or symbol does not fail; SwiftUI silently draws the default instead.
    @Test func everyFontAndSymbolExists() {
        for theme in Theme.all {
            #expect(NSImage(systemSymbolName: theme.symbol, accessibilityDescription: nil) != nil, "\(theme.name): symbol \(theme.symbol)")
            if case .named(let title, let body) = theme.typeface {
                #expect(NSFont(name: title, size: 12) != nil, "\(theme.name): font \(title)")
                #expect(NSFont(name: body, size: 12) != nil, "\(theme.name): font \(body)")
            }
        }
    }
}
