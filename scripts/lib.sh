# Shared by the build scripts. Source it from the repository root.

version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Support/Info.plist)
# The first "Developer ID Application" certificate in the keychain, or empty.
identity=$(security find-identity -v -p codesigning | sed -n 's/.*"\(Developer ID Application: .*\)"/\1/p' | head -1)
# Notarization credentials, saved once with `xcrun notarytool store-credentials caffeguard ...`.
notary_profile=caffeguard
