# S001 Tester Report — Red Phase

**Story**: `_mynot/3-plan/stories/S001-human-input-signed-message.md`  
**Contract**: `tester-agent`  
**Phase**: Testing / red-light only  
**Date**: 2026-04-21

## Files changed

- `moonbit/cdda_native_contract/cdda_native_contract_test.mbt` — added S001 blackbox tests only.
- `.omx/evidence/S001-red-tests.log` — captured red run output.

## Acceptance criteria coverage

| AC | Test evidence |
|---|---|
| AC1 human text becomes human-signed envelope | `human input: text creates human-signed envelope` |
| AC2 actor consumes accepted human input | `human input: actor consumes accepted input` |
| AC3 browser transport does not become author | `human input: browser signer is rejected` |
| AC4 `/api/*` command path is not success | `human input: api command is not success path` |
| AC5 wrong signer/channel rejected | `human input: wrong signers are rejected` |
| AC6 audit projection shows provenance | `human input: audit projection shows provenance` |
| AC7 S000 remains green | Existing S000 tests are still present in the same suite and will remain part of green verification. |

## Failure-mode coverage

| Failure mode | Test evidence |
|---|---|
| `browser-as-human-author` | `human input: browser signer is rejected` |
| `browser-api-command-input` | `human input: api command is not success path` |
| `server-authored-human-input` | `human input: wrong signers are rejected` includes server/relay |
| `actor-self-instruction` | `human input: wrong signers are rejected` includes actor |
| `missing-human-text` | `human input: empty text rejected` |
| `missing-causation` | `human input: actor response requires causation` |
| `S000-regression` | Existing S000 tests remain in file and are not modified/removed. |

## Red run evidence

Command:

```bash
cd moonbit/cdda_native_contract
moon fmt
moon test > ../../.omx/evidence/S001-red-tests.log 2>&1
```

Result: expected red. `moon test` exits non-zero because S001 public contract helpers are intentionally missing:

- `human_input_from_text`
- `action_decision_from_human_input`
- `audit_human_input`

No implementation files were changed during this phase.
