#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Install agents-zone-skillset into the Codex/OMX ecosystem.
#
# Target layout (per Codex convention, confirmed against ~/.codex/skills/bootstrap-loop/):
#
#   ~/.codex/skills/<skill>/SKILL.md   — frontmatter + body, activation by description match
#
# What this installs:
#
#   upstream stock (copied with description frontmatter added):
#     prd, architect, story, qc, auto_qc, follow, hr, mentor, setup
#     tester-agent, coder-agent   (the two "agents/*.md" files from skillset;
#                                  installed as skills because $ralph will
#                                  typically replace them — they stay available
#                                  as a fallback when $ralph is not the right tool)
#
#   project-customized (read from _mynot/_ops/skills/, cat with frontmatter):
#     conduct    — knows our 5-layer paths + emits $ralph at Testing+Impl phase
#     hr         — routes lessons to the correct upstream file (local because
#                  upstream skillset does not currently ship an hr.md)
#
# Idempotent: running twice overwrites the installed SKILL.md files. Your edits
# to ~/.codex/skills/<name>/SKILL.md will be clobbered — edit the copies in
# _mynot/_ops/skills/ (for conduct) or patch this script's heredocs instead,
# so changes are version-controlled.
#
# Nothing outside ~/.codex/skills/<installed names>/ is touched. No OMX state,
# no Codex agents/*.toml, no MCP registration, no .omx/ files.
#
# Usage:
#   bash _mynot/_ops/install-skillset.sh               # install all
#   bash _mynot/_ops/install-skillset.sh --dry-run     # show what would happen
#   bash _mynot/_ops/install-skillset.sh --uninstall   # remove only the skills
#                                                        this script installed
# -----------------------------------------------------------------------------

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
UPSTREAM="${SKILLSET_SRC:-/Users/yetian/Desktop/learn-harness-manux/_repo/agents-zone-skillset}"
CODEX_SKILLS="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
PROJECT_CONDUCT="$REPO_ROOT/_mynot/_ops/skills/conduct.md"
PROJECT_HR="$REPO_ROOT/_mynot/_ops/skills/hr.md"

DRY_RUN=0
UNINSTALL=0
for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN=1 ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help)   sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done

# List of skills this script manages. Anyone who wants to uninstall or reset
# reads this list.
SKILLS=(
  prd architect story qc auto_qc follow hr mentor setup
  tester-agent coder-agent
  conduct
)

# Description strings for each skill. These become the `description:` field in
# the Codex frontmatter, which is what triggers skill activation during a
# Codex/OMX session. Keep them specific enough that they don't fire on unrelated
# prompts.
describe() {
  case "$1" in
    prd)          echo "Create a Product Requirements Document (PRD) for a new feature by researching existing code, asking clarifying questions, distinguishing MVP from later phases. Use when the user wants to write a PRD, capture WHAT/WHY for a new feature, or produce _mynot/1-intent/PRD.md in this repo." ;;
    architect)    echo "Design technical architecture from an approved PRD: components, data flow, API shape, trust boundaries. Validate patterns against the real codebase rather than inventing. Use after a PRD is frozen and the user wants an ARCHITECTURE.md." ;;
    story)        echo "Turn PRD plus ARCHITECTURE into a single self-contained development story with acceptance criteria, test scenarios, exact file paths, anti-patterns. The story file is the sole source of truth for Tester and Coder. Use when moving from architecture to implementable work." ;;
    qc)           echo "Adversarial quality-check auditor. Do not trust claims: read actual test code, run tests, cross-check claimed coverage against story acceptance criteria, detect fake tests, placeholder code, and claim/reality mismatches. Use when a Tester/Coder reports done, or when the user asks to audit implementation quality." ;;
    auto_qc)      echo "Auto-trigger the qc skill whenever a Tester or Coder sub-run reports completion. Use passively — the main agent loads this skill so QC fires without the user having to ask each time." ;;
    follow)       echo "CI/CD self-healer. After a push, monitor GitHub Actions, download failing logs, classify the failure (lint/test/build/deploy), fix, verify locally, push, watch again. At most 2 iterations before handing the user a root-cause report. Use after shipping a story, or when the user asks to chase a failing CI run." ;;
    hr)           echo "Guardian of team capability. When a lesson reveals a missing principle in an upstream skill/agent doc, route that lesson back into the correct file instead of patching the downstream artifact. Also audits skill/agent doc quality and dedupes. Use for /hr-style lesson routing and skill-level maintenance." ;;
    mentor)       echo "Pair-programming mentor for complex refactors or unfamiliar codebase navigation. Explains tradeoffs, teaches patterns, does not just answer. Use when the user wants to learn while doing, not when they want a task finished." ;;
    setup)        echo "Prepare a development environment for a story: git worktree creation, dependency verification, build checks. Optional — many developers skip this and work in the main checkout. Use when starting a new story that benefits from isolation." ;;
    tester-agent) echo "TDD red-light sub-run: read the story file, write failing tests that describe the acceptance criteria without looking at implementation, verify the tests fail for the right reason, then report. Use as a fallback when \$ralph is not appropriate — typically \$ralph replaces this in this repo." ;;
    coder-agent)  echo "TDD green-light sub-run: read the story file and the failing tests, implement code until the tests pass without modifying the tests. Capped at 3 iterations; report blocked if unable to make tests pass. Use as a fallback when \$ralph is not appropriate." ;;
    conduct)      echo "Autonomous orchestrator for this repo's five-layer workflow (_mynot/0 context → _mynot/1-intent/PRD.md → _mynot/2-architecture/ARCHITECTURE.md → _mynot/3-plan/stories/ → code + tests → _mynot/4-runbook/). Reads the repo-root PROGRESS.md, validates prerequisites for the next phase, executes it, and updates PROGRESS.md. At Testing+Implementation phase emits \$ralph. Use when the user says 'conduct', 'drive the pipeline', 'continue from where we left off', or invokes this skill by name." ;;
    *) echo "(no description)" ;;
  esac
}

# Extract the upstream body for non-conduct skills. Strips leading YAML
# frontmatter if present (stock skillset files mostly have no frontmatter, but a
# few have a 3-line metadata header we want to keep verbatim as part of the
# body — easier to just copy everything as body).
upstream_path() {
  local name="$1"
  case "$name" in
    tester-agent) echo "$UPSTREAM/agents/tester.md" ;;
    coder-agent)  echo "$UPSTREAM/agents/coder.md" ;;
    conduct)      echo "$PROJECT_CONDUCT" ;;
    hr)           echo "$PROJECT_HR" ;;
    *)            echo "$UPSTREAM/skills/$name.md" ;;
  esac
}

write_skill() {
  local name="$1"
  local src="$2"
  local dest_dir="$CODEX_SKILLS/$name"
  local dest="$dest_dir/SKILL.md"
  local desc; desc="$(describe "$name")"

  if [[ $DRY_RUN -eq 1 ]]; then
    printf '  would write: %s (from %s)\n' "$dest" "$src"
    return 0
  fi

  mkdir -p "$dest_dir"
  {
    printf -- '---\n'
    printf -- 'name: %s\n' "$name"
    # yaml-safe single-line description; body may embed $ refs which is fine
    printf -- 'description: %s\n' "$desc"
    printf -- 'metadata:\n'
    printf -- '  source: agents-zone-skillset\n'
    printf -- '  installed-by: _mynot/_ops/install-skillset.sh\n'
    printf -- '---\n\n'
    cat -- "$src"
  } > "$dest"
}

remove_skill() {
  local name="$1"
  local dest_dir="$CODEX_SKILLS/$name"
  if [[ -d "$dest_dir" ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
      printf '  would remove: %s\n' "$dest_dir"
    else
      rm -rf -- "$dest_dir"
      printf '  removed: %s\n' "$dest_dir"
    fi
  fi
}

# ---- pre-flight ----

if [[ $UNINSTALL -eq 1 ]]; then
  echo "Uninstalling agents-zone-skillset skills from $CODEX_SKILLS ..."
  for name in "${SKILLS[@]}"; do
    remove_skill "$name"
  done
  echo "done."
  exit 0
fi

if [[ ! -d "$UPSTREAM" ]]; then
  echo "ERROR: upstream skillset not found at: $UPSTREAM" >&2
  echo "Set SKILLSET_SRC=/path/to/agents-zone-skillset and rerun." >&2
  exit 1
fi

if [[ ! -f "$PROJECT_CONDUCT" ]]; then
  echo "ERROR: project conduct override not found at: $PROJECT_CONDUCT" >&2
  echo "Expected to be present in this repo; have you pulled the latest?" >&2
  exit 1
fi

if [[ ! -f "$PROJECT_HR" ]]; then
  echo "ERROR: project hr skill not found at: $PROJECT_HR" >&2
  echo "Expected to be present in this repo; have you pulled the latest?" >&2
  exit 1
fi

mkdir -p "$CODEX_SKILLS"

# ---- install ----

echo "Installing agents-zone-skillset into $CODEX_SKILLS ..."
echo "  upstream:         $UPSTREAM"
echo "  project conduct:  $PROJECT_CONDUCT"
echo

for name in "${SKILLS[@]}"; do
  src="$(upstream_path "$name")"
  if [[ ! -f "$src" ]]; then
    echo "  WARN: source missing, skipped: $name ($src)" >&2
    continue
  fi
  write_skill "$name" "$src"
  [[ $DRY_RUN -eq 0 ]] && printf '  installed: %s\n' "$CODEX_SKILLS/$name/SKILL.md"
done

echo
if [[ $DRY_RUN -eq 1 ]]; then
  echo "(dry run — nothing written)"
else
  echo "Done. Run 'omx doctor' to verify OMX health."
  echo "Verify skills loaded:"
  echo "  ls $CODEX_SKILLS | grep -E 'prd|architect|story|conduct|qc|hr'"
fi
