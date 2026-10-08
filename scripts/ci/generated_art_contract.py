"""Validate the original rectangular material family and stable interaction geometry.

Generated full-frame RGB artwork replaces the former transparent silhouettes.
The interaction and scene-size checks remain in each object contract.
"""
from pathlib import Path
import json
import re
import struct

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "assets/ui/generated"
FAMILIES = {
    "receipt": {"receipt"},
    "condemnation_mark": {"condemnation_mark"},
    "second_incision": {"second_incision"},
    "arena_threshold": {"bronze_plaque"},
    "registry_table": {"registry_table", "registry_closed"},
    "promise_signature": {"promise_signature"},
    "pact_tablet": {"pact_tablet"},
    "arena_gesture": {"gesture_placa", "gesture_provoca"},
    "judgment_seal": {"judgment_seal"},
    "final_dossier": {"final_dossier", "registry_closed", "bronze_plaque"},
}

# The counter pass replaces ornamental object frames with native state surfaces.
# Paper is the only textured reading surface; other families keep their legacy art.
COUNTER_FAMILIES = {"receipt", "second_incision", "promise_signature", "arena_gesture", "registry_table", "final_dossier"}

def validate_counter_styles(family: str, styles: list[Path], declared: set[str]) -> None:
    geometries = {}
    for style in styles:
        text = style.read_text(encoding="utf-8")
        paper = family == "receipt" or (family == "final_dossier" and "_tab_" not in style.stem and "closed" not in style.stem)
        if paper:
            assert 'type="StyleBoxTexture"' in text, f"{style}: paper surface missing"
            assert 'path="res://assets/ui/generated/registry_paper.png"' in text, f"{style}: wrong reading material"
            assert "registry_paper" in declared, "missing paper provenance"
            assert (ART / "registry_paper.png").is_file(), "missing paper texture"
            slices = re.findall(r"^texture_margin_(?:left|top|right|bottom) = (.+)$", text, re.M)
            assert len(slices) == 4 and all(float(x) == 12 for x in slices), f"{style}: unstable paper edge"
        else:
            assert 'type="StyleBoxFlat"' in text, f"{style}: expected native counter state"
            assert "bg_color = Color(" in text and "border_color = Color(" in text, f"{style}: missing state contrast"
        geometry = tuple(re.findall(r"^content_margin_(?:left|top|right|bottom) = (.+)$", text, re.M))
        assert len(geometry) == 4, f"{style}: margins must be explicit"
        group = "tab" if "_tab_" in style.stem else "object"
        if group in geometries:
            assert geometries[group] == geometry, f"{style}: state changes hit geometry"
        geometries[group] = geometry

def validate_family(family: str) -> None:
    manifest = json.loads((ART / "manifest.json").read_text(encoding="utf-8"))
    declared = {entry["name"] for entry in manifest["assets"] if entry["prompt"] and entry["tool"] == "built-in image_gen"}
    for asset in FAMILIES[family]:
        assert asset in declared, f"{asset}: missing generation provenance"
        path = ART / f"{asset}.png"
        data = path.read_bytes()
        assert data[:8] == b"\x89PNG\r\n\x1a\n" and data[12:16] == b"IHDR", path
        width, height, depth, color_type = struct.unpack(">IIBB", data[16:26])
        assert depth == 8 and color_type in (2, 6), f"{path}: expected RGB/RGBA"
        assert min(width, height) >= 700 and max(width, height) <= 4096, f"{path}: invalid production size"
        expected = 3.0 if asset in ("bronze_plaque", "promise_signature") else 1.75 if asset == "final_dossier" else 1.5 if asset in ("registry_table", "registry_closed", "gesture_placa", "gesture_provoca") else 2.5
        assert abs(width / height - expected) < 0.005, f"{path}: incorrect object aspect"
    styles = sorted((ROOT / "assets/ui/official/objects" / family).glob("*.tres"))
    assert len(styles) >= 4, f"{family}: missing interactive states"
    if family in COUNTER_FAMILIES:
        validate_counter_styles(family, styles, declared)
        return
    geometries = {}
    bindings = set()
    for style in styles:
        text = style.read_text(encoding="utf-8")
        match = re.search(r'path="res://assets/ui/generated/([^"/]+)\.png"', text)
        assert match and match[1] in FAMILIES[family], f"{style}: wrong original material"
        bindings.add(match[1])
        geometry = tuple(re.findall(r"^(?:texture_margin|content_margin)_(?:left|top|right|bottom) = (.+)$", text, re.M))
        assert len(geometry) == 8 and all(float(x) == 0 for x in geometry[:4]), f"{style}: object must use whole-texture drawing"
        group = "tab" if "_tab_" in style.stem else "object"
        if group in geometries:
            assert geometries[group] == geometry, f"{style}: focus/press changes hit geometry"
        geometries[group] = geometry
    assert bindings == FAMILIES[family], f"{family}: missing state material"

def validate_theme() -> None:
    text = (ROOT / "assets/ui/theme/official_theme.tres").read_text(encoding="utf-8")
    assert "theme_types/" not in text, "Theme dictionaries are not Godot resource properties"
    for token in ("Label/colors/font_color", "Button/styles/normal", "Button/styles/focus", "OptionButton/styles/normal", "ProgressBar/styles/fill"):
        assert token in text, f"missing theme role: {token}"
    for name in ("font_body", "font_title_outline", "italiana_regular_font"):
        assert "base_font = ExtResource" in (ROOT / f"assets/ui/fonts/{name}.tres").read_text(encoding="utf-8"), f"{name}: empty font"
    # Guard the complete runtime binding surface, including dynamic load strings.
    for folder in ("scripts", "scenes", "data", "assets/ui/official", "assets/ui/fonts", "assets/ui/theme"):
        for source in (ROOT / folder).rglob("*"):
            if source.suffix not in (".gd", ".tscn", ".tres") or "ci" in source.parts:
                continue
            for path in re.findall(r'res://[^"\s]+\.(?:png|jpg|webp|svg|ttf|otf)', source.read_text(encoding="utf-8")):
                is_title_font = path in {"res://assets/ui/official/typography/LibreBaskerville.ttf", "res://assets/ui/official/typography/roboto_serif/RobotoSerif.ttf"}
                assert path.startswith("res://assets/ui/generated/") or is_title_font, f"{source}: retired visual dependency {path}"
                assert (ROOT / path.removeprefix("res://")).is_file(), f"{source}: missing visual {path}"
                if is_title_font:
                    assert (ROOT / path.removeprefix("res://")).with_name("OFL.txt").is_file(), "missing title font license"
