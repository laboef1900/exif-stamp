# Exif Stamp

Native macOS app that stamps the EXIF capture date and filesystem date on photos
selected in Capture One. JPEG, TIFF, and HEIC.

## Why

Capture One can adjust an existing capture date but cannot set one when none
exists. This app fills that gap.

## Build

Requires Xcode 15+ and XcodeGen (`brew install xcodegen`).

```bash
xcodegen generate
open CaptureOneDatePlugin.xcodeproj
```

Run the `CaptureOneDatePlugin` scheme. Tests run via `Cmd+U` or:

```bash
xcodebuild -project CaptureOneDatePlugin.xcodeproj \
  -scheme CaptureOneDatePlugin \
  -destination 'platform=macOS' test
```

## Install

Two options, easiest first:

1. **`.dmg`** — `installer/build-dmg.sh` produces `dist/Exif Stamp.dmg`. Mount, drag the app to Applications. On first launch the app installs the Scripts-menu launcher automatically.
2. **From Xcode** — open the project, run the `CaptureOneDatePlugin` scheme. Useful for development.

Because v1.0 is unsigned, macOS Gatekeeper will warn on first launch. Right-click the `.app` → Open → confirm. Subsequent launches are unprompted.

## Use

1. Open Capture One and select photos that have no capture date.
2. Launch **Exif Stamp** — Dock/Spotlight, or Capture One's **Scripts** menu. Approve the Automation permission prompt on first run.
3. Pick a date in the date picker.
4. Click Apply. Files with existing dates trigger a confirmation sheet.

The app modifies files in place. **Back up first.**

## Status

- v1.1: per-row dates, strategies, TZ, presets, history/undo, drop-files, RAW via ExifTool (`brew install exiftool`).
- Unsigned local build. No notarisation.

## Design

See `docs/superpowers/specs/2026-04-28-capture-one-date-plugin-design.md`.

## License

Copyright (C) 2026 laboef1900

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

See [LICENSE](LICENSE) for the full terms.
