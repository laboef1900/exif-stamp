#!/bin/bash
# Packages dist/Exif Stamp.app into a drag-to-Applications DMG.
# Usage: installer/build-dmg.sh
set -euo pipefail

cd "$(dirname "$0")/.."

APP="dist/Exif Stamp.app"
DMG_PATH="dist/Exif Stamp.dmg"
VOL_NAME="Exif Stamp"
STAGE=dist/.dmg-stage

if [[ ! -d "$APP" ]]; then
    installer/build-release.sh >/dev/null
fi

rm -rf "$STAGE" "$DMG_PATH"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"

hdiutil create \
    -volname "$VOL_NAME" \
    -srcfolder "$STAGE" \
    -ov -format UDZO \
    "$DMG_PATH" >/dev/null

rm -rf "$STAGE"
echo "$DMG_PATH"
