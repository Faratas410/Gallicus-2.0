from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[2]
UI_ROOT = ROOT / "scripts" / "ui" / "ui_root.gd"
MAIN_MENU = ROOT / "scripts" / "ui" / "main_menu.gd"
BETTING_CIRCLE = ROOT / "scripts" / "ui" / "betting_circle_ui.gd"
UI_CANON = ROOT / "docs" / "canon" / "UI_CANON.md"


ALLOWED_UI_ROOT_TWEEN_FUNCS = {
    "_show_scar_popup",
    "_show_arena_resolution_overlay",
    "_on_register_annotation",
    "_reveal_verdict_group",
    "_pulse_pressure_indicator",
    "_on_mid_choice_emphasis",
    "_pulse_pyl_panel",
    "_apply_decision_lock",
    "_pre_resolve_tension_boost",
    "begin_sign_feedback",
    "_fade_modal",
    "_play_panel_enter",
}


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _function_body(source: str, name: str) -> str:
    match = re.search(rf"^func {re.escape(name)}\(.*?(?=^func |\Z)", source, re.M | re.S)
    if not match:
        raise AssertionError(f"missing function {name}")
    return match.group(0)


def _tween_functions(source: str) -> set[str]:
    current = ""
    funcs: set[str] = set()
    for line in source.splitlines():
        if line.startswith("func "):
            current = line.split("(", 1)[0].replace("func ", "")
        if "create_tween()" in line:
            funcs.add(current)
    return funcs


def test_ui_motion_contract() -> None:
    ui_root = _read(UI_ROOT)
    main_menu = _read(MAIN_MENU)
    betting_circle = _read(BETTING_CIRCLE)
    canon = _read(UI_CANON)

    for token in [
        'const MOTION_KIND_STANDARD: String = "standard"',
        'const MOTION_KIND_RITUAL: String = "ritual"',
        'const MOTION_KIND_ENDING: String = "ending"',
        "func _play_panel_enter",
        "func _fade_modal",
    ]:
        if token not in ui_root:
            raise AssertionError(f"ui_root.gd missing motion token: {token}")

    if "func _play_modal_pop" in ui_root:
        raise AssertionError("legacy _play_modal_pop helper must be replaced by _play_panel_enter")

    unexpected = _tween_functions(ui_root) - ALLOWED_UI_ROOT_TWEEN_FUNCS
    if unexpected:
        raise AssertionError(f"unexpected create_tween() functions in ui_root.gd: {sorted(unexpected)}")

    fade_body = _function_body(ui_root, "_fade_modal")
    if "Tween.TRANS_QUAD" not in fade_body or "Tween.EASE_OUT" not in fade_body or "Tween.EASE_IN" not in fade_body:
        raise AssertionError("_fade_modal must use governed QUAD enter/exit easing")

    for name in [
        "_on_push_luck_cashout_pressed",
        "_on_push_luck_condanna_pressed",
        "_on_push_luck_double_pressed",
    ]:
        body = _function_body(ui_root, name)
        if "await " in body:
            raise AssertionError(f"{name} must not await animation before emitting gameplay intent")
        if "_emit_game_event_signal_if_available" not in body:
            raise AssertionError(f"{name} must still emit gameplay intent")

    if "_menu_button_tweens" not in main_menu:
        raise AssertionError("main_menu.gd must guard hover tweens against accumulation")
    if "Tween.TRANS_QUAD" not in betting_circle:
        raise AssertionError("betting_circle_ui.gd must use governed QUAD motion for open/stamp feedback")
    for token in [
        "_opening_locked",
        "_awaiting_open_request",
        "_show_book_closed_state",
        "_show_closed_intro",
        "_on_open_book_pressed",
        "_reveal_book_content",
        "_start_contract_write_animation",
        "CONTRACT_WRITE_SECONDS",
        "BOOK_DROP_SECONDS",
    ]:
        if token not in betting_circle:
            raise AssertionError(f"betting_circle_ui.gd missing book-open animation token: {token}")
    for stale_token in [
        "BOOK_IDLE_BOB_SPEED",
        "BOOK_IDLE_BOB_AMPLITUDE",
    ]:
        if stale_token in betting_circle:
            raise AssertionError(f"betting_circle_ui.gd must not keep idle page-bob token: {stale_token}")

    betting_scene = (ROOT / "scenes" / "ui" / "BettingCircle.tscn").read_text(encoding="utf-8")
    for token in [
        "book_closed_cover.png",
        "ClosedBookBg",
        "ClosedIntro",
        "Btn_Open_Book",
    ]:
        if token not in betting_scene:
            raise AssertionError(f"BettingCircle.tscn missing closed-book animation token: {token}")

    for token in [
        "Motion Contract",
        "presentational-only",
        "standard`, `ritual`, and `ending",
    ]:
        if token not in canon:
            raise AssertionError(f"UI_CANON.md missing motion contract token: {token}")


if __name__ == "__main__":
    test_ui_motion_contract()
    print("[OK][UI_MOTION_CONTRACT] motion governance guard passed")
