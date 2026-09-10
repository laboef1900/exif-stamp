#!/usr/bin/env python3
"""
Generate per-character <text> elements positioned along a full circle.
Used because rsvg-convert does not implement SVG textPath.
"""
import math

# Post-translate, pre-rotation local frame (seal centre at origin, y-down).
R = 292
FONT_SIZE = 40
TEXT = "EXIF·STAMP·EXIF·STAMP·EXIF·STAMP·EXIF·STAMP·"
FILL = "#F3E6D8"
ADVANCE = 2 * math.pi * R / len(TEXT)

elements = []
s = ADVANCE / 2
for ch in TEXT:
    alpha = math.pi + s / R
    x = R * math.cos(alpha)
    y = R * math.sin(alpha)
    rot = math.degrees(math.atan2(R * math.cos(alpha), -R * math.sin(alpha)))
    elements.append(
        f'      <text x="{x:.2f}" y="{y:.2f}" '
        f'transform="rotate({rot:.2f} {x:.2f} {y:.2f})" '
        f'font-family="Menlo, ui-monospace, monospace" font-size="{FONT_SIZE}" '
        f'font-weight="700" fill="{FILL}" text-anchor="middle" '
        f'dominant-baseline="middle">{ch}</text>'
    )
    s += ADVANCE

print("\n".join(elements))
