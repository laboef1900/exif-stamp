#!/usr/bin/env bash
#
# Rasterises the four tier source SVGs into the ten PNGs that make up the
# macOS AppIcon asset catalog. Idempotent — overwrites existing PNGs.
#
# Requires `rsvg-convert` (install via `brew install librsvg`).
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/Resources/AppIcon.iconset.src"
OUT="$ROOT/Resources/Assets.xcassets/AppIcon.appiconset"

if ! command -v rsvg-convert >/dev/null 2>&1; then
  echo "error: rsvg-convert not found. Install with: brew install librsvg" >&2
  exit 1
fi

mkdir -p "$OUT"

# pixel_size:source_basename:filename
specs=(
  "16:tier-tiny:icon_16x16.png"
  "32:tier-small:icon_16x16@2x.png"
  "32:tier-small:icon_32x32.png"
  "64:tier-mid:icon_32x32@2x.png"
  "128:tier-mid:icon_128x128.png"
  "256:tier-full:icon_128x128@2x.png"
  "256:tier-full:icon_256x256.png"
  "512:tier-full:icon_256x256@2x.png"
  "512:tier-full:icon_512x512.png"
  "1024:tier-full:icon_512x512@2x.png"
)

for spec in "${specs[@]}"; do
  IFS=':' read -r size tier filename <<<"$spec"
  echo "  → $filename (${size}px from ${tier}.svg)"
  rsvg-convert \
    --width="$size" \
    --height="$size" \
    --keep-aspect-ratio \
    --background-color=none \
    --output="$OUT/$filename" \
    "$SRC/$tier.svg"
done

echo "done — $(ls -1 "$OUT"/*.png | wc -l | tr -d ' ') PNGs in $OUT"
