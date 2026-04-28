# Manual Test Plan — Capture One Date Plugin

Run before tagging a release. Each item is one assertion.

## Setup
- Build via Xcode → Product → Archive (or Run for dev builds)
- Have Capture One 16+ open with a test catalog containing:
  - At least 5 JPEG files with no capture date
  - At least 2 JPEG files with an existing capture date
  - 1 TIFF file
  - 1 HEIC file
  - 1 file on an external drive
  - 1 RAW file (e.g., CR3 or NEF) — to verify graceful failure

## Empty state checks
- [ ] Quit Capture One. Launch the app. Expect "Capture One is not running" screen with Refresh button.
- [ ] Open Capture One but close the catalog. Refresh in the app. Expect "No catalog or session open".
- [ ] Open the catalog with no selection. Refresh. Expect "No photos selected".

## Permission flow
- [ ] On a fresh macOS user, first launch: expect macOS prompt "Capture One Date Plugin wants to control Capture One". Click OK.
- [ ] Toggle the permission off in System Settings → Privacy & Security → Automation. Refresh in the app. Expect "Automation permission denied" screen with deep-link button that opens the right settings pane.

## Happy path — undated only
- [ ] Select 5 undated JPEGs in Capture One. Refresh in the app.
- [ ] Verify the file list shows all 5 with "—" in the date column.
- [ ] Pick a date, click Apply. Expect Results sheet showing "5 succeeded · 0 failed".
- [ ] In Capture One, verify all 5 variants now show the new capture date.
- [ ] In Finder Get Info, verify Created and Modified dates match.
- [ ] In Preview → Tools → Show Inspector, verify EXIF capture date matches.

## Mixed selection — overwrite warning
- [ ] Select 3 undated + 2 dated JPEGs. Refresh.
- [ ] Click Apply. Expect overwrite sheet listing the 2 dated files with their current dates.
- [ ] Click "Skip those". Expect 3 succeeded, dated files untouched.
- [ ] Re-select the same 5. Apply again. Click "Overwrite all". Expect 5 succeeded, all now share the new date.

## Format coverage
- [ ] Select the TIFF file. Apply a date. Verify in Preview's EXIF inspector.
- [ ] Select the HEIC file. Apply. Verify in Preview's EXIF inspector.

## Failure modes
- [ ] Select the RAW file. Apply. Expect Results showing "Format not supported for writing" or "Could not read image".
- [ ] Eject the external drive without quitting C1 (so file is "offline"). Apply. Expect "File not found".
- [ ] Make a JPEG read-only with `chmod 444 file.jpg`. Select & apply. Expect "File not writable".

## Concurrency / scale
- [ ] Select 50 undated JPEGs. Apply. Expect all to succeed within a few seconds.

## Refresh button
- [ ] Apply to a selection. After Results "Done", change the C1 selection and observe that the file list reflects the new selection (the app calls loadSelection after Done).

## v1.1 Foundation manual tests

### Strategies

- [ ] **Same date** — pick a date, Apply to all, verify all selected rows have the new date.
- [ ] **From filename (built-in)** — select 5 files with names matching IMG_yyyymmdd_hhmmss; switch to From filename. Verify each row's Target column reflects the parsed date.
- [ ] **From filename (custom format)** — open Configure custom format. Type `Scan_yyyyMMdd_HHmmss_*`. Verify the preview rows show parsed dates for matching names.
- [ ] **Sequential** — pick start time + interval. Drag a row to reorder. Verify the row that was moved gets the date corresponding to its new visual index.
- [ ] **Shift by Δ** — select files with existing dates. Pick `+3600 sec`. Apply. Verify each file's date moved forward 1 hour.

### Manual edits

- [ ] Edit a Target cell directly; lock 🔒 appears.
- [ ] Switch strategy; locked rows keep their values; unlocked rows recompute.
- [ ] Click 🔒 to clear; row recomputes from active strategy.

### Per-row overrides

- [ ] Click ▸ on a row. Pick a row strategy override. Verify the row's Target reflects it; the rest reflect the default. The row shows a blue dot indicator.
- [ ] Per-row TZ override: pick a non-local TZ for one row. Apply. Verify in `exiftool -OffsetTimeOriginal` that this row's offset differs from the default.

### Multi-select Apply

- [ ] Select 3 of 7 rows. Apply → Apply to selected. Verify only those 3 files were written.

### TZ awareness

- [ ] Pick TZ Asia/Tokyo. Apply. Verify written EXIF: `DateTimeOriginal` is the wall-clock; `OffsetTimeOriginal` is `+09:00`.
- [ ] Pick TZ Europe/Berlin with a target in November. Apply. Verify `OffsetTimeOriginal` is `+01:00` (winter time).

### DST audit

- [ ] In Sequential mode, pick start = "March 30 2024 23:00 Europe/Berlin" and interval = 3600s, with 5 rows. Verify the inline DST warning appears.

### Apply guards

- [ ] All rows have target == current → Apply doesn't write any file (skip-existing path).
- [ ] Mixed: some rows match current, others differ. Apply prompts overwrite confirmation for differing rows; manually-edited rows skip the warning.
