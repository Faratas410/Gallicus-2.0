"""Coverage of focused selection, unions and conservative escalation."""
from pathlib import Path
import os
import shutil
import subprocess
import sys
import tempfile

import contextual_ci as ci


def test_function_selection():
    before = 'const VALUE = 1\n\nfunc _pick_crowd_intent() -> void:\n\tvar a = 1\n\nfunc other() -> void:\n\tpass\n'
    after = before.replace('var a = 1', 'var a = 2')
    assert ci.changed_functions(before, after) == {'_pick_crowd_intent'}
    assert ci.changed_functions(before, after.replace('VALUE = 1', 'VALUE = 2')) is None
    assert ci.changed_functions(before, after.replace('var a = 2', 'GameEvents.run_started.emit()')) is None
    assert ci.changed_functions(before, after.replace('var a = 2', 'call_deferred("save")')) is None
    assert ci.changed_functions(before, after.replace('var a = 2', '_autosave_run_checkpoint()')) is None
    assert ci.changed_functions(before, after.replace('var a = 2', 'button.pressed.connect(callback)')) is None
    assert ci.changed_functions(before, after.replace('var a = 2', '_run_state.set("field", 1)')) is None
    assert ci.changed_functions(before, after.replace('func _pick_crowd_intent()', 'func renamed()')) is None
    multi_old = 'func _pick_crowd_intent(\n\ta: int\n) -> void:\n\tpass\n'
    multi_new = multi_old.replace('a: int', 'a: float')
    assert ci.changed_functions(multi_old, multi_new) is None
    assert ci.changes_contract(multi_old, multi_new)
    result = ci.select([('M', 'scripts/systems/run_manager.gd'), ('M', 'scripts/audio/sfx_bus.gd')],
                       lambda side, path: (before if side == 'base' else after) if path.endswith('run_manager.gd') else 'func play():\n\tpass\n')
    assert result['mode'] == 'contextual' and result['groups'] == ['audio', 'crowd']
    settlement_old = 'func _settle_ledger_at_run_end(reason):\n\tvar n = 1\n'
    settlement_new = settlement_old.replace('n = 1', 'n = 2')
    result = ci.select([('M', 'scripts/systems/run_manager.gd')],
                       lambda side, _: settlement_old if side == 'base' else settlement_new)
    assert result['mode'] == 'contextual' and result['groups'] == ['settlement']
    assert set(ci.STATIC['settlement']) >= {'ledger_economy', 'bando_ladder', 'i18n_contract', 'ui_reactive_surface'}
    assert ('ledger_settlement_runtime_contract.gd', 'LEDGER_SETTLEMENT_CONTRACT_OK') in ci.RUNTIME['settlement']
    assert ci.select([('M', 'scripts/systems/run_manager.gd')], lambda side, _: before if side == 'base' else after.replace('other()', 'changed()'))['mode'] == 'full'


def test_fail_closed():
    unused = lambda *_: ''
    assert ci.select([('M', 'docs/testing.md'), ('A', 'docs/new.md')], unused)['groups'] == ['docs']
    assert ci.select([('M', 'scripts/audio/sfx_bus.gd'), ('M', 'docs/testing.md')], unused)['groups'] == ['audio', 'docs']
    assert ci.select([('M', 'scripts/ui/seat_case.gd')], unused)['groups'] == ['seat']
    assert ci.select([('M', 'docs/canon/UI_CANON.md')], unused)['groups'] == ['doc_ui', 'docs']
    assert ci.select([('M', 'docs/contracts/gameevents_signal_contract_v1.md')], unused)['groups'] == ['doc_gameevents', 'docs']
    assert ci.select([('M', 'scripts/ui/seat_case.gd')], lambda side, _: 'func x():\n\tpass\n' if side == 'base' else 'func x():\n\tGameEvents.foo.emit()\n')['mode'] == 'full'
    assert ci.select([('M', 'scripts/ui/seat_case.gd')], lambda side, _: 'const LIMIT = 1\n' if side == 'base' else 'const LIMIT = 2\n')['mode'] == 'full'
    assert ('seat_steps_era_contract.gd', 'SEAT_STEPS_ERA_CONTRACT_OK') in ci.RUNTIME['seat']
    assert ci.select([('D', 'scripts/audio/sfx_bus.gd')], unused)['mode'] == 'lean'
    assert ci.select([('D', 'scripts/systems/run_manager.gd')], unused)['mode'] == 'full'
    assert ci.select([('M', 'scripts/systems/save_manager.gd')], unused)['mode'] == 'full'
    assert ci.select([('M', 'unknown.gd'), ('M', 'scripts/systems/save_manager.gd')], unused)['mode'] == 'full'
    assert ci.select([('M', 'scripts/systems/save_manager.gd'), ('M', 'unknown.gd')], unused)['mode'] == 'full'
    assert ci.select([('M', 'scripts/contracts/run_phase_contract.gd')], unused)['mode'] == 'full'
    assert ci.select([('M', 'project.godot')], unused)['mode'] == 'full'
    assert ci.select([('M', '.github/ci/full_suite_checkpoint.txt')], unused)['mode'] == 'lean'
    assert ci.select([('M', 'unknown.gd')], unused)['mode'] == 'lean'
    assert ci.plan(ci.ZERO, ci.ZERO)['mode'] == 'full'


def test_betting_and_localization():
    before = 'func _format_contract_body():\n\tvar width = 100\n'
    after = before.replace('100', '120')
    reader = lambda side, _: before if side == 'base' else after
    ui = 'scripts/ui/betting_circle_ui.gd'
    result = ci.select([('M', ui)], reader)
    assert result['mode'] == 'contextual' and result['groups'] == ['betting_ui']
    assert {'identity_resolver', 'level3_bet_offer', 'ledger_economy', 'bando_ladder',
            'promise_signature_object', 'registry_table_object', 'ui_motion', 'i18n_contract'} <= set(ci.STATIC['betting_ui'])
    assert ('audit_runtime_contract.gd', 'AUDIT_RUNTIME_CONTRACT_OK') in ci.RUNTIME['betting_ui']
    for locale in ('it', 'en', 'es'):
        for suffix in ('csv', 'csv.import', f'{locale}.translation'):
            path = f'assets/i18n/{locale}.{suffix}'
            assert ci.select([('M', path)], reader)['groups'] == ['localization']
            assert ci.select([('D', path)], reader)['mode'] == 'lean'
    assert {'i18n_contract', 'textual_style', 'bando_ladder', 'promise_signature_object'} <= set(ci.STATIC['localization'])
    # Translations feed exact strings and untranslated-key checks beyond the pact page.
    localized = {script for script, _ in ci.RUNTIME['localization']}
    assert set(ci.RUNTIME['betting_ui']) <= set(ci.RUNTIME['localization'])
    assert {'av_runtime_contract.gd', 'character_runtime_contract.gd', 'illustrated_dialogue_contract.gd',
            'final_era_runtime_contract.gd', 'seat_copy_echo_contract.gd', 'seat_steps_era_contract.gd'} <= localized
    assert ci.RUNTIME_TIMEOUTS['illustrated_dialogue_contract.gd'] >= 150
    result = ci.select([('M', ui), ('M', 'assets/i18n/en.csv')], reader)
    assert result['groups'] == ['betting_ui', 'localization']
    assert ci.select([('M', ui)], lambda side, _: before if side == 'base' else after + '\tGameEvents.changed.emit()\n')['mode'] == 'full'
    assert ci.select([('M', ui)], lambda side, _: before.replace('_format_contract_body', 'layout') if side == 'base' else after.replace('_format_contract_body', 'layout'))['mode'] == 'lean'
    assert ci.select([('M', 'assets/i18n/languages.gd')], reader)['mode'] == 'lean'
    assert ci.select([('M', ui), ('M', 'scripts/systems/save_manager.gd')], reader)['mode'] == 'full'


def test_ui_behavior_replacements():
    from types import SimpleNamespace
    from unittest.mock import patch
    # Execute selection through the runner: mixed UI/locale/docs changes must
    # keep their replacement behaviors and must not execute them three times.
    markers = '\n'.join(marker for group in ('betting_ui', 'localization', 'doc_ui')
                        for _, marker in ci.RUNTIME[group])
    result = SimpleNamespace(returncode=0, stdout=markers, stderr='')
    with patch.object(ci.subprocess, 'run', return_value=result) as run:
        ci.run_runtime(['betting_ui', 'localization', 'doc_ui'], 'fixture-godot')
    scripts = [call.args[0][call.args[0].index('--script') + 1] for call in run.call_args_list]
    for name in ('judgment_runtime_contract.gd', 'art_uniformity_runtime_contract.gd',
                 'audit_runtime_contract.gd'):
        assert scripts.count('res://scripts/ci/' + name) == 1, scripts
    profiles = [call.kwargs['env']['APPDATA'] for call in run.call_args_list]
    assert len(profiles) == len(set(profiles)), 'runtime contracts reused a profile'


def test_real_push_range():
    with tempfile.TemporaryDirectory(prefix='gallicus_ci_plan_') as temp:
        path = Path(temp)
        def git(*args):
            return subprocess.check_output(['git', *args], cwd=path, stderr=subprocess.STDOUT, text=True).strip()
        git('init')
        git('config', 'user.email', 'ci@example.invalid')
        git('config', 'user.name', 'CI fixture')
        (path / 'docs').mkdir()
        (path / 'scripts' / 'audio').mkdir(parents=True)
        (path / 'assets' / 'i18n').mkdir(parents=True)
        (path / 'assets' / 'i18n' / 'en.csv').write_text('keys,en\nhello,Hello\n', encoding='utf-8')
        (path / 'docs' / 'a.md').write_text('old\n', encoding='utf-8')
        (path / 'scripts' / 'audio' / 'sfx_bus.gd').write_text('func play():\n\tvar value = 1\n', encoding='utf-8')
        git('add', '.')
        git('commit', '-m', 'base')
        base = git('rev-parse', 'HEAD')
        (path / 'docs' / 'a.md').write_text('new\n', encoding='utf-8')
        git('add', '.')
        git('commit', '-m', 'docs')
        head = git('rev-parse', 'HEAD')
        (path / 'scripts' / 'audio' / 'sfx_bus.gd').write_text('func play():\n\tvar value = 2\n', encoding='utf-8')
        git('add', '.')
        git('commit', '-m', 'audio')
        latest = git('rev-parse', 'HEAD')
        script = path / 'scripts' / 'ci' / 'contextual_ci.py'
        script.parent.mkdir()
        shutil.copyfile(Path(ci.__file__), script)
        old_root = ci.ROOT
        try:
            ci.ROOT = path
            result = ci.plan(base, latest)
            assert result['mode'] == 'contextual' and result['groups'] == ['audio', 'docs'], result
            output = path / 'github_output.txt'
            env = os.environ.copy()
            env['GITHUB_OUTPUT'] = str(output)
            subprocess.run([sys.executable, str(script), 'plan', '--base', base, '--head', latest], cwd=path, env=env, check=True, capture_output=True, text=True)
            assert output.read_text(encoding='utf-8').splitlines() == ['mode=contextual', 'groups=audio,docs', 'runtime=true']
            result = ci.plan(head, latest)
            assert result['mode'] == 'contextual' and result['groups'] == ['audio'], result
            (path / 'assets' / 'i18n' / 'en.csv').write_text('keys,en\nhello,Welcome\n', encoding='utf-8')
            git('add', 'assets/i18n/en.csv')
            git('commit', '-m', 'localization')
            localized = git('rev-parse', 'HEAD')
            result = ci.plan(latest, localized)
            assert result['mode'] == 'contextual' and result['groups'] == ['localization'], result
            output.unlink()
            subprocess.run([sys.executable, str(script), 'plan', '--base', latest, '--head', localized], cwd=path, env=env, check=True, capture_output=True, text=True)
            assert output.read_text(encoding='utf-8').splitlines() == ['mode=contextual', 'groups=localization', 'runtime=true']
            git('checkout', '--detach', head)
            result = ci.plan(base, head)
            assert result['mode'] == 'contextual' and result['groups'] == ['docs'], result
            assert ci.plan(head, base)['mode'] == 'full'
            assert ci.plan('f' * 40, head)['mode'] == 'full'
            git('checkout', '--detach', base)
            (path / 'docs' / 'a.md').write_text('divergent\n', encoding='utf-8')
            git('add', '.')
            git('commit', '-m', 'divergent')
            divergent = git('rev-parse', 'HEAD')
            git('checkout', '--detach', latest)
            assert ci.plan(divergent, latest)['mode'] == 'full'
        finally:
            ci.ROOT = old_root


if __name__ == '__main__':
    test_function_selection()
    test_fail_closed()
    test_betting_and_localization()
    test_ui_behavior_replacements()
    test_real_push_range()
    print('[OK][CONTEXTUAL_CI]')
