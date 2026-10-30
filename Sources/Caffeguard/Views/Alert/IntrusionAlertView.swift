import SwiftUI

/// The full-screen intrusion message, drawn in a theme over an optional wallpaper.
struct IntrusionAlertView: View {
    let theme: Theme
    var wallpaper: NSImage?
    var unlock: () -> Void = {}

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: theme.symbol)
                .font(.system(size: 128))
                .foregroundStyle(theme.accent)
            Text(theme.title)
                .font(theme.titleFont(64))
            Text(theme.message)
                .font(theme.bodyFont(28))
            Label("Click or press any key to unlock with Touch ID or your password.", systemImage: "touchid")
                .font(theme.bodyFont(18))
                .opacity(0.7)
                .padding(.top, 24)
        }
        .foregroundStyle(theme.foreground)
        .multilineTextAlignment(.center)
        .padding(64)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { background }
        .contentShape(.rect)
        .onTapGesture(perform: unlock)
    }

    @ViewBuilder private var background: some View {
        let gradient = LinearGradient(colors: theme.colors, startPoint: .top, endPoint: .bottom)
        if let wallpaper {
            Image(nsImage: wallpaper)
                .resizable()
                .scaledToFill()
                // A wash of the theme's colors keeps its text readable on any picture.
                .overlay(gradient.opacity(0.6))
                .clipped()
        } else {
            gradient
        }
    }
}
