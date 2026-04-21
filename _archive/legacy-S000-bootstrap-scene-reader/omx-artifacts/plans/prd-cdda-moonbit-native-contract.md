# PRD — CDDA MoonBit Native Contract Rebuild

## Objective
Rebuild the CDDA native contract correctly in MoonBit after removing the wrong adapter-backed implementation.

## Principles
1. Native means independent writer ownership, not post-processed capture output.
2. The page unit is a relation section, not a one-off channel column.
3. Canonical channels are single runtime identities that may appear in multiple sections.
4. MoonBit owns the contract/domain logic and validation path.
5. Wrong implementations must be removed, not refined in place.

## Decision Drivers
1. Truthfulness of channel ownership
2. Clear section-based explanation of dataflow
3. MoonBit-based implementation with real toolchain verification

## Viable Options
### Option A — Keep Python runtime and add MoonBit library beside it
- Pros: faster migration
- Cons: repeats the same trust problem; MoonBit would not own the real contract
- Verdict: rejected

### Option B — MoonBit owns canonical domain + runtime state model, with a thin shell/static wrapper around it
- Pros: MoonBit becomes the contract source of truth; thinner non-MoonBit boundary
- Cons: requires fresh scaffolding and toolchain integration
- Verdict: chosen for v1 rebuild

### Option C — Full MoonBit end-to-end web/runtime/writer stack immediately
- Pros: maximal purity
- Cons: higher delivery risk, larger unknown surface for the first correction pass
- Verdict: not chosen for first rebuild, but can be a later target

## Product Shape
- canonical channels defined in MoonBit
- relation sections defined in MoonBit
- section stack rendered from MoonBit-produced state
- repeated appearances of the same channel are references, not duplicates
- first pass should support more than five sections when the registry demands it

## Key User Stories
### US-1
As an operator, I want every section to show two real participants and a relation explanation so I can understand how data moves.

### US-2
As an operator, I want the same canonical channel to reappear across sections with consistent identity and lineage.

### US-3
As a developer, I want MoonBit to define the contract/domain logic so the implementation can be validated with `moon check` and `moon test`.

### US-4
As a reviewer, I want the previous wrong implementation fully removed so the repo does not silently keep the wrong model alive.

## Deliverables
- wrong implementation removed
- MoonBit module scaffolded
- MoonBit channel/relation/section domain implemented
- MoonBit tests covering canonical reuse + section contracts
- new prompts/skills/assets rewritten from lessons learned
