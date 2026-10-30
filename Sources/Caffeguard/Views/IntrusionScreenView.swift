import SwiftUI

/// Shared by the alert windows and the non-interactive preview in Settings.
struct IntrusionScreenView: View {
    let configuration: IntrusionScreenConfiguration

    private var accent: Color {
        switch configuration.style {
        case .redWarning: .white
        case .darkWarning: .orange
        case .minimal: .white
        }
    }

    private var background: Color {
        switch configuration.style {
        case .redWarning: .red
        case .darkWarning: Color(red: 0.10, green: 0.11, blue: 0.14)
        case .minimal: .black
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / 960, geometry.size.height / 600, 1.25)
            let minimal = configuration.style == .minimal

            VStack(spacing: 24 * scale) {
                Image(systemName: minimal ? "lock.fill" : "exclamationmark.shield.fill")
                    .font(.system(size: (minimal ? 64 : 112) * scale))
                    .foregroundStyle(accent)
                Text(minimal ? "Protected Mac" : "Intrusion Detected")
                    .font(.system(size: (minimal ? 48 : 64) * scale, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(verbatim: configuration.displayMessage)
                    .font(.system(size: 24 * scale))
                    .lineLimit(8)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: 1000)
                Label(configuration.unlockTrigger.instruction, systemImage: "lock.shield")
                    .font(.system(size: 18 * scale))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.top, 16 * scale)
            }
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(40 * scale)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(background)
        }
        .environment(\.colorScheme, .dark)
    }
}

struct IntrusionScreenPreview: View {
    let configuration: IntrusionScreenConfiguration

    var body: some View {
        GeometryReader { geometry in
            IntrusionScreenView(configuration: configuration)
                .frame(width: 960, height: 600)
                .scaleEffect(geometry.size.width / 960, anchor: .topLeading)
        }
        .aspectRatio(1.6, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Intrusion screen preview")
        .accessibilityValue("\(configuration.style.title). \(configuration.displayMessage) \(configuration.unlockTrigger.instruction)")
    }
}
