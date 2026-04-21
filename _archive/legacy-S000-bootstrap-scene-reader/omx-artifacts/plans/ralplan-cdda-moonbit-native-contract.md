# RALPLAN — CDDA MoonBit Native Contract Rebuild

## ADR
- **Decision**: Delete the wrong adapter-backed implementation and rebuild the native contract around a MoonBit-owned canonical domain model.
- **Drivers**: truthfulness, reusable channel identity, section-based explanation, MoonBit verification.
- **Alternatives considered**:
  - keep Python runtime and patch it: rejected
  - full MoonBit end-to-end immediately: deferred
- **Why chosen**: it is the smallest plan that fully rejects the wrong model while making MoonBit the source of truth.
- **Consequences**: temporary reset of the new dashboard surface; more upfront scaffolding; cleaner long-term contract.
- **Follow-ups**: implement MoonBit module, tests, then thin launch/display wrapper.

## Implementation Lanes
1. Cleanup lane
   - delete wrong files
   - stop wrong runtime session
   - clear wrong generated state
2. MoonBit scaffold lane
   - create module + package structure
   - wire `moon check` / `moon test`
3. Domain lane
   - channel, relation, section models in MoonBit
   - repeated canonical references
4. Prompt/skill lane
   - rewrite scene-reader / navigator / supervisor guidance from lessons learned
5. Verification lane
   - shell cleanup verification
   - MoonBit toolchain verification

## Risks
- overreaching into full web/runtime in one pass
- reintroducing adapter logic under a new name
- mixing section views with duplicated channel identity

## Available agent types roster
- planner
- architect
- critic
- executor
- verifier
- writer

## Ralph staffing guidance
- implementation lane: executor
- spec/prompt lane: writer
- final evidence lane: verifier
- architectural sign-off lane: architect
