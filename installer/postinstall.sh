#!/bin/bash
# Postinstall script for the .pkg installer.
# Copies the Capture One Scripts-menu launcher into the installing user's
# Library so it appears in Capture One's Scripts menu.
#
# Apple sets $HOME and $USER to the installing user's identity when the
# pkg is run via Installer.app, even though the script itself runs as root.

set -e

SRC="/Applications/CaptureOneDatePlugin.app/Contents/Resources/Launch Capture One Date Plugin.scpt"
DEST_DIR="$HOME/Library/Application Scripts/com.captureone.captureone16"

mkdir -p "$DEST_DIR"
cp "$SRC" "$DEST_DIR/"
chown "$USER" "$DEST_DIR/Launch Capture One Date Plugin.scpt" || true

exit 0
