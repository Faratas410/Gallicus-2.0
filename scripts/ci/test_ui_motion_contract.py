"""Static export regression guard; motion behavior is exercised in Godot."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]


def test_ui_motion_contract() -> None:
    scene = (ROOT / "scenes/UI.tscn").read_text(encoding="utf-8")
    instance = re.search(r'\[node name="BettingCircle" parent="UI_RunRoot" instance=[^\]]*\]\n(.*?)(?=\n\[|\Z)', scene, re.S)
    if not instance:
        raise AssertionError("UI.tscn must instance BettingCircle under UI_RunRoot")
    # Historical exported binary-scene regression (2026-10-07). Retain until
    # an exported-instance check protects this boundary, not just editor input.
    for token in ("layout_mode = 3", "anchor_right = 1.0", "anchor_bottom = 1.0"):
        if token not in instance.group(1):
            raise AssertionError(f"Registry export needs explicit full-rect anchors: {token}")
    betting = (ROOT / "scripts/ui/betting_circle_ui.gd").read_text(encoding="utf-8")
    if "set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)" not in betting:
        raise AssertionError("Registry must restore full-rect layout after loading")


if __name__ == "__main__":
    test_ui_motion_contract()
    print("[OK][UI_MOTION_CONTRACT] Registry export anchor regression guard passed")
