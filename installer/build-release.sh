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
echo "dist/Exif Stamp.app"
