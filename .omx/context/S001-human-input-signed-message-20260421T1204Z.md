# Context Snapshot: S001 Human input signed-message path

- Task statement: Conduct Setup/Ralplan handoff for `_mynot/3-plan/stories/S001-human-input-signed-message.md` only.
- Desired outcome: current `.omx/plans/prd-S001-human-input-signed-message.md` and `.omx/plans/test-spec-S001-human-input-signed-message.md` exist before any Testing or Implementation work.
- Known facts/evidence:
  - S000 is complete and current MoonBit baseline passes 14/14.
  - Layer 1 PRD Use case 2 requires browser-entered human instruction to become a human-signed message, not a privileged `/api/*` command.
  - Layer 2 Architecture §4 defines `human_input` with human key signing; §5 requires actor rejection when `human_input` is not human-signed; §7 limits browser to subscribe/render plus human publish.
  - Current S001 story freezes one causal path: human text -> signed `human_input` -> actor consumes accepted input.
- Constraints:
  - No implementation edits in Setup/Ralplan.
  - Preserve explicit phase contracts: tester-agent -> auto_qc/qc -> coder-agent -> auto_qc/qc.
  - No new dependencies.
  - No browser/server `/api/*` success path.
- Unknowns/open questions:
  - Whether implementation should expose `action_decision_from_human_input` or a narrower actor acknowledgement helper; tester phase should lock behavior from story before coder chooses the minimal API.
- Likely touchpoints:
  - `moonbit/cdda_native_contract/cdda_native_contract_test.mbt`
  - `moonbit/cdda_native_contract/cdda_native_contract.mbt`
  - `moonbit/cdda_native_contract/pkg.generated.mbti`
