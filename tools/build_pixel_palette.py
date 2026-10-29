"""Build the closed palette for the pixel-art scene treatment.

Samples the unified backgrounds and the wax objects at the pixel grid
(640x360) and keeps 32 median-cut colours, written as a 32x1 strip that
assets/ui/official/ritual_aging.gdshader reads. Requires Pillow.

    python tools/build_pixel_palette.py
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCES = [
    "assets/ui/generated/arena_unified.png",
    "assets/ui/generated/crowd_unified.png",
    "assets/ui/generated/registry_counter_unified.png",
    "assets/ui/generated/portico_unified.png",
    "assets/ui/generated/verdict_owl_seal.png",
    "assets/ui/generated/judgment_seal.png",
]
GRID = (640, 360)
COLORS = 32
OUTPUT = ROOT / "assets/ui/official/pixel_palette.png"


def main() -> None:
    tiles = []
    for source in SOURCES:
        image = Image.open(ROOT / source).convert("RGBA")
        flat = Image.new("RGBA", image.size, (25, 25, 23, 255))
        flat.alpha_composite(image)
        tiles.append(flat.convert("RGB").resize(GRID, Image.BOX))
    sheet = Image.new("RGB", (GRID[0], GRID[1] * len(tiles)))
    for index, tile in enumerate(tiles):
        sheet.paste(tile, (0, GRID[1] * index))
    quantized = sheet.quantize(colors=COLORS, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    raw = quantized.getpalette()[: COLORS * 3]
    colours = sorted((tuple(raw[i : i + 3]) for i in range(0, len(raw), 3)), key=lambda c: 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2])
    strip = Image.new("RGB", (COLORS, 1))
    strip.putdata(colours)
    strip.save(OUTPUT)
    print(f"wrote {OUTPUT.relative_to(ROOT)} ({COLORS} colours)")


if __name__ == "__main__":
    main()
