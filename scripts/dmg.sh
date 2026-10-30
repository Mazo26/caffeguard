#!/bin/sh
# Builds build/Caffeguard-<version>.dmg: the app plus an Applications shortcut to drag it onto.
set -eu
cd "$(dirname "$0")/.."

scripts/build.sh
version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Support/Info.plist)
stage=build/dmg
dmg=build/Caffeguard-$version.dmg
rm -rf "$stage" "$dmg"
mkdir -p "$stage"
cp -R build/Caffeguard.app "$stage/"
ln -s /Applications "$stage/Applications"
hdiutil create -volname Caffeguard -srcfolder "$stage" -format UDZO -quiet "$dmg"
rm -rf "$stage"
echo "$dmg"
