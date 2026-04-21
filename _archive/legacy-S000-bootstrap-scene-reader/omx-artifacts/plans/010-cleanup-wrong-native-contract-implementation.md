# Cleanup Plan — remove wrong adapter-backed native-contract implementation

## Why
The previous implementation was wrong at the contract layer, not just at the UI layer. It introduced new channel/relation stores and UI sections, but still synthesized those channels from a single adapter that read tmux and existing agent outputs. That violates the required native-writer model.

## Goal
Delete the wrong implementation completely, keep the lessons learned, and reopen the implementation lane with a MoonBit-first design that does not inherit the adapter-backed mistake.

## Files to remove
- `scripts/cdda_channel_runtime.py`
- `scripts/cdda_contract_web_server.py`
- `scripts/channel_store.py`
- `scripts/relation_store.py`
- `scripts/open-native-contract-dashboard.sh`
- `scripts/test-native-contract-dashboard.sh`
- `web/native-contract.html`
- `prompts/scene-reader.md`
- `prompts/navigator.md`
- `prompts/supervisor.md`

## Runtime cleanup
- stop tmux session `cdda-native-contract-web` if running
- remove generated state under `tmp/native-contract/` and `tmp/native-contract-web/` when present

## Lessons kept
- section-stack UI model was useful
- repeated canonical channel appearance across sections remains valid
- explicit relation explanation per section remains valid

## Non-goals
- do not delete legacy dashboard files
- do not delete historical planning docs
- do not keep any adapter-backed runtime code as a starting point

## Verification
- removed files no longer exist
- native-contract dashboard entrypoint no longer boots
- legacy dashboard still unaffected
