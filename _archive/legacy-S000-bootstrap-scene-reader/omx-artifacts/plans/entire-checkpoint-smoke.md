# Entire Checkpoint Smoke

Purpose: create one minimal committed artifact from inside the active Codex session so we can verify whether Entire links a checkpoint trailer to the commit.

Expected result:
- commit succeeds
- commit message may get an `Entire-Checkpoint:` trailer
- `entire explain --commit HEAD` should either work or provide a more precise failure mode
