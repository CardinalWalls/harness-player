# Test Spec — CDDA MoonBit Native Contract Rebuild

## Acceptance Criteria
1. Wrong adapter-backed implementation files are deleted.
2. MoonBit module exists and passes `moon check`.
3. MoonBit tests pass with `moon test`.
4. The domain model supports:
   - canonical channel identity
   - repeated channel references across sections
   - relation section composition
5. Section rendering state can represent more than five sections.
6. At least one test proves the same channel appears in multiple sections without becoming multiple channels.
7. New prompt assets describe separate writer roles and explicitly forbid adapter-backed synthesis.

## Verification Commands
- `moon check`
- `moon test`
- `moon fmt --check` if supported, else `moon fmt`
- shell verification that deleted wrong files are gone

## Core Test Cases
### T1 — canonical channel identity
Construct one canonical channel and reference it in 3 sections; verify the same id is reused.

### T2 — section pair model
Each section must hold exactly two participants plus relation metadata.

### T3 — relation explanation metadata
Every section includes contract kind and human-readable explanation.

### T4 — more-than-five sections
The registry can produce 6+ sections without structural change.

### T5 — no adapter-backed residue
The removed implementation files do not exist after cleanup.
