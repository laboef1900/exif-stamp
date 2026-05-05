# App Icon Design

Date: 2026-05-05
Status: Approved (brainstorming complete, awaiting plan)

## Goal

Replace the default macOS app icon with a custom mark that reads as a date-stamping tool for photographers. The icon must be legible from 1024 px down to 16 px.

## Concept

A circular ink-stamp mark — the "EXIF date stamp" — sitting on a dark photographic backdrop. The stamp reads as something an archivist applies to images, which is literally what the app does: it writes EXIF capture dates onto undated photos.

## Visual specification

### Palette (locked)

| Token             | Hex       | Usage                                       |
|-------------------|-----------|---------------------------------------------|
| `bg-top`          | `#2A2A2C` | Background gradient top                     |
| `bg-bottom`       | `#0E0E10` | Background gradient bottom (vertical)       |
| `ink-light`       | `#EE6A4A` | Stamp ink — top of vertical gradient        |
| `ink-dark`        | `#D2492C` | Stamp ink — bottom of vertical gradient     |
| `ink-flat`        | `#E85A3A` | Solid ink (used in mid/small/tiny tiers)    |
| `mountain`        | `#FAFAFA` | Faint photo silhouette behind seal, 18% α   |

### Composition

- **Canvas:** 1024 × 1024 px, rounded rect (squircle approximation, `rx ≈ 22.4%`).
- **Background:** vertical gradient (`bg-top` → `bg-bottom`).
- **Photo silhouette:** simple mountain-range polygon across the lower half, 18 % opacity white, evokes "a photo" without committing to one.
- **Seal:** centered, rotated −6°. Two concentric rings (outer ø ≈ 62 % canvas, inner ø ≈ 52 %).
- **Inner content varies by size tier** (see below).

### Size tiers

| Tier      | Sizes (px)        | Contents                                                                 |
|-----------|-------------------|--------------------------------------------------------------------------|
| Full      | 1024, 512, 256    | Curved outer text "CAPTURE · ONE · DATE · PLUGIN ·", "EXIF", divider, "2026·05·05", both rings. Stamp ink uses vertical gradient. |
| Mid       | 128, 64           | Curved outer text removed. "EXIF" and date scaled up. Strokes thickened. |
| Small     | 32                | Date removed. Just the seal rings + "EXIF". Strokes thickened further so rings survive. |
| Tiny      | 16                | Pure silhouette glyph: outer ring + filled red disc + dark horizontal bar. No type. Recognisable as a stamp. |

The tier breaks were chosen by visual judgement at real pixel size — the curved text disintegrates below ≈ 256, the date disintegrates below ≈ 64, "EXIF" disintegrates below ≈ 32.

### Typography

- All type uses `ui-monospace` (system mono). The exact face does not matter because the icon is rasterised — what matters is that the source SVG renders consistently in the tool we use for export. SF Mono / Menlo / Roboto Mono all produce nearly identical results at these weights.
- Weights: 700 for curved text and date, 800 for "EXIF".
- Letter-spacing: 1–2 px depending on element.

### Date string

The date "2026·05·05" appears only in the Full and Mid tiers. It is decorative — it does *not* represent the user's selected date and is not updated at runtime. The date is fixed at the icon's "birthday" (today, 2026-05-05).

## Asset deliverables

Create `Resources/Assets.xcassets/AppIcon.appiconset/` containing PNGs at the ten standard macOS app-icon sizes. Tier assignment is by **hardware pixel size**, not logical-size convention — this means `@1x` and `@2x` representations of the same logical size sometimes use different source artwork. That deviates from the strict "same art at 2× resolution" convention, but the legibility win at small sizes is the whole point of having tiers.

| Filename             | Hardware px | Tier  | Source SVG    |
|----------------------|------------:|-------|---------------|
| `icon_16x16.png`     |  16 × 16    | Tiny  | `tier-tiny`   |
| `icon_16x16@2x.png`  |  32 × 32    | Small | `tier-small`  |
| `icon_32x32.png`     |  32 × 32    | Small | `tier-small`  |
| `icon_32x32@2x.png`  |  64 × 64    | Mid   | `tier-mid`    |
| `icon_128x128.png`   | 128 × 128   | Mid   | `tier-mid`    |
| `icon_128x128@2x.png`| 256 × 256   | Full  | `tier-full`   |
| `icon_256x256.png`   | 256 × 256   | Full  | `tier-full`   |
| `icon_256x256@2x.png`| 512 × 512   | Full  | `tier-full`   |
| `icon_512x512.png`   | 512 × 512   | Full  | `tier-full`   |
| `icon_512x512@2x.png`| 1024 × 1024 | Full  | `tier-full`   |

Source SVGs (one per tier — `tier-full.svg`, `tier-mid.svg`, `tier-small.svg`, `tier-tiny.svg`) live in `Resources/AppIcon.iconset.src/` so the icon can be regenerated.

## Integration

The project currently has no `Assets.xcassets`. Two paths:

1. **Asset catalog (preferred).** Create `Resources/Assets.xcassets/AppIcon.appiconset/` with `Contents.json` mapping the PNGs above. Add to `project.yml` under `targets.CaptureOneDatePlugin.sources` and set `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` in build settings. Re-run `xcodegen generate`.
2. **Loose `.icns`.** Compile a single `AppIcon.icns` with `iconutil` and reference it via `CFBundleIconFile` in `Info.plist`.

Path 1 is the modern, recommended approach and is what we'll use.

## Generation pipeline

The four source SVGs are converted to PNGs by a small shell script (`installer/build-appicon.sh`) using one of:

- `rsvg-convert` (preferred — high-quality, deterministic, available via `brew install librsvg`)
- `qlmanage` (fallback — bundled with macOS but lower quality)

The script picks the right source SVG per output size based on the tier table above. It is idempotent and committed alongside the SVGs so the icon can be rebuilt in CI or by another developer.

## Out of scope

- Animated / "Liquid Glass" treatments for newer macOS versions.
- A separate dark-mode icon (the icon is already dark-mode-friendly).
- Marketing artwork, screenshots, README hero image.
- Updating the date string at runtime to match the user's selection.

## Testing / verification

Visual only — no unit tests for an icon. After integration:

1. Build the app, launch it, verify the Dock icon shows the new mark.
2. In Finder, view `CaptureOneDatePlugin.app` at icon-list, list, and gallery view sizes — confirm each tier renders cleanly and the right tier is picked at each size.
3. Inspect the built `.app/Contents/Resources/AppIcon.icns` with Preview to confirm all 10 representations are present.
4. Update the manual test plan to include "icon renders correctly in Dock and Finder".

## References

- macOS App Icon HIG: https://developer.apple.com/design/human-interface-guidelines/app-icons
- iconset filename conventions: `man iconutil`
