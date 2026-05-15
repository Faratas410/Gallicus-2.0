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


STONE = _rgba("#4b4538")
STONE_LIGHT = _rgba("#756b57")
STONE_DARK = _rgba("#29241d")
BRONZE = _rgba("#8b6a42")
BRONZE_DARK = _rgba("#4b3722")
GROOVE = _rgba("#1d1914")


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


def _jittered_edge_path(
    start: tuple[int, int],
    end: tuple[int, int],
    seed: int,
    steps: int,
    amplitude: int,
) -> list[tuple[int, int]]:
    rng = random.Random(seed)
    x1, y1 = start
    x2, y2 = end
    points: list[tuple[int, int]] = []
    horizontal = abs(x2 - x1) >= abs(y2 - y1)
    for i in range(steps + 1):
        t = i / max(1, steps)
        x = round(x1 + (x2 - x1) * t)
        y = round(y1 + (y2 - y1) * t)
        if i not in (0, steps):
            if horizontal:
                y += rng.randint(-amplitude, amplitude)
            else:
                x += rng.randint(-amplitude, amplitude)
        points.append((x, y))
    return points


def _roughen_outer_edge(
    img: Image.Image,
    box: tuple[int, int, int, int],
    seed: int,
    amplitude: int = 3,
    notches: int = 18,
) -> None:
    rng = random.Random(seed)
    draw = ImageDraw.Draw(img, "RGBA")
    x1, y1, x2, y2 = box
    top = _jittered_edge_path((x1, y1), (x2, y1), seed + 1, 28, amplitude)
    right = _jittered_edge_path((x2, y1), (x2, y2), seed + 2, 18, amplitude)
    bottom = _jittered_edge_path((x2, y2), (x1, y2), seed + 3, 28, amplitude)
    left = _jittered_edge_path((x1, y2), (x1, y1), seed + 4, 18, amplitude)
    for path in (top, right, bottom, left):
        draw.line(path, fill=(30, 26, 21, 255), width=2, joint="curve")
        draw.line([(x, y - 1) for x, y in path], fill=(128, 116, 92, 255), width=1)
    for _ in range(notches):
        side = rng.choice(("top", "right", "bottom", "left"))
        if side in ("top", "bottom"):
            x = rng.randint(x1 + 12, x2 - 12)
            y = y1 if side == "top" else y2
            notch = [(x, y), (x + rng.randint(4, 14), y + (rng.randint(3, 8) if side == "top" else -rng.randint(3, 8))), (x + rng.randint(12, 26), y)]
        else:
            x = x1 if side == "left" else x2
            y = rng.randint(y1 + 12, y2 - 12)
            notch = [(x, y), (x + (rng.randint(3, 8) if side == "left" else -rng.randint(3, 8)), y + rng.randint(4, 14)), (x, y + rng.randint(12, 26))]
        draw.polygon(notch, fill=(42, 36, 28, 255))
        draw.line(notch, fill=(126, 112, 86, 255), width=1)


def _carved_rect(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=radius, fill=None, outline=STONE_DARK, width=5)
    draw.rounded_rectangle((x1 + 5, y1 + 5, x2 - 5, y2 - 5), radius=max(1, radius - 4), outline=BRONZE_DARK, width=2)
    draw.rounded_rectangle((x1 + 12, y1 + 12, x2 - 12, y2 - 12), radius=max(1, radius - 8), outline=(136, 122, 92, 255), width=1)
    draw.line((x1 + 10, y2 - 12, x2 - 10, y2 - 12), fill=(22, 19, 15, 255), width=2)
    draw.line((x1 + 10, y1 + 10, x2 - 10, y1 + 10), fill=(148, 134, 104, 255), width=2)


def _stone_base(size: tuple[int, int], seed: int) -> Image.Image:
    rng = random.Random(seed)
    w, h = size
    img = Image.new("RGBA", size, STONE)
    px = img.load()
    for y in range(h):
        shade = int((y / max(1, h - 1)) * -22)
        for x in range(w):
            ripple = int(math.sin((x + seed) * 0.032) * 3)
            r = max(0, min(255, STONE[0] + shade + ripple))
            g = max(0, min(255, STONE[1] + shade + ripple))
            b = max(0, min(255, STONE[2] + shade + ripple))
            px[x, y] = (r, g, b, 255)
    img.alpha_composite(_noise_layer(size, 34, seed))
    draw = ImageDraw.Draw(img, "RGBA")
    for i in range(18):
        x = rng.randint(0, max(0, w - 12))
        y = rng.randint(0, max(0, h - 12))
        rx = rng.randint(20, 96)
        ry = rng.randint(8, 28)
        color = STONE_LIGHT if i % 3 != 0 else _rgba("#2f2a22")
        alpha = rng.randint(8, 18)
        draw.ellipse((x, y, min(w, x + rx), min(h, y + ry)), fill=(color[0], color[1], color[2], alpha))
    for i in range(14):
        x = rng.randint(0, w)
        y = rng.randint(0, h)
        ln = rng.randint(18, 120)
        lift = rng.randint(-8, 8)
        draw.line((x, y, min(w, x + ln), max(0, min(h, y + lift))), fill=(176, 160, 124, rng.randint(24, 42)), width=1)
        if i % 3 == 0:
            draw.line((x + 1, y + 2, min(w, x + ln + 1), max(0, min(h, y + lift + 2))), fill=(30, 26, 21, 36), width=1)
    for i in range(5):
        x = rng.randint(8, max(8, w - 8))
        y = rng.randint(8, max(8, h - 8))
        draw.polygon(
            [
                (x, y),
                (x + rng.randint(4, 16), y + rng.randint(-3, 6)),
                (x + rng.randint(1, 10), y + rng.randint(5, 16)),
            ],
            fill=(162, 146, 112, rng.randint(24, 42)),
        )
    for i in range(4):
        x = rng.randint(0, w)
        y = rng.randint(0, h)
        points = [(x, y)]
        for _ in range(rng.randint(2, 4)):
            x = max(0, min(w, x + rng.randint(20, 70)))
            y = max(0, min(h, y + rng.randint(-18, 18)))
            points.append((x, y))
        draw.line(points, fill=(28, 24, 19, rng.randint(28, 48)), width=1)
    opaque = Image.new("RGBA", size, STONE)
    opaque.alpha_composite(img)
    return opaque


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
    _roughen_outer_edge(slab, (2, 2, 957, 445), 301, 2, 10)
    _carved_rect(sd, (42, 66, 448, 348), 10)
    _roughen_outer_edge(slab, (43, 67, 447, 347), 302, 1, 4)
    _carved_rect(sd, (512, 66, 918, 348), 10)
    _roughen_outer_edge(slab, (513, 67, 917, 347), 303, 1, 4)
    sd.rectangle((488, 42, 496, 386), fill=(0, 0, 0, 92))
    sd.rectangle((498, 42, 502, 386), fill=(160, 124, 72, 90))
    sd.rounded_rectangle((142, 382, 818, 410), radius=5, fill=GROOVE, outline=STONE_DARK, width=2)
    img.alpha_composite(slab, (32, 24))
    img.save(path)


def register_tablet(path: Path) -> None:
    img = Image.new("RGBA", SIZES[path.name], (0, 0, 0, 0))
    tablet = _stone_base((416, 328), 23)
    draw = ImageDraw.Draw(tablet, "RGBA")
    _carved_rect(draw, (0, 0, 415, 327), 12)
    _roughen_outer_edge(tablet, (2, 2, 413, 325), 401, 2, 8)
    for y in (78, 140, 202, 264):
        draw.line((44, y, 372, y), fill=(255, 220, 150, 22), width=1)
    img.alpha_composite(tablet, (16, 16))
    img.save(path)


def button_tablet_states(path: Path) -> None:
    img = Image.new("RGBA", SIZES[path.name], (0, 0, 0, 0))
    labels = [
        (STONE, BRONZE_DARK, 0),
        (_rgba("#4b402e"), BRONZE, 1),
        (_rgba("#29231a"), _rgba("#b48145"), 2),
    ]
    for row, (fill, outline, seed) in enumerate(labels):
        y = row * 64 + 6
        button = _stone_base((488, 52), 80 + seed)
        button.alpha_composite(Image.new("RGBA", (488, 52), (fill[0], fill[1], fill[2], min(fill[3], 96))))
        bd = ImageDraw.Draw(button, "RGBA")
        bd.rounded_rectangle((0, 0, 487, 51), radius=6, outline=outline, width=3)
        _roughen_outer_edge(button, (2, 2, 485, 49), 501 + seed, 1, 3)
        bd.rounded_rectangle((8, 8, 479, 43), radius=4, outline=(255, 220, 150, 28), width=1)
        if row == 2:
            bd.rectangle((8, 8, 479, 14), fill=(0, 0, 0, 40))
        img.alpha_composite(button, (12, y))
    img.save(path)


def _button_state(path: Path, fill: tuple[int, int, int, int], outline: tuple[int, int, int, int], seed: int, inset: bool = False) -> None:
    img = Image.new("RGBA", SIZES[path.name], (0, 0, 0, 0))
    button = _stone_base((488, 52), 120 + seed)
    button.alpha_composite(Image.new("RGBA", (488, 52), (fill[0], fill[1], fill[2], min(fill[3], 96))))
    bd = ImageDraw.Draw(button, "RGBA")
    bd.rounded_rectangle((0, 0, 487, 51), radius=6, outline=outline, width=3)
    _roughen_outer_edge(button, (2, 2, 485, 49), 601 + seed, 1, 3)
    bd.rounded_rectangle((8, 8, 479, 43), radius=4, outline=(255, 220, 150, 28), width=1)
    if inset:
        bd.rectangle((8, 8, 479, 15), fill=(0, 0, 0, 48))
    img.alpha_composite(button, (12, 6))
    img.save(path)


def button_tablet_normal(path: Path) -> None:
    _button_state(path, STONE, BRONZE_DARK, 1)


def button_tablet_hover(path: Path) -> None:
    _button_state(path, _rgba("#4b402e", 90), BRONZE, 2)


def button_tablet_pressed(path: Path) -> None:
    _button_state(path, _rgba("#29231a", 120), _rgba("#b48145"), 3, True)


def button_tablet_disabled(path: Path) -> None:
    _button_state(path, _rgba("#0d0c0a", 165), _rgba("#3b3427", 170), 4)


def title_plaque(path: Path) -> None:
    img = Image.new("RGBA", SIZES[path.name], (0, 0, 0, 0))
    plaque = _stone_base((608, 88), 41)
    draw = ImageDraw.Draw(plaque, "RGBA")
    _carved_rect(draw, (0, 0, 607, 87), 10)
    _roughen_outer_edge(plaque, (2, 2, 605, 85), 701, 1, 4)
    draw.line((66, 44, 542, 44), fill=(255, 220, 150, 28), width=1)
    img.alpha_composite(plaque, (16, 20))
    img.save(path)


def pressure_groove(path: Path) -> None:
    img = Image.new("RGBA", SIZES[path.name], (0, 0, 0, 0))
    rail = _stone_base((736, 64), 52)
    draw = ImageDraw.Draw(rail, "RGBA")
    _carved_rect(draw, (0, 0, 735, 63), 8)
    _roughen_outer_edge(rail, (2, 2, 733, 61), 801, 1, 4)
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
