#!/bin/sh
# Tags the version in Support/Info.plist and publishes a GitHub release with a notarized DMG.
# Run from a clean, pushed main branch.
set -eu
cd "$(dirname "$0")/.."
. scripts/lib.sh

[ -z "$(git status --porcelain)" ] || { echo "Commit your changes first." >&2; exit 1; }
# Without these, people who download the DMG get "cannot be verified".
[ -n "$identity" ] || { echo "No Developer ID Application certificate in the keychain." >&2; exit 1; }
xcrun notarytool history --keychain-profile "$notary_profile" >/dev/null 2>&1 \
    || { echo "No notarization credentials; see README > Releasing." >&2; exit 1; }

scripts/dmg.sh
gh release create "v$version" "build/Caffeguard-$version.dmg" --target main --title "Caffeguard $version" --generate-notes
