#!/bin/sh
# Builds build/Caffeguard-<version>.dmg: a drag-to-Applications window with a background.
# With a Developer ID certificate it is also signed, notarized and stapled.
set -eu
cd "$(dirname "$0")/.."
. scripts/lib.sh

scripts/build.sh
stage=build/dmg
draft=build/draft.dmg
dmg=build/Caffeguard-$version.dmg
rm -rf "$stage" "$draft" "$dmg"
mkdir -p "$stage/.background"
cp -R build/Caffeguard.app "$stage/"
ln -s /Applications "$stage/Applications"
cp Support/dmg-background.tiff "$stage/.background/background.tiff"

# Finder only remembers a window layout on a writable disk, so lay it out there, then compress.
hdiutil detach -quiet /Volumes/Caffeguard 2>/dev/null || true
hdiutil create -quiet -volname Caffeguard -srcfolder "$stage" -fs HFS+ -format UDRW "$draft"
device=$(hdiutil attach -readwrite -noverify -noautoopen "$draft" | awk '/Apple_HFS/ { print $1 }')
osascript <<'APPLESCRIPT'
tell application "Finder"
    tell disk "Caffeguard"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        -- 660 × 400 content, plus the title bar.
        set bounds of container window to {200, 120, 860, 548}
        set options to icon view options of container window
        set arrangement of options to not arranged
        set icon size of options to 128
        set text size of options to 13
        set background picture of options to file ".background:background.tiff"
        set position of item "Caffeguard.app" of container window to {180, 190}
        set position of item "Applications" of container window to {480, 190}
        update without registering applications
        delay 1
        close
    end tell
end tell
APPLESCRIPT
sync
hdiutil detach -quiet "$device"
hdiutil convert -quiet "$draft" -format UDZO -imagekey zlib-level=9 -o "$dmg"
rm -rf "$stage" "$draft"

if [ -n "$identity" ]; then
    codesign --sign "$identity" --timestamp "$dmg"
    xcrun notarytool submit "$dmg" --keychain-profile "$notary_profile" --wait
    xcrun stapler staple "$dmg"
fi
echo "$dmg"
