#!/bin/bash
# Postinstall script for the .pkg installer.
# Copies the Capture One Scripts-menu launcher into the installing user's
# Library so it appears in Capture One's Scripts menu.
#
# Apple sets $HOME and $USER to the installing user's identity when the
# pkg is run via Installer.app, even though the script itself runs as root.

set -e

SRC="/Applications/CaptureOneDatePlugin.app/Contents/Resources/Exif Stamp.scpt"
DEST_DIR="$HOME/Library/Scripts/Capture One Scripts"

mkdir -p "$DEST_DIR"
cp "$SRC" "$DEST_DIR/"
chown "$USER" "$DEST_DIR/Exif Stamp.scpt" || true
rm -f "$DEST_DIR/Launch Capture One Date Plugin.scpt"

exit 0
