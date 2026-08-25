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
    sfx_bus = (ROOT / "scripts/audio/sfx_bus.gd").read_text(encoding="utf-8")
    ui_root = (ROOT / "scripts/ui/ui_root.gd").read_text(encoding="utf-8")
    export_presets = (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
    project_settings = (ROOT / "project.godot").read_text(encoding="utf-8")

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
        "const PROFILE_VERSION: int = 4",
        "DEFAULT_SFX_VOLUME",
        "DEFAULT_REDUCED_MOTION",
        "func get_sfx_volume()",
        "func set_sfx_volume(value: float)",
        "func get_reduced_motion()",
        "func set_reduced_motion(value: bool)",
        "func _migrate_v3_to_v4",
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
        '"sfx_volume": SaveManager.get_sfx_volume()',
        '"reduced_motion": SaveManager.get_reduced_motion()',
        "_on_sfx_volume_changed",
        "_on_reduced_motion_toggled",
        "_configure_focus_order",
    ]:
        require(main_menu, token, "MainMenu settings wiring")

    for token in [
        'node name="ResolutionLabelPanel"',
        'node name="ResolutionOption"',
        'node name="ResolutionValuePanel"',
        'node name="SchermoInteroToggle"',
        'node name="SfxVolumeSlider"',
        'node name="ReducedMotionToggle"',
        "settings_slider_track.tres",
        "settings_slider_fill.tres",
        "settings_slider_grabber.png",
        "theme_override_styles/grabber_area",
    ]:
        require(main_scene, token, "Main settings scene nodes")

    for token in [
        'const SFX_BUS_NAME: String = "SFX"',
        "AudioServer.add_bus",
        'AudioServer.set_bus_send(_sfx_bus_index, "Master")',
        "_apply_sfx_volume_linear",
    ]:
        require(sfx_bus, token, "SFX runtime bus contract")

    for token in [
        "func _is_reduced_motion()",
        "func _focus_first_available(controls: Array)",
        "Control.FOCUS_ALL",
        "KEY_ENTER",
    ]:
        require(ui_root, token, "keyboard/reduced-motion UI contract")

    for token in [
        'name="Core Playable Candidate - Windows x86_64"',
        'platform="Windows Desktop"',
        'export_path="artifacts/exports/cp02/Gallicus_Core_Playable_Candidate.exe"',
        'exclude_filter="docs/*,work/*,artifacts/*,tools/*,scripts/ci/*,.github/*"',
        "script_export_mode=2",
        "debug/export_console_wrapper=0",
        "binary_format/embed_pck=true",
        'binary_format/architecture="x86_64"',
        "codesign/enable=false",
    ]:
        require(export_presets, token, "Windows CP-02 export preset")

    for token in [
        "window/size/viewport_width=1280",
        "window/size/viewport_height=720",
        'window/stretch/mode="viewport"',
        'window/stretch/aspect="keep"',
    ]:
        require(project_settings, token, "CP-02 viewport contract")

    print("[OK][SETTINGS_CONTRACT] settings persistence/UI guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
