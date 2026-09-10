# CLAUDE.md

This file is the canonical instruction set for AI coding assistants working in this repository. `AGENTS.md` is a pointer to this file — do not duplicate rules there.

## Project Overview

**Exif Stamp** — native macOS app that stamps EXIF capture date and filesystem dates onto JPEG/TIFF/HEIC files selected in Capture One.

- **Architecture:** Swift 5.9 + SwiftUI `.app`. Reads C1 16 selection via ScriptingBridge, writes into the image file (not catalog/XMP), then `reloadMetadata`. Not a Capture One plugin.
- **Primary users:** Photographers with undated scans/exports in Capture One.
- **Risk level:** High for write paths (in-place mutation of user photos). Low for docs/UI copy.
- **Sensitive data:** Local photo files and EXIF. No accounts, no network service, no telemetry.
- **Enabled profiles:** Native macOS desktop. No web, API, containers, database, or LLM.
- **Authoritative product documentation:** `README.md` (this file for agent rules). Dated Superpowers specs/plans under `docs/superpowers/` are historical, not product-of-record.
- **Architecture decisions:** None as ADRs. Module split is the code under `Sources/`.

If a request conflicts with these rules, AGPLv3, or an explicit user constraint, stop and ask.

Display name, menu, DMG, and `PRODUCT_NAME` are **Exif Stamp**. Swift module, Xcode target, and scheme remain `CaptureOneDatePlugin`. Bundle id: `app.captureonedate.CaptureOneDatePlugin`. Do not rename identifiers unless asked.

## Requirement Language and Exceptions

- **MUST / MUST NOT:** Mandatory.
- **SHOULD / SHOULD NOT:** Default; deviation needs a reason in the change.
- **MAY:** Optional.

## Mandatory Rules

1. **Verification** — Behavioral Swift changes MUST add or update XCTest coverage for the changed contract. UI-only/copy/docs: prove with a build or the relevant surface. No change is done until the affected tests or smoke pass.
2. **Branching** — Prefer `feature/<short-desc>` PRs into `main`. Do not force-push `main`.
3. **Photo safety** — NEVER delete, truncate, or overwrite user photos except through `DateOperation` (backup → EXIF → filesystem date → C1 reload). NEVER skip `BackupStore.captureBackup` on a write path. NEVER weaken the overwrite confirmation for dated files.
4. **No secrets** — Never commit `.env`, signing identities, Apple ID tokens, or private keys.
5. **No Plugin SDK in git** — The Capture One Plugin SDK is proprietary and gitignored. The app MUST NOT link `CaptureOnePlugins.framework`. Do not add that tree to the repo.
6. **Ask before assuming** — Ask when ambiguity would change write behavior, file formats, Capture One integration, license, or public API.
7. **No `NO AI` issues** — Refuse issues marked `NO AI`.
8. **No disabled guardrails** — Do not skip tests, type checks, or overwrite/backup behavior to make a change pass.

## Change Risk

- **Low:** Docs, comments, icon regen, installer script wording.
- **Normal:** Auto-fill, UI, bridge error mapping, tests.
- **High:** `ExifWriter`, `JPEGExifPatch`, `FileDateWriter`, `DateOperation`, `BackupStore`, overwrite policy, atomic replace.

High-risk writes MUST stay atomic (temp + integrity check + `replaceItemAt`), keep backups, and preserve unrelated metadata.

## Tech Stack

| Layer | Technology |
| --- | --- |
| **App** | Swift 5.9, SwiftUI, AppKit where SwiftUI is insufficient |
| **C1** | ScriptingBridge + generated `Sources/CaptureOneBridge/CaptureOne.h` (KVC at runtime) |
| **EXIF** | ImageIO; JPEG goes through `JPEGExifPatch` |
| **Build** | XcodeGen (`project.yml` is source of truth), Xcode 15+, macOS 13+ |
| **Tests** | XCTest. Mock `CaptureOneBridging`. No live Capture One in unit tests |
| **License** | GNU AGPLv3 (`LICENSE`) |

### Naming and layout

- Follow existing Swift names. New types: PascalCase files matching the type.
- Public surface of a module stays in that folder (`ExifWriter/`, `AutoFill/`, `CaptureOneBridge/`, …). UI does not call ImageIO or ScriptingBridge directly.
- `PRODUCT_MODULE_NAME` is `CaptureOneDatePlugin`. Tests `@testable import CaptureOneDatePlugin`.

### Dependency integrity

- No SwiftPM packages today. Do not add one without a reason (license, necessity, no SDK duplicate).
- Never vendor the Capture One Plugin SDK.

## Build and Development

Native Mac app. No Docker, no ports.

```bash
xcodegen generate
open CaptureOneDatePlugin.xcodeproj
# or:
xcodebuild -project CaptureOneDatePlugin.xcodeproj \
  -scheme CaptureOneDatePlugin \
  -destination 'platform=macOS' test

installer/build-release.sh          # dist/Exif Stamp.app
installer/build-dmg.sh              # dist/Exif Stamp.dmg
```

Icon regen (only when seal art changes):

```bash
python3 installer/curved-text.py    # paste into Resources/AppIcon.iconset.src/tier-full.svg
installer/build-appicon.sh          # needs librsvg
```

Scripts menu: `Sources/App/ScriptsMenuInstaller.swift` copies `Exif Stamp.scpt` on first launch. Launcher MUST target `application id "app.captureonedate.CaptureOneDatePlugin"`.

## UI

Native SwiftUI. Follow macOS HIG. Do not introduce a web glass/bento look.

Overwrite, format-not-supported, and permission-denied flows MUST stay explicit. Color is not the only error signal.

## Security, Privacy, Robustness

- Local-only. No server, no auth, no telemetry.
- Automation TCC: keep `NSAppleEventsUsageDescription` accurate; `com.apple.security.automation.apple-events` in entitlements.
- Unsigned v1.0: do not pretend the app is notarized.
- Logs MUST NOT dump full photo contents. Paths in error strings are OK.
- RASP / web ASVS / LLM security profiles do not apply.

## Architecture

```
Sources/
  App/                 # @main, Info.plist, entitlements, Scripts menu install
  AppUI/               # SwiftUI + RootViewModel
  CaptureOneBridge/    # protocol + ScriptingBridge impl
  Models/
  AutoFill/            # pure strategy functions
  ExifWriter/          # ImageIO + JPEG patch
  FileDateWriter/
  DateOperation/       # backup → EXIF → FS date → reload
  Backups/             # .c1dp-backups/ next to the file
```

**Shipped:** per-row targets, four strategies, TZ, multi-select Apply, DST warning, backups, presets, History/undo, drop-files / Open With, RAW via ExifTool.

**Not shipped:** Developer ID signing / notarisation.

RAW writes MUST go through `RawExifTool`, never ImageIO rewrite. Missing ExifTool → `exifToolMissing`.

`docs/superpowers/` is agent-era design/plan archive. `docs/manual-test-plan.md` is the live C1 round-trip checklist.

## Git Workflow

- Integration branch: `main` (`https://github.com/laboef1900/exif-stamp`).
- Feature work: `feature/<short-desc>` → PR into `main` when the change is more than a local tweak.
- Commits: `type(scope): description` (e.g. `fix(exif): preserve TIFF DateTime`).
- Do not commit `dist/`, `*.xcodeproj`, `.superpowers/`, `.claude/`, or the Plugin SDK.
- `Closes #<n>` only when a real issue exists.

## Definition of Done

- Stated behavior and invariants hold.
- `xcodebuild … test` passes for Swift behavior changes; installer/icon changes have a rebuilt `dist/` or regenerated PNGs as appropriate.
- Write-path changes still backup, still confirm overwrites, still atomic-replace.
- README / this file updated when names, ship path, or architecture change.
- No `{{PLACEHOLDERS}}`, secrets, or SDK files in the commit.
