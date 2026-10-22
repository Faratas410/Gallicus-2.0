"""Ritual cues for tools/audio/compose.py: stone, wax, bronze, paper, coins, sand, crowd.

Each cue is a short layered edit of real recordings (see sources.json). A few
textures that no free recording in reach covered well (coin ring, paper grain,
brand sizzle tail, distant voices) are shaped from noise and resonators and
always sit under a real recorded layer.
"""
import numpy as np

import dsp
from dsp import SR, Bus, db

ROOM_SEED = 9100


def hit(key: str, peak_db: float = -1.0) -> np.ndarray:
    return dsp.peak_to(dsp.load(key), peak_db)


def slice_(x: np.ndarray, start: float, seconds: float, fade_out: float = 0.02) -> np.ndarray:
    piece = x[int(start * SR): int((start + seconds) * SR)]
    return dsp.fade(piece, 0.002, min(fade_out, len(piece) / SR))


def noise(seconds: float, rng) -> np.ndarray:
    return rng.standard_normal((int(seconds * SR), 2)).astype(np.float32) * 0.3


def envelope(n: int, attack: float, decay: float) -> np.ndarray:
    t = np.arange(n) / SR
    env = np.minimum(1.0, t / max(attack, 1e-4)) * np.exp(-t / max(decay, 1e-4))
    return env.astype(np.float32)[:, None]


def coin(rng) -> np.ndarray:
    """One small bronze coin: a real metal tick pitched up over a ring of inharmonic modes."""
    n = int(0.35 * SR)
    t = np.arange(n) / SR
    base = rng.uniform(2600, 4200)
    ring = np.zeros(n, dtype=np.float32)
    for ratio, gain, decay in [(1.0, 1.0, 0.09), (2.41, 0.6, 0.06), (3.86, 0.45, 0.045), (5.3, 0.25, 0.03)]:
        ring += gain * np.sin(2 * np.pi * base * ratio * rng.uniform(0.99, 1.01) * t + rng.uniform(0, 6.28)) * np.exp(-t / (decay * rng.uniform(0.7, 1.3)))
    ring = dsp.stereo(ring) * 0.25
    tick_key = ["mt_place_metal_1", "mt_place_metal_2", "mt_dug_metal_1", "mt_metal_footstep_2"][int(rng.integers(4))]
    tick = slice_(dsp.pitch(hit(tick_key), rng.uniform(10, 17)), 0.0, 0.12, 0.08)
    out = np.zeros_like(ring)
    out[: len(tick)] += dsp.highpass(tick, 1800)[: len(out)] * 0.8
    out += ring
    return dsp.balance(out, rng.uniform(-0.6, 0.6))


def coins(count: int, seconds: float, rng, darker: bool = False) -> np.ndarray:
    bus = Bus(seconds + 0.4)
    times = np.sort(rng.beta(1.3, 3.0, count) * seconds)
    for index, at in enumerate(times):
        bus.add(coin(rng), at, -index * 0.6 + rng.normal(0, 2))
    out = bus.render()
    return dsp.lowpass(out, 5200) if darker else out


def paper(seconds: float, rng, density: float = 160) -> np.ndarray:
    """Heavy paper: crackle impulses in a band, over a real shaker grain."""
    n = int(seconds * SR)
    crackle = np.zeros((n, 2), dtype=np.float32)
    for at in rng.uniform(0, seconds, int(density * seconds)):
        i = int(at * SR)
        length = int(rng.uniform(0.002, 0.012) * SR)
        if i + length < n:
            crackle[i: i + length] += rng.standard_normal((length, 2)) * np.hanning(length)[:, None] * rng.uniform(0.2, 1)
    body = dsp.bandpass(noise(seconds, rng), 700, 5000) * np.hanning(n)[:, None] * 0.6
    grain = dsp.bandpass(hit("shaker_Mid_ShakerDouble_Down_rr1"), 900, 7000)
    out = dsp.bandpass(crackle, 1200, 7500) + body
    grain = grain[:n]
    out[: len(grain)] += grain * 0.7
    return out * envelope(n, 0.01, seconds * 0.6)


def sizzle(seconds: float, rng) -> np.ndarray:
    """The brand cooling: real fire crackle, high-passed, over a falling hiss."""
    fire = dsp.highpass(slice_(dsp.load("mt_fire_2"), 0.4, seconds, 0.3), 2500)
    hiss = dsp.bandpass(noise(seconds, rng), 3000, 9000)
    n = min(len(fire), len(hiss))
    return (fire[:n] * 1.4 + hiss[:n] * 0.5) * envelope(n, 0.005, seconds * 0.35)


def voices(seconds: float, rng, rise: bool = True, count: int = 14, pitch_shift: float = 0.0) -> np.ndarray:
    from compose import murmur
    crowd = murmur(seconds, rng, voices=count)
    if pitch_shift:
        crowd = dsp.pitch(crowd, pitch_shift)[: len(crowd)]
    n = len(crowd)
    curve = np.linspace(0.2, 1.0, n) ** 1.5 if rise else np.linspace(1.0, 0.1, n) ** 1.2
    return crowd * curve[:, None] * np.hanning(n)[:, None] ** 0.3


def choir(semitones: float, seconds: float) -> np.ndarray:
    tone = dsp.pitch(dsp.load("sp_ambi_choir"), semitones)
    return dsp.cut(dsp.lowpass(tone, 2400), seconds, release=min(0.6, seconds / 2))


def scrape(key: str, start: float, seconds: float, semis: float, low=1500, high=7000) -> np.ndarray:
    return dsp.bandpass(slice_(dsp.pitch(dsp.load(key), semis), start, seconds, 0.05), low, high)


def stomps(count: int, seconds: float, rng, people: int = 10) -> np.ndarray:
    from compose import crowd_stomp
    bus = Bus(seconds + 1.5)
    for at in np.sort(rng.uniform(0, seconds, count)):
        bus.add(crowd_stomp(people, rng), at, rng.normal(0, 1.5))
    return bus.render()


def applause(seconds: float, rng, density: float = 22.0, people_per_burst: int = 3) -> np.ndarray:
    from compose import crowd_clap
    bus = Bus(seconds + 1.2)
    total = int(seconds * density)
    for at in np.sort(rng.uniform(0, seconds, total)):
        shape = np.sin(np.pi * min(1.0, at / seconds)) ** 0.6
        bus.add(crowd_clap(people_per_burst, rng, spread=0.01), at, -14 * (1 - shape) + rng.normal(0, 2), rng.uniform(-0.8, 0.8))
    return bus.render()


def tick(semis: float) -> np.ndarray:
    wood = dsp.cut(dsp.pitch(hit("woodblock_wood_click_pp_rr1"), semis), 0.05, 0.03)
    sand = dsp.cut(dsp.pitch(hit("mt_sand_footstep_1"), 5), 0.03, 0.02)
    out = dsp.silence(0.09)
    out[: len(wood)] += dsp.lowpass(wood, 6500)[: len(out)]
    out[: len(sand)] += dsp.highpass(sand, 2000)[: len(out)] * db(-10)
    return out


# Each cue: (builder, family, recipe). Families set loudness; see LEVELS.
def build_cues(rng_for):
    room = dsp.room_ir(0.9, 1.6, 3200, ROOM_SEED)
    arena = dsp.room_ir(2.2, 3.0, 2400, ROOM_SEED + 1)
    cues = {}

    def cue(name, family, recipe, stereo=False):
        def wrap(fn):
            cues[name] = (fn, family, recipe, stereo)
            return fn
        return wrap

    @cue("button_hover", "focus", "woodblock tick pitched up, grain of sand")
    def _(rng):
        return tick(7)

    @cue("cursor_move", "focus", "woodblock tick a fourth lower than hover, grain of sand")
    def _(rng):
        return tick(4)

    @cue("button_click", "confirm", "woodblock and a stone tap from gravel, soft frame-drum body")
    def _(rng):
        b = Bus(0.4)
        b.add(dsp.cut(dsp.pitch(hit("woodblock_wood_click_mp"), 2), 0.12), 0, 0, 0, -16)
        b.add(dsp.cut(dsp.pitch(hit("mt_gravel_dug_1"), 3), 0.08), 0.004, -9, 0, -18)
        b.add(dsp.cut(hit("frame_HDrumS_HitMuted_v3_rr1"), 0.15), 0, -14, 0, -18)
        return b.render(room)

    @cue("cursor_select", "confirm", "woodblock with a small Nepalese bell, a fifth down")
    def _(rng):
        b = Bus(0.6)
        b.add(dsp.cut(dsp.pitch(hit("woodblock_wood_click_mp"), 0), 0.12), 0, 0, 0, -16)
        b.add(dsp.cut(dsp.pitch(hit("handbell_HB_2"), -7), 0.35, 0.2), 0.01, -13, 0.1, -10)
        return b.render(room)

    @cue("player_damage", "heavy", "the scar: anvil a fifth down, bass drum, fire sizzle cooling")
    def _(rng):
        b = Bus(1.4)
        b.add(dsp.cut(dsp.pitch(hit("anvil_Anvil_Hit1_v3_rr1"), -7), 0.9, 0.4), 0, -2, 0, -12)
        b.add(dsp.cut(dsp.lowpass(hit("bassdrum_bassdrum_hit_f"), 160), 0.8, 0.3), 0, -1, 0, -14)
        b.add(sizzle(1.1, rng), 0.03, -9, 0, -16)
        return b.render(room)

    @cue("enemy_hit", "confirm", "legacy alias: stone crack and frame drum tek")
    def _(rng):
        b = Bus(0.5)
        b.add(dsp.cut(hit("mt_dig_cracky_1"), 0.2), 0, -2, 0, -12)
        b.add(dsp.cut(hit("frame_HDrumS_HitMuted_v3_rr1"), 0.2), 0, -6, 0, -12)
        return b.render(room)

    @cue("enemy_death", "ritual", "legacy alias: gravel settling over a low timpani")
    def _(rng):
        b = Bus(1.2)
        for i, at in enumerate((0, 0.07, 0.16)):
            b.add(dsp.pitch(hit(f"mt_gravel_dug_{i + 1}"), -5), at, -4 - 3 * i, 0.2 * (i - 1), -10)
        b.add(dsp.cut(dsp.pitch(hit("timp_Timpani3_Hit_v2_rr1"), 0.6), 0.9, 0.3), 0, -4, 0, -12)
        return b.render(room)

    @cue("pickup", "ritual", "wax tablet set down: slapstick, muted frame drum, guiro wax grain")
    def _(rng):
        b = Bus(0.7)
        b.add(dsp.lowpass(hit("slapstick_quiet_rr1"), 3500), 0, -3, 0, -12)
        b.add(dsp.cut(hit("frame_HDrumL_HitMuted_v3_rr2"), 0.35), 0.002, -4, 0, -12)
        b.add(scrape("guiro_guiro_short", 0.0, 0.18, 5), 0.06, -14, 0.2, -10)
        return b.render(room)

    @cue("level_up", "ritual", "SPINGI LA SORTE opens: timpani roll on D swelling, gravel shift, muted stop")
    def _(rng):
        b = Bus(1.8)
        roll = dsp.pitch(hit("timp_roll_1_v3"), -3)
        swell = dsp.fade(roll[: int(1.3 * SR)], 1.2, 0.05)
        b.add(swell, 0, -2, 0, -10)
        b.add(dsp.cut(hit("frame_HDrumL_HitMuted_v3_rr2"), 0.3), 1.3, -2, 0, -10)
        b.add(dsp.pitch(hit("mt_gravel_dig_2"), -6), 1.28, -10, 0.3, -10)
        return b.render(arena)

    @cue("stage_complete", "ritual", "frame drum and Nepalese bell")
    def _(rng):
        b = Bus(1.6)
        b.add(hit("frame_HDrumL_Hit_v3_rr1"), 0, -4, 0, -10)
        b.add(dsp.cut(hit("handbell_HB_1"), 1.2, 0.5), 0.02, -8, 0.2, -6)
        return b.render(arena)

    @cue("game_over", "heavy", "low gong and bass drum, long settle")
    def _(rng):
        b = Bus(3.0)
        b.add(dsp.cut(dsp.pitch(hit("gong_p"), -3), 2.4, 1.2), 0, -1, 0, -8)
        b.add(dsp.cut(dsp.lowpass(hit("bassdrum_bassdrum_hit_mf1"), 200), 1.5, 0.8), 0, -3, 0, -12)
        return b.render(arena)

    @cue("registry_receipt_take", "ritual", "INCASSA: coins into a pouch, paper folded, stamp")
    def _(rng):
        b = Bus(1.5)
        b.add(coins(7, 0.28, rng), 0, -1, 0, -16)
        b.add(dsp.cut(dsp.lowpass(hit("frame_HDrumS_HitMuted_v2_rr1"), 900), 0.2), 0.26, -4, 0, -14)
        b.add(paper(0.16, rng), 0.3, -9, 0.1, -14)
        b.add(dsp.cut(dsp.pitch(hit("woodblock_wood_click_f_rr1"), -6), 0.2), 0.46, -4, 0, -12)
        b.add(dsp.cut(hit("frame_HDrumL_HitMuted_v3_rr2"), 0.3), 0.46, -5, 0, -12)
        return b.render(room)

    @cue("registry_condemnation_mark", "heavy", "the marchio: heavy anvil, bass drum, brand sizzle, stone settling")
    def _(rng):
        b = Bus(1.8)
        b.add(dsp.cut(dsp.pitch(hit("anvil_Anvil_Hit3_v3_rr1"), -9), 1.2, 0.5), 0, -1, 0, -10)
        b.add(dsp.cut(dsp.lowpass(hit("bassdrum_bassdrum_hit_f"), 140), 1.2, 0.5), 0, 0, 0, -12)
        b.add(sizzle(1.4, rng), 0.05, -8, 0, -14)
        b.add(dsp.pitch(hit("mt_gravel_dug_2"), -8), 0.12, -12, -0.2, -10)
        return b.render(room)

    @cue("registry_second_incision", "ritual", "RADDOPPIA: two stylus strokes in wax, darbuka pulse quickening, small bronze")
    def _(rng):
        b = Bus(1.4)
        b.add(scrape("guiro_Guiro_Fast_rr1_Mid", 0.05, 0.15, 3), 0, -2, -0.2, -12)
        b.add(scrape("guiro_Guiro_Fast_rr1_Mid", 0.3, 0.14, 5), 0.16, -1, 0.2, -12)
        for i, at in enumerate((0.32, 0.42, 0.5, 0.56)):
            b.add(hit("darbuka_2_vl1" if i < 3 else "darbuka_1_vl2"), at, -10 + 2.5 * i, 0, -12)
        b.add(dsp.cut(dsp.pitch(hit("handbell_HB_2"), -5), 0.3, 0.15), 0.56, -8, 0.1, -8)
        return b.render(room)

    @cue("arena_threshold_cross", "ritual", "entering the arena: stone grind, step on sand, distant gradinata, bronze")
    def _(rng):
        b = Bus(2.6)
        grind = np.concatenate([dsp.pitch(hit(f"mt_gravel_dig_{i}"), -9) for i in (1, 2)])
        b.add(dsp.lowpass(grind, 2500), 0, -4, -0.2, -10)
        b.add(hit("mt_sand_footstep_2"), 0.3, -6, 0.1, -8)
        b.add(hit("mt_sand_footstep_3"), 0.5, -8, -0.1, -8)
        b.add(voices(0.7, rng, rise=True, count=10), 0.15, -12, 0, -2)
        b.add(dsp.cut(dsp.pitch(hit("handbell_HB_1"), -12), 0.4, 0.2), 0.42, -10, 0.2, -4)
        return b.render(arena)

    @cue("registry_table_open", "ritual", "stone slab sliding, bronze hinge, settle")
    def _(rng):
        b = Bus(1.4)
        slab = np.concatenate([dsp.pitch(hit(f"mt_gravel_dug_{i}"), -11) for i in (1, 2)])
        b.add(dsp.lowpass(slab, 1800), 0, -3, 0, -12)
        b.add(dsp.cut(dsp.pitch(hit("mt_place_metal_1"), -5), 0.3), 0.15, -10, 0.3, -12)
        b.add(dsp.cut(dsp.pitch(hit("timp_Timpani3_Hit_v2_rr1"), 0.6), 0.4, 0.2), 0.5, -6, 0, -12)
        return b.render(room)

    @cue("registry_promise_sign", "ritual", "stylus in wax, short bronze impression")
    def _(rng):
        b = Bus(0.8)
        b.add(scrape("guiro_Guiro_Slow_rr2_Mid", 0.1, 0.32, 7, 2000, 9000), 0, 0, 0, -14)
        b.add(dsp.cut(dsp.pitch(hit("mt_place_metal_2"), 3), 0.18), 0.34, -7, 0.1, -12)
        return b.render(room)

    @cue("registry_pact_validate", "ritual", "the pact sealed: tablet set down, bronze bell on D")
    def _(rng):
        b = Bus(1.6)
        b.add(dsp.lowpass(hit("slapstick_rr2"), 2800), 0, -4, 0, -12)
        b.add(dsp.cut(hit("frame_HDrumL_HitMuted_v3_rr2"), 0.4), 0, -3, 0, -12)
        b.add(dsp.cut(hit("tubular_chimes_D3_pp_rr3"), 1.0, 0.5), 0.03, -5, 0.1, -6)
        return b.render(room)

    @cue("arena_gesture_placa", "ritual", "PLACA: token laid on sand, the gradinata breathes out")
    def _(rng):
        b = Bus(1.6)
        b.add(hit("mt_sand_footstep_1"), 0, -3, 0, -10)
        b.add(dsp.pitch(hit("mt_sand_footstep_3"), -3), 0.1, -8, 0.1, -10)
        b.add(voices(0.7, rng, rise=False, count=12), 0.08, -8, 0, -2)
        return b.render(arena)

    @cue("arena_gesture_provoca", "ritual", "PROVOCA: scrape in the sand, stone and bronze strike, the gradinata jolts")
    def _(rng):
        b = Bus(1.6)
        b.add(dsp.pitch(hit("mt_sand_footstep_2"), -6), 0, -4, -0.2, -10)
        b.add(scrape("guiro_Guiro_Hit_rr1_Mid", 0.0, 0.2, -3, 800, 5000), 0.02, -9, -0.2, -10)
        b.add(dsp.cut(hit("mt_dig_cracky_2"), 0.25), 0.2, -3, 0, -10)
        b.add(dsp.cut(dsp.pitch(hit("anvil_Anvil_Hit2_v2_rr1"), -5), 0.5, 0.3), 0.2, -9, 0, -8)
        b.add(voices(0.5, rng, rise=True, count=12), 0.25, -7, 0, -2)
        return b.render(arena)

    @cue("registry_judgment_seal_strike", "heavy", "seal strike: anvil, timpani on D, stone crack")
    def _(rng):
        b = Bus(1.2)
        b.add(dsp.cut(dsp.pitch(hit("anvil_Anvil_Hit3_v3_rr1"), -4), 0.7, 0.4), 0, -3, 0, -10)
        b.add(dsp.cut(dsp.pitch(hit("timp_Timpani3_Hit_v3_rr1"), 0.6), 0.8, 0.4), 0, -2, 0, -12)
        b.add(dsp.cut(hit("mt_dig_cracky_3"), 0.25), 0.01, -6, 0.15, -10)
        return b.render(room)

    @cue("registry_judgment_seal_resolve", "heavy", "third strike: timpani low A, gong, anvil, wax pressed shut")
    def _(rng):
        b = Bus(2.4)
        b.add(dsp.cut(dsp.pitch(hit("timp_Timpani3_Hit_v3_rr1"), -4.4), 1.6, 0.6), 0, -1, 0, -10)
        b.add(dsp.cut(dsp.pitch(hit("anvil_Anvil_Hit1_v3_rr1"), -10), 1.0, 0.5), 0, -5, 0, -10)
        b.add(dsp.cut(hit("gong_mf"), 2.0, 1.0), 0.01, -9, 0, -6)
        b.add(scrape("guiro_Guiro_Hit_rr1_Mid", 0.0, 0.2, -5, 500, 4000), 0.35, -12, 0.2, -10)
        return b.render(room)

    @cue("registry_dossier_update", "ritual", "fascicolo: heavy paper turned, wooden stamp")
    def _(rng):
        b = Bus(0.9)
        b.add(paper(0.28, rng), 0, -3, -0.1, -14)
        b.add(dsp.cut(dsp.pitch(hit("woodblock_wood_click_f_rr1"), -7), 0.2), 0.3, -4, 0, -12)
        b.add(dsp.cut(hit("frame_HDrumS_HitMuted_v3_rr1"), 0.2), 0.3, -6, 0, -12)
        return b.render(room)

    @cue("registry_dossier_close", "heavy", "fascicolo closed: board and tablet shut, timpani, seal")
    def _(rng):
        b = Bus(2.0)
        b.add(paper(0.16, rng, density=90), 0, -9, 0, -12)
        b.add(dsp.lowpass(hit("slapstick_rr2"), 2200), 0.12, -3, 0, -10)
        b.add(dsp.cut(dsp.pitch(hit("timp_Timpani3_Hit_v3_rr1"), 0.6), 0.6, 0.3), 0.12, -2, 0, -10)
        b.add(dsp.cut(dsp.pitch(hit("anvil_Anvil_Hit1_v3_rr1"), -12), 0.5, 0.3), 0.14, -11, 0, -10)
        return b.render(room)

    @cue("registry_dossier_route", "confirm", "tab lifted, page drawn")
    def _(rng):
        b = Bus(0.6)
        b.add(paper(0.28, rng, density=110), 0, -2, 0.1, -16)
        b.add(dsp.lowpass(hit("sp_perc_swoosh"), 5000), 0.05, -14, 0, -16)
        return b.render(room)

    # --- new cues for the gradinata and the ledger -------------------------

    @cue("crowd_favor_up", "crowd", "Favore rises: scattered claps, voices lifting, a low 'ooh'", stereo=True)
    def _(rng):
        b = Bus(2.4)
        b.add(applause(1.4, rng, density=14), 0.1, -3, 0, -2)
        b.add(voices(1.8, rng, rise=True), 0, -6, 0, -2)
        b.add(choir(-5, 1.2), 0.15, -16, 0, -2)
        return b.render(arena)

    @cue("crowd_favor_down", "crowd", "Favore falls: a low grumble and a few stamps", stereo=True)
    def _(rng):
        b = Bus(2.2)
        b.add(voices(1.8, rng, rise=True, pitch_shift=-3), 0, -4, 0, -2)
        b.add(stomps(3, 0.9, rng, people=6), 0.3, -6, 0, -4)
        b.add(choir(-10, 1.0), 0.2, -18, 0, -2)
        return b.render(arena)

    @cue("crowd_triumph", "crowd_big", "LA GRADINATA TI PORTA: full applause, stomps, voices, gong", stereo=True)
    def _(rng):
        b = Bus(4.2)
        b.add(applause(3.4, rng, density=40, people_per_burst=4), 0.05, -1, 0, -2)
        b.add(stomps(6, 1.6, rng, people=12), 0.0, -5, 0, -4)
        b.add(voices(3.0, rng, rise=True, count=20), 0.0, -4, 0, -2)
        b.add(dsp.cut(hit("gong_p"), 2.5, 1.2), 0.0, -12, 0, -6)
        return b.render(arena)

    @cue("crowd_riot", "crowd_big", "LA GRADINATA SI RIVOLTA: stamping, uproar, a bronze thrown on stone", stereo=True)
    def _(rng):
        b = Bus(3.4)
        b.add(stomps(14, 2.6, rng, people=14), 0, -2, 0, -4)
        b.add(voices(3.0, rng, rise=True, count=22, pitch_shift=-2), 0, -2, 0, -2)
        b.add(dsp.cut(dsp.lowpass(hit("bassdrum_bassdrum_hit_f"), 150), 1.2, 0.5), 0, -4, 0, -10)
        b.add(dsp.pitch(hit("mt_dug_metal_2"), -7), 0.9, -9, 0.4, -6)
        return b.render(arena)

    @cue("coins_gain", "crowd", "Denari in: a handful of small bronze coins into Vessa's pouch", stereo=True)
    def _(rng):
        b = Bus(1.0)
        b.add(coins(7, 0.45, rng), 0, 0, 0, -16)
        b.add(dsp.cut(dsp.lowpass(hit("frame_HDrumS_HitMuted_v2_rr1"), 700), 0.2), 0.36, -6, 0, -14)
        return b.render(room)

    @cue("coins_loss", "crowd", "Denari out: coins slide away on stone, the pouch falls slack", stereo=True)
    def _(rng):
        b = Bus(1.1)
        b.add(coins(4, 0.35, rng, darker=True), 0, -2, 0.2, -14)
        b.add(dsp.pitch(hit("mt_gravel_dug_3"), -7), 0.05, -12, 0.2, -12)
        b.add(dsp.cut(dsp.lowpass(hit("frame_HDrumL_HitMuted_v2_rr1"), 500), 0.3), 0.45, -4, 0, -12)
        return b.render(room)

    @cue("bando_closed", "crowd_big", "BANDO CHIUSO: Orvo's bell, coins, frame drum, the gradinata applauds", stereo=True)
    def _(rng):
        b = Bus(3.0)
        b.add(dsp.cut(hit("handbell_HB_1"), 2.0, 0.8), 0, -4, 0.2, -6)
        b.add(hit("frame_HDrumL_Hit_v3_rr2"), 0, -6, 0, -10)
        b.add(coins(10, 0.7, rng), 0.25, -6, 0, -14)
        b.add(applause(1.6, rng, density=18), 0.5, -8, 0, -2)
        return b.render(arena)

    @cue("terminal_heartbeat", "terminal", "Assenza: one double heartbeat from a soft bass drum, every 3 s")
    def _(rng):
        out = dsp.silence(3.0)
        beat = dsp.cut(dsp.lowpass(hit("bassdrum_bassdrum_hit_pp1"), 110), 0.55, 0.25)
        out[: len(beat)] += beat
        second = beat * db(-5)
        start = int(0.32 * SR)
        out[start: start + len(second)] += second[: len(out) - start]
        return dsp.fade(out, 0.0, 0.05)

    return cues


# Momentary loudness targets (dB RMS of the loudest 300 ms) by family.
LEVELS = {"focus": -29.0, "confirm": -22.0, "ritual": -16.0, "heavy": -13.5, "crowd": -16.0, "crowd_big": -13.5, "terminal": -22.0}
# Object-first gestures are short by contract (scripts/ci/test_*_object_contract.py):
# the cue ends inside its window, the gradinata's answer comes as its own cue.
MAX_SECONDS = {
    "registry_receipt_take": 0.76, "registry_condemnation_mark": 0.76, "registry_second_incision": 0.72,
    "arena_threshold_cross": 0.82, "registry_table_open": 0.92, "registry_promise_sign": 0.68,
    "registry_pact_validate": 0.78, "arena_gesture_placa": 0.82, "arena_gesture_provoca": 0.82,
    "registry_judgment_seal_strike": 0.72, "registry_judgment_seal_resolve": 0.82,
    "registry_dossier_update": 0.68, "registry_dossier_close": 0.78, "registry_dossier_route": 0.72,
}
