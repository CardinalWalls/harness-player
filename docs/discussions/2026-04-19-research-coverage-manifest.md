# Research Coverage Manifest

## Purpose

This document closes a process gap discovered during OMX planning:

- research notes were created faster than they were explicitly consumed by planning inputs

This manifest records, for each tracked discussion artifact:

- whether it is directly consumed by planning
- whether it is indirectly represented by another document
- whether it is mainly a derived/organizational artifact
- whether any follow-up integration is still needed

## Coverage states

- `direct` — explicitly consumed by current planning input
- `indirect` — not named directly, but its content is folded into another consumed document
- `derived` — organizational or transitional artifact, useful but not required as a primary planning input
- `missing` — should be integrated into planning input but currently is not

## Current coverage map

| File | State | Notes |
| --- | --- | --- |
| `README.md` | `direct` | index for discussion corpus |
| `2026-04-19-architecture-research-report.md` | `direct` | primary research synthesis |
| `2026-04-19-moonbit-native-candidates-matrix.md` | `direct` | primary MoonBit/reuse split input |
| `2026-04-19-synthesis-method-from-test-assets.md` | `direct` | primary synthesis-method input |
| `2026-04-19-test-assets-and-mock-boundaries.md` | `direct` | primary test-asset and mock-boundary input |
| `2026-04-19-per-source-extraction-notes.md` | `direct` | primary extraction plan input |
| `2026-04-19-seed-rules-reference.md` | `direct` | primary rules input |
| `2026-04-19-seed-asset-corpus-candidates.md` | `direct` | primary corpus input |
| `2026-04-19-seed-mock-boundaries.md` | `direct` | primary mock input |
| `2026-04-19-interview-handoff-note.md` | `direct` | primary handoff artifact |
| `2026-04-19-omx-interview-summary.md` | `indirect` | summarized into handoff and architecture report |
| `2026-04-19-software-synthesis-subject-comparison.md` | `indirect` | folded into architecture report |
| `2026-04-19-phase-ordering-for-all-four-centers.md` | `indirect` | folded into execution-plan sequencing |
| `2026-04-19-extraction-rules-and-quality-grading.md` | `indirect` | folded into per-source extraction notes and seed docs |
| `2026-04-19-first-wave-concrete-asset-sources.md` | `indirect` | folded into per-source extraction notes |
| `2026-04-19-first-extraction-batch-plan.md` | `derived` | transitional execution prep for research phase |
| `2026-04-19-interview-stage-work-plan.md` | `derived` | stage tracking, not a core planning input |

## Process correction

The correct OMX best-practice rule from this point onward is:

- every new research document must either:
  - become a direct planning input
  - be marked as indirect with a named parent document
  - be marked as derived/organizational

This avoids silent drift between:

- what research exists
- what planning actually consumes

## Current judgment

There are no critical research documents currently in the `missing` state.

The real issue was not missing substance.
The issue was missing explicit traceability.
