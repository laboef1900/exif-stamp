#!/bin/bash
# Packages dist/CaptureOneDatePlugin.app into a drag-to-Applications DMG.
# Usage: installer/build-dmg.sh
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -d dist/CaptureOneDatePlugin.app ]]; then
    installer/build-release.sh >/dev/null
fi

VOL_NAME="Exif Stamp"
DMG_PATH=dist/CaptureOneDatePlugin.dmg
STAGE=dist/.dmg-stage

rm -rf "$STAGE" "$DMG_PATH"
mkdir -p "$STAGE"
cp -R dist/CaptureOneDatePlugin.app "$STAGE/"
ln -s /Applications "$STAGE/Applications"

hdiutil create \
    -volname "$VOL_NAME" \
    -srcfolder "$STAGE" \
    -ov -format UDZO \
    "$DMG_PATH" >/dev/null

rm -rf "$STAGE"
echo "$DMG_PATH"
