from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
UI_SCENE = ROOT / "scenes" / "UI.tscn"
UI_ROOT = ROOT / "scripts" / "ui" / "ui_root.gd"
RUN_MANAGER = ROOT / "scripts" / "systems" / "run_manager.gd"
OUTCOME_SYSTEM = ROOT / "scripts" / "systems" / "run" / "outcome_system.gd"
BET_CATALOG = ROOT / "scripts" / "content" / "bet_catalog.gd"
UI_CANON = ROOT / "docs" / "canon" / "UI_CANON.md"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _assert_contains(text: str, needle: str, source: str) -> None:
    if needle not in text:
        raise AssertionError(f"{source} missing required pressure contract token: {needle}")


def _assert_absent(text: str, needle: str, source: str) -> None:
    if needle in text:
        raise AssertionError(f"{source} contains stale pressure/escalation token: {needle}")


def test_player_facing_pressure_contract() -> None:
    scene = _read(UI_SCENE)
    ui_root = _read(UI_ROOT)
    run_manager = _read(RUN_MANAGER)
    outcome_system = _read(OUTCOME_SYSTEM)
    bet_catalog = _read(BET_CATALOG)
    canon = _read(UI_CANON)

    _assert_contains(scene, 'text = "PRESSIONE 0/10"', "UI.tscn")
    _assert_contains(scene, 'node name="PressureRail"', "UI.tscn")
    _assert_contains(scene, 'node name="PressureStateLabel"', "UI.tscn")
    _assert_contains(scene, "Pressione -1.", "UI.tscn")
    _assert_contains(scene, "Pressione +1.", "UI.tscn")
    _assert_contains(scene, "Pressione +1. Aumenti posta e rischio.", "UI.tscn")

    _assert_absent(scene, 'text = "ESCALATION"', "UI.tscn")
    _assert_absent(scene, 'parent="HUD/SafeMargin/TopRow/LeftColumn/EscalationRow"', "UI.tscn")
    _assert_absent(scene, "Riduci escalation", "UI.tscn")
    _assert_absent(scene, "Aumenta escalation", "UI.tscn")

    for helper in [
        "func _format_pressure_label",
        "func _get_pressure_state_text",
        "func _get_pressure_color",
        "func _pulse_pressure_indicator",
        "func _resolve_final_pressure_max",
    ]:
        _assert_contains(ui_root, helper, "ui_root.gd")

    _assert_contains(ui_root, "PressureStateLabel", "ui_root.gd")
    _assert_contains(ui_root, "Pressione massima: %d/%d", "ui_root.gd")
    _assert_contains(ui_root, "chiudi il registro", "ui_root.gd")

    _assert_absent(run_manager, "Pressione folla: %d/%d", "run_manager.gd")
    _assert_absent(run_manager, "Pressione %d/%d", "run_manager.gd")
    _assert_absent(run_manager, "Incasso sotto pressione", "run_manager.gd")
    _assert_contains(run_manager, "var pending_echo_bonus: int = maxi(_run_state.signature_echo_bonus_pending, 0)", "run_manager.gd")
    _assert_contains(run_manager, "clampi(_run_state.escalation_level + 1 + pending_echo_bonus, 1, ESCALATION_MAX)", "run_manager.gd")

    _assert_contains(outcome_system, "const ESCALATION_WIN_STEP_PENALTY: float = 0.055", "outcome_system.gd")
    _assert_contains(outcome_system, "const ESCALATION_ADVERSE_STEP_PENALTY: float = 0.045", "outcome_system.gd")
    _assert_absent(outcome_system, "float(escalation_level - 1) * 0.09", "outcome_system.gd")
    _assert_absent(outcome_system, "float(escalation_level - 1) * 0.07", "outcome_system.gd")

    _assert_contains(bet_catalog, "Tieni il margine. Ricompensa bassa, pressione stabile.", "bet_catalog.gd")
    _assert_contains(bet_catalog, "Ritorno alto, margine nullo.", "bet_catalog.gd")
    _assert_absent(bet_catalog, "incassi subito", "bet_catalog.gd")

    _assert_contains(canon, "only numeric pressure meter", "UI_CANON.md")
    _assert_contains(canon, "RunState.audience_pressure", "UI_CANON.md")
    _assert_contains(canon, "runtime-internal", "UI_CANON.md")


if __name__ == "__main__":
    test_player_facing_pressure_contract()
    print("[OK] pressure presentation contract")
