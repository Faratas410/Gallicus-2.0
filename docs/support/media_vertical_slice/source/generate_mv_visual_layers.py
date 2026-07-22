"""Build deterministic 1920x1080 review layers from the selected MV02 direction."""

from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageOps


SLICE_DIR = Path(__file__).resolve().parents[1]
CONCEPT_DIR = SLICE_DIR / "concepts"
OUTPUT_DIR = SLICE_DIR / "selected_preview"
SIZE = (1920, 1080)


def _save(image: Image.Image, name: str) -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    image.save(OUTPUT_DIR / name, optimize=True)


def _light_overlay() -> Image.Image:
    width, height = SIZE
    image = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    pixels = image.load()
    center_x = width * 0.52
    center_y = height * 0.26
    radius_x = width * 0.42
    radius_y = height * 0.64
    for y in range(height):
        for x in range(width):
            distance = math.sqrt(((x - center_x) / radius_x) ** 2 + ((y - center_y) / radius_y) ** 2)
            strength = max(0.0, 1.0 - distance)
            alpha = int(68 * strength * strength)
            pixels[x, y] = (226, 197, 142, alpha)
    return image.filter(ImageFilter.GaussianBlur(radius=24))


def _fog_overlay() -> Image.Image:
    randomizer = random.Random(20_260_722)
    small_size = (240, 135)
    noise = Image.new("L", small_size)
    noise.putdata([randomizer.randrange(0, 256) for _ in range(small_size[0] * small_size[1])])
    noise = noise.resize(SIZE, Image.Resampling.BICUBIC).filter(ImageFilter.GaussianBlur(radius=38))
    mask = Image.new("L", SIZE, 0)
    mask_pixels = mask.load()
    noise_pixels = noise.load()
    for y in range(SIZE[1]):
        vertical = max(0.0, 1.0 - abs(y - SIZE[1] * 0.62) / (SIZE[1] * 0.36))
        for x in range(SIZE[0]):
            mask_pixels[x, y] = int(vertical * 42 * (noise_pixels[x, y] / 255.0))
    image = Image.new("RGBA", SIZE, (117, 128, 128, 0))
    image.putalpha(mask)
    return image


def _dust_overlay() -> Image.Image:
    randomizer = random.Random(46_205)
    image = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    for _ in range(190):
        x = randomizer.randrange(190, SIZE[0] - 190)
        y = randomizer.randrange(90, SIZE[1] - 120)
        radius = randomizer.choice((1, 1, 1, 2, 2, 3))
        alpha = randomizer.randrange(16, 62)
        color = (211, 190, 151, alpha)
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=color)
    return image.filter(ImageFilter.GaussianBlur(radius=0.45))


def _vignette_overlay() -> Image.Image:
    width, height = SIZE
    image = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    pixels = image.load()
    center_x = width / 2.0
    center_y = height / 2.0
    for y in range(height):
        for x in range(width):
            distance = math.sqrt(((x - center_x) / center_x) ** 2 + ((y - center_y) / center_y) ** 2)
            alpha = int(112 * max(0.0, min(1.0, (distance - 0.42) / 0.58)) ** 1.8)
            pixels[x, y] = (7, 8, 8, alpha)
    return image.filter(ImageFilter.GaussianBlur(radius=10))


def main() -> None:
    selected = Image.open(CONCEPT_DIR / "mv02_direction_a_threshold.png").convert("RGB")
    hero = ImageOps.fit(selected, SIZE, method=Image.Resampling.LANCZOS, centering=(0.5, 0.5))
    light = _light_overlay()
    fog = _fog_overlay()
    dust = _dust_overlay()
    vignette = _vignette_overlay()
    _save(hero, "mv02_selected_hero_1920x1080.png")
    _save(light, "mv02_light_overlay_1920x1080.png")
    _save(fog, "mv02_fog_overlay_1920x1080.png")
    _save(dust, "mv02_dust_overlay_1920x1080.png")
    _save(vignette, "mv02_vignette_overlay_1920x1080.png")
    composite = hero.convert("RGBA")
    for layer in (light, fog, dust, vignette):
        composite = Image.alpha_composite(composite, layer)
    _save(composite.convert("RGB"), "mv02_selected_composite_1920x1080.png")


if __name__ == "__main__":
    main()
