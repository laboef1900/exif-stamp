# Capture One Date Plugin — Design

**Date:** 2026-04-28
**Status:** Approved (pending user spec review)

## Problem

Capture One can adjust the EXIF capture date on an image only when a date is already set. For images that have **no capture date at all** (scans, screenshots, exports stripped of metadata, older files), there is no built-in way to set one. The user has many such files.

## Goal

Provide a macOS desktop app that lets a user select photos in Capture One, enter a single date+time, and have that date written **into the file itself** (EXIF tags + filesystem date attributes), then have Capture One refresh its catalog so the new date appears.

## Constraints (from research)

- **Capture One Plugin SDK is not a fit.** It exposes only `IPublishPlugin`, `IEditingPlugin`, `IOpenWithPlugin`, and file-format hooks — none expose metadata-write APIs, none operate on the user's catalog selection, none can write back into source files. SDK plugins are native (Obj-C/Swift on macOS, C# on Windows), not JavaScript.
- **AppleScript path discarded** because Capture One's scripting writes dates into the catalog/XMP sidecar, not into the source file's EXIF. The user requires writes to the file.
- **Capture One's only programmatic surface is its scripting dictionary**, reachable from a native Swift app via the `ScriptingBridge` framework (Apple Events under the hood). This is acceptable per user direction ("internal scripts are fine").
- **File scope is JPEG / TIFF / HEIC** (no proprietary RAW). Apple's `ImageIO` framework writes EXIF natively for these formats. RAW writeback is out of scope.

## Solution

A standalone macOS `.app` bundle (Swift + SwiftUI, AppKit where needed). The app reads the current Capture One selection via `ScriptingBridge`, presents a date/time picker, writes EXIF + filesystem date to each selected file, then asks Capture One to reload metadata. v1.0 is unsigned/local; signing & notarisation deferred to v1.1.

## Architecture

**Form factor:** single macOS `.app` bundle.
**Language / UI:** Swift + SwiftUI, with AppKit (`NSDatePicker`) where SwiftUI primitives are insufficient.
**Build:** Xcode project.
**Min macOS:** 13 (Ventura) — modern Swift concurrency, stable `ScriptingBridge`.
**Min Capture One:** 16.x (current generation, scripting dictionary available).

### Module breakdown

| Module | Purpose | Key APIs |
|---|---|---|
| `CaptureOneBridge` | Read selected variants from running Capture One; send "reload metadata" command. Returns `[VariantInfo]` (path, current EXIF date, filename). Exposes a protocol for testability. | `ScriptingBridge` framework, generated bindings from C1's `.sdef` |
| `ExifWriter` | Read current capture date from a file; write `DateTimeOriginal`, `CreateDate`, `ModifyDate`; preserve all other metadata and image bytes. Pure function over file path. | `ImageIO` (`CGImageSource`, `CGImageDestination`, `CGImageMetadata`) |
| `FileDateWriter` | Set filesystem `creationDate` and `modificationDate` to match. | `FileManager.setAttributes` |
| `DateOperation` | Orchestrates a batch run: takes `[VariantInfo]` + target date, returns per-file `Result<Void, Error>`. Handles overwrite-warning preview/execute split. | Composes the three modules above |
| `AppUI` | SwiftUI views: file list, date picker, overwrite warning sheet, results view. | SwiftUI + AppKit |

**Why this split:** `ExifWriter` and `FileDateWriter` are pure functions of a file path — easy to unit-test against fixture images with no Capture One running. `CaptureOneBridge` is the only module that touches Apple Events, isolated behind a protocol so the rest of the app works without C1. `DateOperation` is the integration point and the only thing the UI calls.

### Repo layout

```
capture-one-date-plugin/
├── CaptureOneDatePlugin.xcodeproj
├── Sources/
│   ├── CaptureOneBridge/
│   ├── ExifWriter/
│   ├── FileDateWriter/
│   ├── DateOperation/
│   └── AppUI/
├── Tests/
│   ├── ExifWriterTests/        (fixture JPEG / TIFF / HEIC)
│   ├── FileDateWriterTests/
│   └── DateOperationTests/     (mocked CaptureOneBridge)
├── docs/
│   ├── superpowers/specs/
│   └── manual-test-plan.md
└── README.md
```

## Workflow & UX

```
1. App launches → CaptureOneBridge.readSelection()
     ↓
   Returns [VariantInfo] = { filePath, filename, currentExifDate? }
   (currentExifDate read directly from file via ImageIO — ground truth, not C1's catalog)
     ↓
2. UI renders:
     • File list (filename · current date or "—")
     • Native NSDatePicker (date + time, defaults to now)
     • Counter: "8 of 12 files have no date"
     • [Apply] button
     ↓
3. User picks date → Apply
     ↓
4. DateOperation.preview() splits selection:
     • filesWithoutDate         → write directly
     • filesWithExistingDate    → trigger overwrite sheet
     ↓
5. Overwrite sheet (only if any existing dates):
     "3 files already have a capture date:
        IMG_001.jpg  (2019-03-15 14:22)
        ..."
     [Skip those] [Overwrite all] [Cancel]
     ↓
6. DateOperation.execute() per file:
     a. ExifWriter.write(path, date)  — atomic temp-file + replace
     b. FileDateWriter.setFsDate(path, date)
     c. Record Result<Void, Error>
     ↓
7. CaptureOneBridge.reloadMetadata(paths)
     ↓
8. Results view: "10 succeeded · 2 failed ▸"
```

### UX details

- **Empty states.** C1 not running → "Open Capture One and select photos to get started." Running but selection empty → "No photos selected in Capture One."
- **Permission gate.** First run prompts for Automation permission (talk to Capture One). On denial, inline help links to System Settings → Privacy & Security → Automation.
- **Default date.** Picker defaults to *now*. Helpful, not magical — user always sets it explicitly.
- **Refresh button** in toolbar: re-reads selection from C1 without restarting the app, so the user can adjust the C1 selection and re-pull.
- **In-place modification disclosure.** App shows a one-line warning above the Apply button: *"This modifies files in place. Back up first."*

## Error handling

| Category | Behaviour |
|---|---|
| C1 not running / no document / empty selection | Friendly empty state, no error toast |
| Automation permission denied | Inline help with deep-link to System Settings → Privacy → Automation |
| File offline (referenced but missing) | Per-file error in results: "File not found" |
| Read-only volume / permission denied | Per-file error: "File not writable" |
| ImageIO can't read source (corrupt) | Per-file error: "Could not read image" |
| ImageIO supports read but not write (e.g., RAW slipped in) | Per-file error: "Format not supported for writing — exclude RAW files" |
| Disk full during temp write | Per-file error, no partial state (atomic replace not committed) |

### Atomicity

EXIF write goes through a temp file in the same directory + atomic `FileManager.replaceItem`. Filesystem-date set happens after EXIF write. If filesystem-date set fails post-EXIF-success, that is a soft failure: log it, count as partial success, EXIF is still correct.

### Crash mid-batch

Processed files are done; unprocessed are untouched. No transactional batch. The in-place-modification disclosure makes this expectation explicit.

### No undo in v1

Stated in UI and README. The app makes no `.bak` copies in v1 (would double disk usage and complicate the flow). Users are directed to back up first.

## Edge cases

- **Duplicate paths in selection** (multiple variants of one source file) → dedupe before writing.
- **Time zone.** EXIF `DateTimeOriginal` is naive local time; we write the picker value as-is (camera convention). No timezone offset tag written in v1.
- **Existing XMP sidecar** → left untouched; we only modify embedded EXIF in the image file.
- **Date before 1970 or far future** → allowed without warning.

## Testing

**Unit tests (XCTest)** — fast, no Capture One required:

- `ExifWriter`: fixture files in `Tests/ExifWriter/Fixtures/` (JPEG with date, JPEG without, TIFF, HEIC, read-only fixture, corrupt fixture) → write → read back → assert
- `FileDateWriter`: write & read back creation/modification dates; verify both set
- `DateOperation`: protocol-based `CaptureOneBridge` mock; verifies the preview/execute split, overwrite logic, error aggregation, dedup of duplicate paths

**Integration tests** (run manually before each release; CI skips):

- Real Capture One round-trip: undated JPEG in catalog → run app, set a date → assert C1 catalog reflects new date after metadata reload
- Cross-tool verification: write date via app → read with `exiftool` (developer-side dev dependency, not bundled) → assert tag values match

**Manual test checklist** lives at `docs/manual-test-plan.md`. Items:

- Fresh install on macOS; first-run Automation permission flow
- Selections of 1 / 5 / 50 photos
- Mix of dated and undated files
- File on external / network drive
- Each empty/error state above
- Verify the resulting date renders correctly in C1 catalog, Finder, and Preview

## Out of scope (explicit YAGNI)

- Undo
- Batch interpolation (sequential dates, fill-between-neighbours)
- Date inferred from filename
- Proprietary RAW writeback (CR2/CR3/NEF/ARW/RAF/etc.)
- Windows
- Code signing / notarisation in v1.0 (local unsigned build first; signing in v1.1)
- Bundled ExifTool (revisit only if RAW support is later required)

## Open questions for the planner

1. **Capture One scripting dictionary inspection.** Confirm the exact `ScriptingBridge` API surface for selection enumeration (`every variant whose selected is true`), the `parent image → file path` traversal, and the metadata-reload command. Generate Swift bindings from the installed C1's `.sdef` as the first plan step.
2. **Automation permission UX.** Confirm the entitlement / `Info.plist` keys required for the app to talk to Capture One (`com.apple.security.automation.apple-events` plus `NSAppleEventsUsageDescription`).
3. **`ImageIO` HEIC write support.** Verify `CGImageDestination` writes EXIF cleanly into HEIC on the supported macOS range (13+). JPEG/TIFF are well-supported; HEIC needs a fixture-driven sanity check during early implementation.
4. **Atomic replace and macOS sandbox.** If the app is sandboxed (signed Mac App Store path), `FileManager.replaceItem` may need user-selected file scope. v1.0 is non-sandboxed local build, but plan should note this if signing is added.
