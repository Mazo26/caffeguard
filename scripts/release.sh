#!/bin/sh
# Tags the version in Support/Info.plist and publishes a GitHub release with the DMG.
# Run from a clean, pushed main branch.
set -eu
cd "$(dirname "$0")/.."

version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Support/Info.plist)
[ -z "$(git status --porcelain)" ] || { echo "Commit your changes first." >&2; exit 1; }

scripts/dmg.sh
gh release create "v$version" "build/Caffeguard-$version.dmg" --target main --title "Caffeguard $version" --generate-notes
