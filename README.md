# Capture One Date Plugin

Native macOS app that sets the EXIF capture date and filesystem date on photos
selected in Capture One that have no date set. v1.0 supports JPEG, TIFF, HEIC.

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

Three options, easiest first:

1. **`.pkg` installer** — `installer/build-pkg.sh` produces `dist/CaptureOneDatePlugin.pkg`. Double-click to install: drops the `.app` into `/Applications` and the Capture One Scripts-menu launcher into `~/Library/Application Scripts/com.captureone.captureone16/`.
2. **`.dmg`** — `installer/build-dmg.sh` produces `dist/CaptureOneDatePlugin.dmg`. Mount, drag the app to Applications. On first launch the app installs the Scripts-menu launcher into `~/Library/Application Scripts/com.captureone.captureone16/` automatically.
3. **From Xcode** — open the project, run the `CaptureOneDatePlugin` scheme. Useful for development.

Because v1.0 is unsigned, macOS Gatekeeper will warn on first launch. Right-click the `.app` → Open → confirm. Subsequent launches are unprompted.

## Use

1. Open Capture One and select photos that have no capture date.
2. Launch the app — either from the Dock/Spotlight, or from Capture One's **Scripts** menu (after installing via the `.pkg`). Approve the Automation permission prompt on first run.
3. Pick a date in the date picker.
4. Click Apply. Files with existing dates trigger a confirmation sheet.

The app modifies files in place. **Back up first.**

## Status

- v1.0: unsigned local build, JPEG/TIFF/HEIC, no undo, no RAW.
- v1.1 (planned): Developer ID code-signing and notarisation.

## Design

See `docs/superpowers/specs/2026-04-28-capture-one-date-plugin-design.md`.
