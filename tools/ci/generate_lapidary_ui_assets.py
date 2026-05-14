from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "ui" / "lapidary"

SIZES = {
    "register_slab_large.png": (1024, 512),
    "register_tablet.png": (448, 360),
    "button_tablet_states.png": (512, 192),
    "button_tablet_normal.png": (512, 64),
    "button_tablet_hover.png": (512, 64),
    "button_tablet_pressed.png": (512, 64),
    "button_tablet_disabled.png": (512, 64),
    "title_plaque.png": (640, 128),
    "pressure_groove.png": (768, 96),
}


def _rgba(hex_value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    hex_value = hex_value.lstrip("#")
    return (
        int(hex_value[0:2], 16),
        int(hex_value[2:4], 16),
        int(hex_value[4:6], 16),
        alpha,
    )


STONE = _rgba("#15130f")
STONE_LIGHT = _rgba("#2b261d")
STONE_DARK = _rgba("#080705")
BRONZE = _rgba("#8a683c")
BRONZE_DARK = _rgba("#3f2d19")
GROOVE = _rgba("#050403")


def _noise_layer(size: tuple[int, int], opacity: int, seed: int) -> Image.Image:
    rng = random.Random(seed)
    w, h = size
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            v = rng.randint(-20, 20)
            base = 128 + v
            px[x, y] = (base, base, base, opacity)
    return img.filter(ImageFilter.GaussianBlur(0.6))


def _carved_rect(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=radius, fill=STONE, outline=BRONZE_DARK, width=4)
    draw.rounded_rectangle((x1 + 5, y1 + 5, x2 - 5, y2 - 5), radius=max(1, radius - 4), outline=BRONZE, width=2)
    draw.rounded_rectangle((x1 + 15, y1 + 15, x2 - 15, y2 - 15), radius=max(1, radius - 8), outline=(255, 210, 130, 34), width=1)
    draw.line((x1 + 10, y2 - 12, x2 - 10, y2 - 12), fill=(0, 0, 0, 90), width=2)
    draw.line((x1 + 10, y1 + 10, x2 - 10, y1 + 10), fill=(255, 220, 150, 36), width=1)


def _stone_base(size: tuple[int, int], seed: int) -> Image.Image:
    img = Image.new("RGBA", size, STONE)
    img.alpha_composite(_noise_layer(size, 22, seed))
    draw = ImageDraw.Draw(img, "RGBA")
    w, h = size
    for i in range(22):
        x = int((i * 53 + seed * 19) % w)
        y = int((i * 31 + seed * 13) % h)
        ln = 20 + ((i * 17) % 90)
        draw.line((x, y, min(w, x + ln), y + int(math.sin(i) * 5)), fill=(255, 230, 170, 18), width=1)
    return img


def register_slab_large(path: Path) -> None:
    img = Image.new("RGBA", SIZES[path.name], (0, 0, 0, 0))
    shadow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow, "RGBA")
    sd.rounded_rectangle((34, 36, 998, 490), radius=16, fill=(0, 0, 0, 130))
    shadow = shadow.filter(ImageFilter.GaussianBlur(10))
    img.alpha_composite(shadow)
    slab = _stone_base((960, 448), 11)
    sd = ImageDraw.Draw(slab, "RGBA")
    _carved_rect(sd, (0, 0, 959, 447), 16)
    _carved_rect(sd, (42, 66, 448, 348), 10)
    _carved_rect(sd, (512, 66, 918, 348), 10)
    sd.rectangle((488, 42, 496, 386), fill=(0, 0, 0, 92))
    sd.rectangle((498, 42, 502, 386), fill=(160, 124, 72, 90))
    sd.rounded_rectangle((142, 382, 818, 410), radius=5, fill=GROOVE, outline=BRONZE_DARK, width=2)
    img.alpha_composite(slab, (32, 24))
    img.save(path)


def register_tablet(path: Path) -> None:
    img = Image.new("RGBA", SIZES[path.name], (0, 0, 0, 0))
    tablet = _stone_base((416, 328), 23)
    draw = ImageDraw.Draw(tablet, "RGBA")
    _carved_rect(draw, (0, 0, 415, 327), 12)
    for y in (78, 140, 202, 264):
        draw.line((44, y, 372, y), fill=(255, 220, 150, 22), width=1)
    img.alpha_composite(tablet, (16, 16))
    img.save(path)


def button_tablet_states(path: Path) -> None:
    img = Image.new("RGBA", SIZES[path.name], (0, 0, 0, 0))
    labels = [
        (STONE, BRONZE_DARK, 0),
        (_rgba("#221a11"), BRONZE, 1),
        (_rgba("#0d0b08"), _rgba("#b48145"), 2),
    ]
    for row, (fill, outline, seed) in enumerate(labels):
        y = row * 64 + 6
        button = Image.new("RGBA", (488, 52), fill)
        button.alpha_composite(_noise_layer((488, 52), 18, 80 + seed))
        bd = ImageDraw.Draw(button, "RGBA")
        bd.rounded_rectangle((0, 0, 487, 51), radius=6, outline=outline, width=3)
        bd.rounded_rectangle((8, 8, 479, 43), radius=4, outline=(255, 220, 150, 28), width=1)
        if row == 2:
            bd.rectangle((8, 8, 479, 14), fill=(0, 0, 0, 40))
        img.alpha_composite(button, (12, y))
    img.save(path)


def _button_state(path: Path, fill: tuple[int, int, int, int], outline: tuple[int, int, int, int], seed: int, inset: bool = False) -> None:
    img = Image.new("RGBA", SIZES[path.name], (0, 0, 0, 0))
    button = Image.new("RGBA", (488, 52), fill)
    button.alpha_composite(_noise_layer((488, 52), 18, 120 + seed))
    bd = ImageDraw.Draw(button, "RGBA")
    bd.rounded_rectangle((0, 0, 487, 51), radius=6, outline=outline, width=3)
    bd.rounded_rectangle((8, 8, 479, 43), radius=4, outline=(255, 220, 150, 28), width=1)
    if inset:
        bd.rectangle((8, 8, 479, 15), fill=(0, 0, 0, 48))
    img.alpha_composite(button, (12, 6))
    img.save(path)


def button_tablet_normal(path: Path) -> None:
    _button_state(path, STONE, BRONZE_DARK, 1)


def button_tablet_hover(path: Path) -> None:
    _button_state(path, _rgba("#221a11"), BRONZE, 2)


def button_tablet_pressed(path: Path) -> None:
    _button_state(path, _rgba("#0d0b08"), _rgba("#b48145"), 3, True)


def button_tablet_disabled(path: Path) -> None:
    _button_state(path, _rgba("#0d0c0a", 165), _rgba("#3b3427", 170), 4)


def title_plaque(path: Path) -> None:
    img = Image.new("RGBA", SIZES[path.name], (0, 0, 0, 0))
    plaque = _stone_base((608, 88), 41)
    draw = ImageDraw.Draw(plaque, "RGBA")
    _carved_rect(draw, (0, 0, 607, 87), 10)
    draw.line((66, 44, 542, 44), fill=(255, 220, 150, 28), width=1)
    img.alpha_composite(plaque, (16, 20))
    img.save(path)


def pressure_groove(path: Path) -> None:
    img = Image.new("RGBA", SIZES[path.name], (0, 0, 0, 0))
    rail = _stone_base((736, 64), 52)
    draw = ImageDraw.Draw(rail, "RGBA")
    _carved_rect(draw, (0, 0, 735, 63), 8)
    draw.rounded_rectangle((40, 22, 696, 42), radius=4, fill=GROOVE, outline=BRONZE_DARK, width=2)
    draw.line((44, 23, 692, 23), fill=(255, 220, 150, 20), width=1)
    img.alpha_composite(rail, (16, 16))
    img.save(path)


GENERATORS = {
    "register_slab_large.png": register_slab_large,
    "register_tablet.png": register_tablet,
    "button_tablet_states.png": button_tablet_states,
    "button_tablet_normal.png": button_tablet_normal,
    "button_tablet_hover.png": button_tablet_hover,
    "button_tablet_pressed.png": button_tablet_pressed,
    "button_tablet_disabled.png": button_tablet_disabled,
    "title_plaque.png": title_plaque,
    "pressure_groove.png": pressure_groove,
}


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, generate in GENERATORS.items():
        generate(OUT / name)
        print(f"wrote {OUT / name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
