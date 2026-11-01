#!/usr/bin/env python3
"""Conservative selection of CI checks from an exact Git push range."""
from __future__ import annotations

import argparse
import difflib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ZERO = '0' * 40

# Each scoped runtime function has a focused contract exercising its real path.
FUNCTIONS = {
    '_pick_crowd_intent': 'crowd',
    '_settle_ledger_at_run_end': 'settlement',
}
CONTRACT_CHANGE = re.compile(
    r'\b(?:GameEvents|SaveManager|request_save|autosave|to_dict|from_dict|'
    r'emit_signal|signal|call|call_deferred|set_deferred|get_node|get_tree|load|preload|'
    r'ResourceLoader|FileAccess|DirAccess)\b|'
    r'\b\w*save\w*\s*\(|\.(?:emit|connect|disconnect|set|get|set_meta)\s*\(',
    re.IGNORECASE,
)
FUNCTION_SIGNATURE = re.compile(r'(?ms)^(?:static\s+)?func\s+\w+\s*\(.*?\)\s*(?:->\s*[^:\n]+)?\s*:')
DOC_GROUPS = {
    'docs/contracts/gameevents_signal_contract_v1.md': 'doc_gameevents',
    'docs/contracts/ritual_loop_contract_v1.md': 'doc_ritual',
    'docs/canon/UI_CANON.md': 'doc_ui',
    'docs/canon/MECHANICS_UNIFIED.md': 'doc_mechanics',
    'docs/canon/GLOSSARY_ENTITIES.md': 'doc_glossary',
    'docs/development_plan.md': 'doc_release',
    'docs/object_grammar.md': 'doc_release',
    'docs/release_checklist.md': 'doc_release',
}
STATIC = {
    'docs': ('docs_refs', 'no_mojibake', 'ci_checkpoint_contract'),
    'audio': ('av_assets', 'no_mojibake'),
    'crowd': ('no_mojibake',),
    'settlement': ('ledger_economy', 'bando_ladder', 'i18n_contract', 'ui_reactive_surface', 'no_mojibake'),
    'seat': ('i18n_contract', 'res_paths', 'no_mojibake'),
    'betting_ui': ('identity_resolver', 'level3_bet_offer', 'ledger_economy',
                   'bando_ladder', 'promise_signature_object', 'registry_table_object',
                   'ui_motion', 'ui_reactive_surface', 'i18n_contract', 'res_paths', 'no_mojibake'),
    'localization': ('i18n_contract', 'textual_style', 'bando_ladder', 'ledger_economy',
                     'arena_gesture_object', 'arena_threshold_object', 'condemnation_mark_object',
                     'final_dossier_object', 'judgment_seal_object', 'pact_tablet_object',
                     'promise_signature_object', 'receipt_object', 'registry_table_object',
                     'second_incision_object', 'no_mojibake'),
    'doc_gameevents': ('gameevents_contract', 'bando_ladder'),
    'doc_ritual': ('ritual_loop_contract',),
    'doc_ui': ('pressure_presentation', 'push_luck_counter', 'textual_style', 'ui_motion'),
    'doc_mechanics': ('push_luck_counter',),
    'doc_glossary': ('textual_style',),
    'doc_release': ('release_content',),
}
RUNTIME = {
    'audio': (('av_runtime_contract.gd', 'AV_RUNTIME_CONTRACT_OK'),
              ('audio_shutdown_contract.gd', 'AUDIO_SHUTDOWN_CONTRACT_OK'),
              ('audio_abrupt_shutdown_contract.gd', 'AUDIO_ABRUPT_SHUTDOWN_STARTED')),
    'crowd': (('crowd_seed_runtime_contract.gd', 'CROWD_SEED_CONTRACT_OK'),),
    'settlement': (('ledger_settlement_runtime_contract.gd', 'LEDGER_SETTLEMENT_CONTRACT_OK'),),
    'seat': (('seat_case_runtime_contract.gd', 'SEAT_CASE_RUNTIME_CONTRACT_OK'),
             ('seat_inquiry_runtime_contract.gd', 'SEAT_INQUIRY_RUNTIME_CONTRACT_OK'),
             ('seat_memory_runtime_contract.gd', 'SEAT_MEMORY_RUNTIME_CONTRACT_OK'),
             ('seat_copy_runtime_contract.gd', 'SEAT_COPY_RUNTIME_CONTRACT_OK'),
             ('seat_steps_era_contract.gd', 'SEAT_STEPS_ERA_CONTRACT_OK')),
    'betting_ui': (('audit_runtime_contract.gd', 'AUDIT_RUNTIME_CONTRACT_OK'),),
    # Every runtime contract that lean ran and that reads translated text:
    # exact strings, untranslated keys or localized presentation.
    'localization': (('audit_runtime_contract.gd', 'AUDIT_RUNTIME_CONTRACT_OK'),
                     ('av_runtime_contract.gd', 'AV_RUNTIME_CONTRACT_OK'),
                     ('character_runtime_contract.gd', 'CHARACTER_RUNTIME_CONTRACT_OK'),
                     ('illustrated_dialogue_contract.gd', 'ILLUSTRATED_DIALOGUE_CONTRACT_OK'),
                     ('final_era_runtime_contract.gd', 'FINAL_ERA_RUNTIME_CONTRACT_OK'),
                     ('seat_copy_echo_contract.gd', 'SEAT_COPY_ECHO_CONTRACT_OK'),
                     ('seat_steps_era_contract.gd', 'SEAT_STEPS_ERA_CONTRACT_OK')),
}
RUNTIME_TIMEOUT = 90
# Longer contracts keep the limits of their own runners.
RUNTIME_TIMEOUTS = {'illustrated_dialogue_contract.gd': 150}


def _function_lines(text: str) -> list[str | None]:
    result: list[str | None] = []
    current = None
    for line in text.splitlines():
        match = re.match(r'^func\s+(\w+)\s*\(', line)
        if match:
            current = match.group(1)
        elif line and not line[0].isspace() and not line.startswith('#'):
            current = None
        result.append(current)
    return result


def changed_functions(before: str, after: str) -> set[str] | None:
    if FUNCTION_SIGNATURE.findall(before) != FUNCTION_SIGNATURE.findall(after):
        return None
    old, new = before.splitlines(), after.splitlines()
    old_map, new_map = _function_lines(before), _function_lines(after)
    found: set[str] = set()
    for tag, i, j, k, l in difflib.SequenceMatcher(None, old, new, autojunk=False).get_opcodes():
        if tag == 'equal':
            continue
        for lines, mapping, start, end in ((old, old_map, i, j), (new, new_map, k, l)):
            for pos in range(start, end):
                if not lines[pos].strip():
                    continue
                name = mapping[pos]
                # Function signatures change contracts and must use the full gate.
                if name is None or lines[pos].startswith('func ') or CONTRACT_CHANGE.search(lines[pos]):
                    return None
                found.add(name)
    return found or None


def changes_contract(before: str, after: str) -> bool:
    if FUNCTION_SIGNATURE.findall(before) != FUNCTION_SIGNATURE.findall(after):
        return True
    old, new = before.splitlines(), after.splitlines()
    for tag, i, j, k, l in difflib.SequenceMatcher(None, old, new, autojunk=False).get_opcodes():
        if tag == 'equal':
            continue
        for line in old[i:j] + new[k:l]:
            if (re.match(r'^(?:static\s+)?func\s+', line) or CONTRACT_CHANGE.search(line)
                    or (line and not line[0].isspace() and not line.startswith('#'))):
                return True
    return False


def select(changes: list[tuple[str, str]], read_file) -> dict:
    groups: set[str] = set()
    fallback = ''
    for status, path in changes:
        if (path in ('project.godot', 'scripts/systems/game_events.gd', 'scripts/systems/save_manager.gd')
                or path.startswith(('scripts/contracts/', 'scripts/systems/run/'))):
            return {'mode': 'full', 'reason': f'authority or schema: {path}', 'groups': []}
        # Renames/deletions/additions may alter dependencies or remove checks.
        if path == 'AGENTS.md' or path.startswith('docs/'):
            if status not in ('A', 'M', 'D'):
                fallback = fallback or f'{status} {path}'
                continue
            groups.add('docs')
            if path in DOC_GROUPS:
                groups.add(DOC_GROUPS[path])
        elif status != 'M':
            if path == 'scripts/systems/run_manager.gd':
                return {'mode': 'full', 'reason': f'{status} {path}', 'groups': []}
            fallback = fallback or f'{status} {path}'
        elif path in {f'assets/i18n/{locale}.{suffix}' for locale in ('it', 'en', 'es')
                      for suffix in ('csv', 'csv.import', f'{locale}.translation')}:
            groups.add('localization')
        elif path == 'scripts/ui/betting_circle_ui.gd':
            try:
                before, after = read_file('base', path), read_file('head', path)
                if changes_contract(before, after):
                    return {'mode': 'full', 'reason': f'contract change in {path}', 'groups': []}
                changed = changed_functions(before, after)
            except (UnicodeError, subprocess.SubprocessError):
                changed = None
            if not changed or not changed.issubset({'_format_contract_body'}):
                fallback = fallback or f'unmapped change in {path}'
            else:
                groups.add('betting_ui')
        elif path in ('scripts/audio/sfx_bus.gd', 'scripts/ui/seat_case.gd'):
            try:
                sensitive = changes_contract(read_file('base', path), read_file('head', path))
            except (UnicodeError, subprocess.SubprocessError):
                sensitive = True
            if sensitive:
                return {'mode': 'full', 'reason': f'contract change in {path}', 'groups': []}
            groups.add({'scripts/audio/sfx_bus.gd': 'audio',
                        'scripts/ui/seat_case.gd': 'seat'}[path])
        elif path == 'scripts/systems/run_manager.gd':
            try:
                changed = changed_functions(read_file('base', path), read_file('head', path))
            except (UnicodeError, subprocess.SubprocessError):
                changed = None
            if not changed or not changed.issubset(FUNCTIONS):
                return {'mode': 'full', 'reason': f'unmapped change in {path}', 'groups': []}
            groups.update(FUNCTIONS[name] for name in changed)
        else:
            fallback = fallback or f'unmapped path {path}'
    if fallback:
        return {'mode': 'lean', 'reason': fallback, 'groups': []}
    if not groups:
        return {'mode': 'full', 'reason': 'empty or unavailable diff', 'groups': []}
    return {'mode': 'contextual', 'reason': 'mapped changes', 'groups': sorted(groups)}


def git(*args: str) -> bytes:
    return subprocess.check_output(['git', *args], cwd=ROOT, stderr=subprocess.PIPE)


def plan(base: str, head: str) -> dict:
    try:
        if base == ZERO or not base or not head:
            raise ValueError('missing push base')
        if git('rev-parse', 'HEAD').strip() != git('rev-parse', head).strip():
            raise ValueError('checkout does not match push head')
        git('merge-base', '--is-ancestor', base, head)
        raw = git('diff', '--name-status', '-z', '--no-renames', base, head)
        parts = raw.decode('utf-8').split('\0')
        changes = [(parts[i], parts[i + 1]) for i in range(0, len(parts) - 1, 2)]
        def read_file(which, path):
            return git('show', f'{base if which == "base" else head}:{path}').decode('utf-8')
        result = select(changes, read_file)
    except (ValueError, UnicodeError, subprocess.SubprocessError, IndexError):
        result = {'mode': 'full', 'reason': 'unavailable or unsafe push range', 'groups': []}
    result.update(base=base, head=head)
    return result


def run_static(groups: list[str]) -> None:
    from run_testing_playbook import STATIC_STEPS
    requested = {label for group in groups for label in STATIC[group]}
    commands = {label: command for label, command in STATIC_STEPS}
    if not requested or not requested.issubset(commands):
        raise ValueError('unknown or empty static selection')
    for label in sorted(requested):
        print(f'[CONTEXT] {label}', flush=True)
        subprocess.run(commands[label], cwd=ROOT, check=True)


def run_runtime(groups: list[str], godot: str) -> None:
    checks = {item for group in groups for item in RUNTIME.get(group, ())}
    if not checks:
        raise ValueError('empty runtime selection')
    for script, marker in sorted(checks):
        with tempfile.TemporaryDirectory(prefix='gallicus_context_') as temp:
            env = os.environ.copy()
            env.update(APPDATA=temp, LOCALAPPDATA=temp, XDG_DATA_HOME=temp)
            result = subprocess.run([godot, '--headless', '--audio-driver', 'Dummy', '--path', str(ROOT),
                                     '--script', f'res://scripts/ci/{script}'], cwd=ROOT, env=env,
                                    capture_output=True, text=True, encoding='utf-8', errors='replace',
                                    timeout=RUNTIME_TIMEOUTS.get(script, RUNTIME_TIMEOUT))
            output = result.stdout + result.stderr
            print(output, flush=True)
            if result.returncode or marker not in output or 'ERROR:' in output or 'ObjectDB instances' in output:
                raise RuntimeError(f'context runtime failed: {script}')


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=('plan', 'static', 'runtime'))
    parser.add_argument('--base', default='')
    parser.add_argument('--head', default='')
    parser.add_argument('--groups', default='')
    parser.add_argument('--godot-bin', default='')
    args = parser.parse_args()
    if args.action == 'plan':
        result = plan(args.base, args.head)
        print(json.dumps(result, sort_keys=True))
        if os.getenv('GITHUB_OUTPUT'):
            with open(os.environ['GITHUB_OUTPUT'], 'a', encoding='utf-8') as out:
                out.write(f"mode={result['mode']}\ngroups={','.join(result['groups'])}\n")
                out.write(f"runtime={'true' if any(g in RUNTIME for g in result['groups']) else 'false'}\n")
        return 0
    groups = args.groups.split(',') if args.groups else []
    if not groups or any(g not in STATIC for g in groups):
        raise ValueError('invalid groups')
    if args.action == 'static':
        run_static(groups)
    else:
        if not args.godot_bin:
            raise ValueError('Godot binary required')
        run_runtime(groups, args.godot_bin)
    return 0


if __name__ == '__main__':
    sys.exit(main())
