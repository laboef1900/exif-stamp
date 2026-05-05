#!/usr/bin/env python3
"""
Generate per-character <text> elements positioned along a circular arc.
Used because rsvg-convert does not implement SVG textPath.
"""
import math
import sys

# Hard-coded for the Full tier seal stamp.
# Coordinate system: SVG (y-down), origin at seal centre after `translate(512 512)`.
# The seal is also rotated -6° in the SVG; we operate in the post-translate,
# pre-rotation local frame so the surrounding `rotate(-6)` carries us along.

R = 297                      # arc radius
FONT_SIZE = 46
LETTER_SPACING = 10
ADVANCE = FONT_SIZE * 0.6 + LETTER_SPACING   # Menlo char advance + tracking
TEXT = "CAPTURE · ONE · DATE · PLUGIN ·"
START_OFFSET = 0.06 * (2 * math.pi * R)      # 6% around the circle

elements = []
s = START_OFFSET + ADVANCE / 2               # centre of first glyph
for ch in TEXT:
    alpha = math.pi + s / R
    x = R * math.cos(alpha)
    y = R * math.sin(alpha)
    rot = math.degrees(math.atan2(R * math.cos(alpha), -R * math.sin(alpha)))
    # XML-escape the character (only space-like whitespace and middot are non-ASCII;
    # we don't have <, >, &, ' or " in TEXT so this is safe).
    elements.append(
        f'      <text x="{x:.2f}" y="{y:.2f}" '
        f'transform="rotate({rot:.2f} {x:.2f} {y:.2f})" '
        f'font-family="Menlo, ui-monospace, monospace" font-size="{FONT_SIZE}" '
        f'font-weight="700" fill="#E85A3A" text-anchor="middle" '
        f'dominant-baseline="middle">{ch}</text>'
    )
    s += ADVANCE

print("\n".join(elements))
