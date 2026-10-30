#!/bin/sh
# Builds a universal (Apple silicon + Intel) build/Caffeguard.app, signed with your
# Developer ID when the keychain has one, otherwise for this Mac only.
set -eu
cd "$(dirname "$0")/.."
. scripts/lib.sh

swift build -c release --arch arm64 --arch x86_64
app=build/Caffeguard.app
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/Caffeguard" "$app/Contents/MacOS/"
cp Support/Info.plist "$app/Contents/"
cp Support/AppIcon.icns "$app/Contents/Resources/"

if [ -n "$identity" ]; then
    codesign --force --options runtime --timestamp --entitlements Support/Caffeguard.entitlements --sign "$identity" "$app"
else
    echo "No Developer ID certificate found; signing for this Mac only." >&2
    codesign --force --options runtime --entitlements Support/Caffeguard.entitlements --sign - "$app"
fi
echo "$app"
