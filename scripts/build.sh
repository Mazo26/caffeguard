#!/bin/sh
# Builds a universal (Apple silicon + Intel) build/Caffeguard.app.
set -eu
cd "$(dirname "$0")/.."

swift build -c release --arch arm64 --arch x86_64
app=build/Caffeguard.app
rm -rf "$app"
mkdir -p "$app/Contents/MacOS"
cp "$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/Caffeguard" "$app/Contents/MacOS/"
cp Support/Info.plist "$app/Contents/"
# shortcut: ad-hoc signature, so other Macs must approve it once in Privacy & Security;
# a Developer ID signature plus notarization would remove that step.
codesign --force --sign - "$app"
echo "$app"
