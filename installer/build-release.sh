#!/bin/bash
# Builds a Release configuration .app and copies it to dist/.
# Usage: installer/build-release.sh
set -euo pipefail

cd "$(dirname "$0")/.."

xcodegen generate >/dev/null

xcodebuild \
    -project CaptureOneDatePlugin.xcodeproj \
    -scheme CaptureOneDatePlugin \
    -destination 'platform=macOS' \
    -configuration Release \
    build \
    >/tmp/c1dp-release-build.log 2>&1 || {
        echo "Build failed. Tail of log:" >&2
        tail -40 /tmp/c1dp-release-build.log >&2
        exit 1
    }

BUILT=$(find ~/Library/Developer/Xcode/DerivedData -path '*Release/Exif Stamp.app' -type d 2>/dev/null \
        | grep -v 'Index.noindex' | head -1)
if [[ -z "$BUILT" || ! -d "$BUILT" ]]; then
    echo "Could not find built .app under DerivedData" >&2
    exit 1
fi

mkdir -p dist
rm -rf "dist/Exif Stamp.app"
cp -R "$BUILT" "dist/Exif Stamp.app"

IDENTITY_HASH=$(installer/ensure-codesign-identity.sh)
KEYCHAIN="$HOME/Library/Keychains/exif-stamp-codesign.keychain-db"
security unlock-keychain -p "exif-stamp-codesign" "$KEYCHAIN"
codesign --force --options runtime --timestamp=none \
    --entitlements Sources/App/CaptureOneDatePlugin.entitlements \
    --keychain "$KEYCHAIN" \
    --sign "$IDENTITY_HASH" \
    "dist/Exif Stamp.app"
codesign --verify --verbose=2 "dist/Exif Stamp.app" >/tmp/c1dp-codesign.log 2>&1

echo "dist/Exif Stamp.app"
