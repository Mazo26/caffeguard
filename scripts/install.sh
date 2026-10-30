#!/bin/sh
# Builds Caffeguard, replaces /Applications/Caffeguard.app and opens it.
set -eu
cd "$(dirname "$0")/.."

scripts/build.sh
pkill -x Caffeguard || true
rm -rf /Applications/Caffeguard.app
cp -R build/Caffeguard.app /Applications/
open /Applications/Caffeguard.app
