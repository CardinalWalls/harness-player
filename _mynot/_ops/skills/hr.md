# HR — Route a lesson back into the upstream skill / doc

> Installed to `~/.codex/skills/hr/SKILL.md` via `_mynot/_ops/install-skillset.sh`.
> Edit **this file** (in the repo) and reinstall; never edit the installed copy.

## When to invoke

When the user says `/hr <lesson>`, or an agent discovers that a principle
that WAS stated earlier in some upstream doc is MISSING from the current
artifact, and wants to prevent re-occurrence.

**Do NOT just patch the current downstream file.** The current file will be
regenerated from its upstream on the next iteration — the patch will vanish.
The lesson must land in the upstream source of truth.

## Procedure

1. **Parse the lesson.** Extract one crisp sentence stating the principle.
   If the user gave free-text like "上一版忘了消息要签名", extract:
   `"消息必须由真正发出者签名"`. If you cannot extract one sentence without
   re-arguing it, ask the user for the one sentence; do not proceed with a
   paraphrase.

2. **Decide the target upstream** (exactly one; if the lesson genuinely
   belongs in two, split it into two `/hr` runs):

   | Lesson scope | Target file |
   |---|---|
   | Project-level (CDDA-demo-is-test-bench, anti-signals) | `_mynot/0-bigger-project-context.md` |
   | Intent-level (what the product claims) | `_mynot/1-intent/PRD.md` §3 or §4 |
   | Architectural (how components talk, trust edges) | `_mynot/2-architecture/ARCHITECTURE.md` (if exists), else `PROGRESS.md → Lessons To Route` with tag `pending-arch` |
   | Story-level (failure-mode for current story) | `_mynot/3-plan/stories/S<NUM>-*.md` `failure-mode:` section |
   | Skill forgot to teach something | `_mynot/_ops/skills/<skill>.md` + re-run `install-skillset.sh` |
   | §3 freeze-gate missed a known failure mode | `_mynot/AGENTS.md §3 Layer <n>` as a new bullet (requires human sign-off per §10 — route via `PROGRESS.md → Lessons To Route` with tag `needs-human`) |

3. **Insert the lesson verbatim, as one sentence, in the chosen target.** No
   re-argument, no hedging. `"消息必须由真正发出者签名"` stays
   `"消息必须由真正发出者签名"` — not "consider ensuring messages are
   typically signed by their sender in most cases".

4. **Update `PROGRESS.md`:**
   - In "Lessons To Route", mark the corresponding row `routed: yes`
     (or add the row if it didn't exist, with `routed: yes`).
   - If the lesson invalidates a downstream phase already marked `[x]`
     (e.g., PRD just gained a new requirement → Architecture phase was built
     without it), uncheck that downstream phase in the current story's Phase
     Progress. `conduct.md` §Rewind will redo it on the next iteration.

5. **Commit.** Single commit, message:
   ```
   hr: route lesson "<first 6 words of lesson>" to <target file>

   Constraint: downstream artifact was missing this principle.
   Directive: do not patch only the downstream — upstream is the real source.
   ```

6. **Exit.** Do not also re-run `/conduct` in the same turn — let ralph pick
   up the rewind on its next iteration (conduct.md §Rewind).

## What this skill never does

- Modify the downstream artifact directly (that's the whole point).
- Invent a lesson the user didn't state.
- Route to more than one upstream file in a single run.
- Silently edit `_mynot/AGENTS.md §1–§4` (the base sections); those require
  human sign-off per `_mynot/AGENTS.md §10`. For those, write the lesson to
  `PROGRESS.md → Lessons To Route` with tag `needs-human` and stop.

## Audit mode: `/hr audit`

Scan `_mynot/_ops/skills/`, `~/.codex/skills/`, and the five-layer docs.
Report (no file edits in audit mode):

- duplicate principles across files;
- principles stated at Layer N that belong at Layer N-1 (upward leaks —
  e.g., "tmux session naming convention" in PRD);
- skill files whose `description:` frontmatter contradicts their body;
- rows in `PROGRESS.md → Lessons To Route` still not `routed: yes` after
  being listed ≥ 7 days.

Report format: one table, one row per finding, columns =
`severity | file | line | finding | suggested-target`.
