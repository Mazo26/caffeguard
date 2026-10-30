import SwiftUI

/// Picks the theme and the optional wallpaper of the intrusion screen, with a live preview.
struct AlertSettings: View {
    @AppStorage(Preference.theme) private var themeID = Theme.all[0].id
    @State private var wallpaper = Wallpaper.image
    @State private var isChoosingWallpaper = false
    @State private var wallpaperError: String?

    private var theme: Theme { Theme.all.first { $0.id == themeID } ?? Theme.all[0] }

    var body: some View {
        Form {
            Section {
                IntrusionAlertView(theme: theme, wallpaper: wallpaper)
                    .frame(width: 1440, height: 900)
                    .scaleEffect(0.29)
                    .frame(width: 418, height: 261)
                    .clipShape(.rect(cornerRadius: 8))
                    .allowsHitTesting(false)
                    .frame(maxWidth: .infinity)

                Picker("Theme", selection: $themeID) {
                    ForEach(Theme.all) { theme in
                        Text(theme.name).tag(theme.id)
                    }
                }
            }

            Section {
                LabeledContent("Wallpaper") {
                    HStack {
                        if wallpaper != nil {
                            Button("Remove") {
                                Wallpaper.remove()
                                wallpaper = nil
                            }
                        }
                        Button(wallpaper == nil ? "Choose…" : "Change…") { isChoosingWallpaper = true }
                    }
                }
            } footer: {
                Text(wallpaperError ?? "Shown behind the theme’s text, tinted in its colors so the text stays readable.")
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .fixedSize()
        .fileImporter(isPresented: $isChoosingWallpaper, allowedContentTypes: [.image]) { result in
            do {
                try Wallpaper.set(from: result.get())
                wallpaper = Wallpaper.image
                wallpaperError = nil
            } catch {
                wallpaperError = "That file could not be used as a wallpaper."
            }
        }
    }
}
