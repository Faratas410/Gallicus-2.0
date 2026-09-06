# REGISTRY SYSTEM SPECIFICATION

## Status
CANON (FOUNDATIONAL EXTENSION)

## Category
SYSTEMIC LORE + INTERPRETIVE MECHANICS (Non-Phase, Non-Authority)

## Stratified Convergence Model (Finite)

## 1. Purpose

This document formalizes:

- The finite stratification of the Register (4 Eras)
- The behavior signature model
- Signature fixation with hysteresis
- Era ramp mechanics (invisible transition)
- Era 3 compression behavior
- Silence escalation logic
- Terminal absence state
- Structural non-loopability
- Non-farmability guarantees
- Indirect fixation–Silence relationship
- Ontological constraints on compression

This specification does NOT:

- Redefine Run phases
- Introduce new managers
- Alter reward economy
- Override existing mechanical contracts
- Change authority ownership

The system remains centralized under Single RunManager authority.

## 2. Finite Structure

The Register evolves through four stratified Eras.

Range:

```text
registry_era: int
0 → 3
```

After Era 3 Silence:

```text
registry_era = 4
```

Era 4 represents Absence of Register.

Total structure is finite.
No additional Eras may be added without canon amendment.

Era progression is strictly monotonic.
No reset, recursion, or hidden cycle is permitted.

## 3. Era Transition Model

Era transitions are:

- Triggered exclusively by Silence
- Persisted in meta-save
- Not declared in UI
- Not labeled in runtime

Each Era change includes a 3-run invisible ramp:

```text
era_progress ∈ {0.33, 0.66, 1.00}
```

Effects scale gradually during first three runs after transition.

No immediate visible shift is permitted.

## 4. Behavior Signature Model

Each run tracks a multidimensional signature:

```text
behavior_signature {
    risk_bias: float (-1.0 → +1.0)
    repetition_bias: float (0.0 → 1.0)
    scar_tolerance: float (0.0 → 1.0)
    volatility: float (0.0 → 1.0)
}
```

Signature is:

- Internal only
- Not displayed
- Not unlockable
- Not reward-linked

## 5. Signature Coherence

Derived value:

```text
signature_coherence =
    (abs(risk_bias) * w1) +
    (repetition_bias * w2) +
    (scar_tolerance * w3) -
    (volatility * w4)
```

Normalized 0 → 1.

Signature becomes FIXED when:

- coherence > threshold
- for 2 consecutive runs

## 6. Hysteresis (Irreversibility Model)

Entry threshold > Exit threshold.

Example structure:

- Enter fixed: > 0.72
- Exit fixed: < 0.40

When fixed:

- Smoothing becomes conservative
- Signature becomes resistant to reversal

Reversal is possible but rare and slow.

This preserves inevitability without absolute lock.

## 7. Linguistic State Shift (When Fixed)

When signature is fixed:

Register language becomes:

- Impersonal
- Definitive
- Shorter
- Non-speculative

Removed elements:

- Modal verbs
- Conditional phrasing
- Ambiguity markers

Register does not accuse.
Register does not dramatize.
Register concludes.

If signature returns to liquid state, ambiguity may return.

## 8. Era Effects Matrix (Structural)

### ERA 0 — Intact

- Neutral convergence
- Full linguistic density
- Balanced offer structure

### ERA 1 — Rigid

- Increased signature gravity
- Slight offer polarization
- Reduced linguistic ambiguity
- Faster interpretive convergence

### ERA 2 — Unstable

- Controlled asymmetry in offer structure
- Reduced lexical coherence
- Non-linear convergence peaks
- Rare structural irregularities

No new mechanics introduced.

### ERA 3 — Terminal

- Rarefied language
- Minimal commentary
- Aggressive interpretive compression
- Elevated Silence proximity

When signature is fixed:

Occasional compression event allowed:

Two semantically distinct offers
→ Ontologically convergent outcomes
→ Deterministic
→ Never majority frequency
→ Never economy-altering

Compression represents structural exhaustion, not deception.

## 9. Silence Logic

Silence occurs when:

- Signature stability exceeds era-modified threshold
- Convergence conditions satisfied
- Deterministic saturation confirmed

Silence:

- Ends run
- Emits no classificatory statement
- Increments registry_era

Silence is never framed as victory or defeat.

## 10. Era 4 — Absence of Register

Triggered after Silence in Era 3.

Effects:

- No classificatory logic initialized
- No Silence possible
- No new convergence
- No linguistic evaluation

The system ceases classification.

No destruction event.
No liberation rhetoric.
No villain resolution.

Only cessation.

Era 4 is terminal and non-reversible.

## 11. Final State Behavior

Final state includes:

- Determined movement of non-classified subjects
- No identifiable protagonist
- Absence of structural commentary
- Terminal black frame
- Single slow heartbeat
- End

System remains finite and closed.

No post-final replay state may reinitialize the Register.

## 12. Integration Constraints

This specification:

- Does not alter phase enums
- Does not introduce additional authority layers
- Does not duplicate managers
- Does not override Run flow
- Does not redefine Scar, Silence, Pact, or Arena

All changes are parametric and interpretive.

## 13. Acceptance Criteria

- registry_era bounded 0..4
- Era transitions triggered only by Silence
- 3-run ramp enforced
- Signature fixation requires 2 consecutive stability confirmations
- Hysteresis thresholds distinct
- Era 3 compression deterministic and < 20% frequency
- No UI explicitly names Eras
- No reward or payout modification tied to signature or era
- No flow alteration required

## 14. Stop Conditions

Implementation must halt immediately if:

- Additional managers are introduced
- Flow authority is duplicated
- Reward economy is altered by era
- Silence becomes farmable
- Era becomes visible as mode
- Signature becomes UI-readable
- Compression affects outcome probability

## 15. Non-Loopability and Structural Finality

The Stratified Convergence Model is explicitly non-cyclical.

- Era progression is strictly monotonic (0 → 4)
- No reset to Era 0 is permitted
- No post-final “New Game+” state may reinitialize the Register
- No hidden recursion or seasonal cycling allowed

The structure is finite by canon definition.

## 16. Non-Farmability of Silence

Silence is emergent and cannot be targeted intentionally.

- No visible counters toward Silence
- No rewards attached to triggering Silence
- Silence must not be optimizable through deterministic strategy alone
- Silence arises from saturation, not pursuit

If Silence becomes farmable, implementation must halt.

## 17. Indirect Causality Between Fixation and Silence

Signature fixation does not directly trigger Silence.

Fixation:

- Alters interpretive compression
- Modifies offer structure
- Increases interpretive certainty

Silence requires additional saturation conditions.

Fixation increases proximity to Silence but does not guarantee it.

The relationship is multi-factorial and structural, not binary.

## 18. Ontological Nature of Compression (Era 3)

Compression events represent structural exhaustion of interpretive space.

They are:

- Deterministic
- Systemic
- Non-adversarial
- Non-deceptive

Compression does not manipulate probabilities.
Compression does not remove agency.
Compression does not alter rewards.

It reflects diminishing interpretive diversity as terminal convergence approaches.

Any use of compression as hidden manipulation violates canon.

## 19. Micro Interpretive Quick Cut (Era 2–3 Runtime Hook)

Quick Cut is a deterministic, transient interpretive interruption integrated into the existing runtime transition between outcome resolution and next phase progression.

Trigger contract:

- Active only when effective registry era is 2 or 3
- Never active in Era 4 (Absence)
- Never active during Silence
- Never active during the first two runs of an era transition ramp

Activation probability (controlled random per run instance):

- Era 2: 25%
- Era 3: 45%
- Era 3 with fixed signature stability: 60%

Quick Cut is never guaranteed and never reaches 100% activation.

Flow integration constraints:

- Quick Cut is NOT a new phase
- It is inserted as an optional transient interruption inside existing Resolve → Next Phase progression
- No phase enum changes
- No new manager
- No duplicated authority

Single RunManager authority remains intact.

Visual contract:

- Hard cut style (no slow fade)
- ~80ms buffer after resolve
- Immediate full-screen interpretive interruption
- Duration bounded to 0.8–1.2 seconds (hard maximum 1.5 seconds)
- Immediate return to normal flow after hold

Background treatment (Choice D):

- Arena remains visible
- Desaturation constrained to 70–85%
- Luminance reduction constrained to <=15%
- No blur
- No vignette
- No camera shake

Text layer:

- Single centered sentence
- Maximum 60 characters
- No multiline rendering
- No exclamation marks
- Tone adaptive by era (analytical in Era 2, definitive in Era 3)

Micro glitch rules:

- At most one micro glitch effect per Quick Cut event
- Allowed: 1px text shift, 1px character offset, micro opacity jitter, single-frame kerning compression
- Disallowed: RGB split, heavy distortion, repeated flicker, audio glitch

Special condition (Era 3 + advanced fixation):

- Optional no-text Quick Cut (desaturated hold only)
- One-second hold
- No glitch
- Frequency capped to <=15% of Era 3 Quick Cuts

Input handling:

- Input disabled for the whole Quick Cut interval
- No skip interaction
- Input resumes immediately on return

Mechanical invariants:

- No payout logic changes
- No offer probability changes
- No outcome resolution changes
- No direct Silence acceleration
- No signature formula changes

Quick Cut remains interpretive-only.

END OF SPECIFICATION

## Runtime Alignment Addendum (September 2026)

Profile v5 adds meta.registry_evolution; defaults and migration are in
`docs/data_schema.md`. Pressure remains diagnostic history, not a random
Silence roll or an era threshold. The former rare random roll is removed.
RunManager derives each sample from completed pact history:

- risk = (Hubris + Violence - Prudence - Penitence) / pact count;
- repetition = largest path count / pact count;
- scar tolerance = scar history count / arena count, clamped to 0..1;
- volatility = 1 - repetition.

Coherence weights are 0.40, 0.35, 0.25 and -0.20. The first sample seeds the
signature; later smoothing is 0.30 liquid, 0.08 fixed. Entry requires >0.72
for two runs; exit <0.40. Saturation requires all of: fixed signature; three
stable samples (mean axis distance <0.16 + era*0.02); at least 8/7/6/5 runs in
eras 0/1/2/3; three distinct fingerprints; three observed path families; three
consecutive equal ending identities. Fingerprints contain path counts, glory,
corruption and double count. Identical repetition alone cannot advance.
These development parameters require human balance and anti-farming validation;
accelerated fixtures do not certify a 2-4 hour campaign.

Silence increments era once and resets era history and ramp. The next three
runs expose strengths 1/3, 2/3, 1; Quick Cut is blocked in the first two.
With fixed signature, bounded offer affinity applies only to selection
weights within eligibility. Rewards, result odds and outcome values do not
change. Optional ontological outcome compression is not implemented.

Intermediate Silence shows black without classification; after two seconds
menu return becomes available. Era 4 shows black and a slow original heartbeat,
persists across restart, blocks new/continued runs and initializes no
RegisterState. Non-classified movement and full audiovisual staging remain
open production work. Linux checkpoint, human duration, anti-farming and
audiovisual acceptance are still required; no release gate is closed here.
