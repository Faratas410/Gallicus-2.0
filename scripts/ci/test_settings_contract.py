#!/usr/bin/env python3
"""Static guard for main-menu settings persistence and UI wiring."""

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def require(text: str, token: str, label: str) -> None:
    if token not in text:
        raise AssertionError(f"missing {label}: {token}")


def main() -> int:
    save_manager = (ROOT / "scripts/systems/save_manager.gd").read_text(encoding="utf-8")
    main_menu = (ROOT / "scripts/ui/main_menu.gd").read_text(encoding="utf-8")
    main_scene = (ROOT / "scenes/Main.tscn").read_text(encoding="utf-8")

    for token in [
        "DEFAULT_FULLSCREEN",
        "DEFAULT_WINDOW_RESOLUTION",
        "ALLOWED_WINDOW_RESOLUTIONS",
        "func get_fullscreen()",
        "func set_fullscreen(value: bool)",
        "func get_window_resolution()",
        "func set_window_resolution(value: String)",
        '"fullscreen"',
        '"window_resolution"',
    ]:
        require(save_manager, token, "SaveManager settings contract")

    for token in [
        "resolution_option",
        "_setup_resolution_options",
        "_on_resolution_selected",
        "_apply_window_resolution",
        "_apply_fullscreen",
        '"fullscreen": SaveManager.get_fullscreen()',
        '"window_resolution": SaveManager.get_window_resolution()',
    ]:
        require(main_menu, token, "MainMenu settings wiring")

    for token in [
        'node name="ResolutionLabelPanel"',
        'node name="ResolutionOption"',
        'node name="ResolutionValuePanel"',
        'node name="SchermoInteroToggle"',
        "settings_slider_track.tres",
        "settings_slider_fill.tres",
        "settings_slider_grabber.png",
        "theme_override_styles/grabber_area",
    ]:
        require(main_scene, token, "Main settings scene nodes")

    print("[OK][SETTINGS_CONTRACT] settings persistence/UI guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
