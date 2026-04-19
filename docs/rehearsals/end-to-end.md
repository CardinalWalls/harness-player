# End-to-End Development Flow

This document describes the canonical development path for this repository.

## Goal

Establish that:

- OMX can orchestrate local work
- MoonBit provides the real validation signal
- GitHub Actions can run CI and PR review on the resulting pull request

## Local steps

1. Create or select a development issue using the issue template.
2. Enter the repository root:

   ```bash
   cd /Users/yetian/Desktop/finall-start-100-commits
   ```

3. Run the local preflight:

   ```bash
   bash ./scripts/verify-preflight.sh
   ```

4. Start the repository automation lane:

   ```bash
   bash ./scripts/omx-takeover.sh --auto
   ```

   If duplicate OMX MCP siblings or transport residue have been repeating,
   use the clean-start variant from an external terminal instead:

   ```bash
   bash ./scripts/omx-takeover.sh --restart --auto
   ```

5. If you need the highest-end official workflow, drive the implementation flow with:

   ```text
   $ralplan -> $team -> $ralph
   ```

6. Make a small MoonBit change or workflow-aligned repository change.
7. Re-run the local preflight before opening a PR.

## GitHub steps

1. Push the branch to the remote repository.
2. Open a pull request using the PR template.
3. Confirm the PR triggers:
   - `MoonBit CI`
   - `Codex PR Review`
4. Inspect:
   - CI result status
   - Codex review comment on the PR

## Validation boundary

### Real local validation

These are validated in this repository locally:

- OMX project readiness
- MoonBit commands
- coverage report generation
- workflow file presence and internal coherence

### Remote-only validation

These happen only after pushing to GitHub:

- Actions runner startup
- repository secret resolution
- PR comment creation by Codex Action

Treat remote-only checks as live-environment validation, not local preflight.
