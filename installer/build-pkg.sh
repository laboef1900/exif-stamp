#!/bin/bash
# Builds a one-click .pkg installer that:
#   1. Installs CaptureOneDatePlugin.app to /Applications
#   2. Runs postinstall.sh to copy the Scripts-menu launcher into the
#      installing user's ~/Library/Application Scripts/com.captureone.captureone16/
# Usage: installer/build-pkg.sh
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -d dist/CaptureOneDatePlugin.app ]]; then
    installer/build-release.sh >/dev/null
fi

PKG_PATH=dist/CaptureOneDatePlugin.pkg
ROOT=dist/.pkg-root
SCRIPTS=dist/.pkg-scripts

rm -rf "$ROOT" "$SCRIPTS" "$PKG_PATH"
mkdir -p "$ROOT/Applications" "$SCRIPTS"
cp -R dist/CaptureOneDatePlugin.app "$ROOT/Applications/"

cp installer/postinstall.sh "$SCRIPTS/postinstall"
chmod +x "$SCRIPTS/postinstall"

VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' \
            "dist/CaptureOneDatePlugin.app/Contents/Info.plist")

pkgbuild \
    --root "$ROOT" \
    --identifier app.captureonedate.CaptureOneDatePlugin \
    --version "$VERSION" \
    --install-location / \
    --scripts "$SCRIPTS" \
    "$PKG_PATH" >/dev/null

rm -rf "$ROOT" "$SCRIPTS"
echo "$PKG_PATH"
