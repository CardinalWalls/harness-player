# Project Progress: `new-real-100-commits` — CDDA demo 分层重写

**Last Updated**: 2026-04-21
**Current Phase**: complete

> 本文件是 agents-zone-skillset `skills/conduct.md` 所读的**唯一**状态文件。
> **不要**把状态写到别处（不要再加 `_mynot/PROGRESS.md`、不要写 Notion/飞书/其他 md）。
> 约定和治理见 `_mynot/AGENTS.md`；层次含义见各层 `README.md`。

---

## Current Work

（暂无）

---

## Completed

### CDDA demo 分层重写 — STORY-000-bootstrap

**Started**: 2026-04-21
**Last Updated**: 2026-04-21
**Status**: Completed
**Story**: `_mynot/3-plan/stories/S000-bootstrap-scene-reader.md`
**Branch**: `S000-bootstrap-scene-reader` (worktree: `/Users/yetian/Desktop/new-real-100-commits-S000-bootstrap-scene-reader`)

**Phase Progress**:
- [x] Design (PRD)
- [x] Architecture (ARCHITECTURE.md)
- [x] Story (story.md)
- [x] Setup (branch + `.omx/plans/`)
- [x] Testing (failing tests)
- [x] Implementation (TDD green)
- [x] Quality Check (qc)
- [x] Dev Testing (n/a — 本地 demo，无 dev env)
- [x] CI/CD (n/a — no remote origin configured for PR creation)

**Artifacts**:
- PRD: `_mynot/1-intent/PRD.md`（draft，待 Design freeze 确认）
- Architecture: `_mynot/2-architecture/ARCHITECTURE.md`（frozen）
- Story: `_mynot/3-plan/stories/S000-bootstrap-scene-reader.md`（frozen）
- OMX plans: `.omx/plans/prd-S000-bootstrap-scene-reader.md` + `.omx/plans/test-spec-S000-bootstrap-scene-reader.md`

**Details**:
- Impact: 把上一版被 `reach_playable()` / server-side `/api/*` / server-authored `human-instruction.jsonl` 污染的架构重做，使 `_mynot/0-bigger-project-context.md §B/§H.5` 里 "CDDA demo 是 test bench" 的定位真正成立。
- Upstream context: `_mynot/_debug/error_MCP.md` 记录了上版的全部症状，作为 PRD 阶段 `$deep-interview` 的反例材料。
- Changes Required:
  - Layer 1：把 `_mynot/1.md` 里属于"意图 + 用例"的内容切给 `/prd`，其余归档到 `_mynot/_legacy/`。
  - Layer 2：用 `/architect` 重画通信/信任链；消除 "server 合成 channel 事件"。
  - Layer 3：只开一条 story（先做 bootstrap + scene-reader），其他 story 排队。
  - Layer 5：用 `$ralph` 跑 TDD 环，直到该 story AC 全绿。

**Notes**:
- Blockers: 无。
- 2026-04-21: Design phase produced `_mynot/1-intent/PRD.md` + `_mynot/1-intent/MOCK-EXPECTED-RESULT.md`. Mechanical §3 Layer 1 gate (8 items) will be evaluated on the next `$ralph` iteration. No human-confirm step — see conduct.md "Root-AGENTS Intent-Freeze carve-out".
- 2026-04-21: Design freeze passed mechanical Layer 1 gate (8/8); PRD leakage wording normalized to avoid Layer-2+ runtime terms while preserving anti-shortcut intent.
- 2026-04-21: Architecture phase produced `_mynot/2-architecture/ARCHITECTURE.md`; Layer 2 gate passed (PRD-only input, channel catalog, trust chain, bootstrap path, browser boundary, commit/restore semantics, PRD derivations).
- 2026-04-21: Story phase produced `_mynot/3-plan/stories/S000-bootstrap-scene-reader.md`; Layer 3 gate passed (single causal chain, testable AC, Architecture refs, upstream dependency, failure modes, exact files).
- 2026-04-21: Setup phase created worktree `/Users/yetian/Desktop/new-real-100-commits-S000-bootstrap-scene-reader` on branch `S000-bootstrap-scene-reader` and generated `.omx/plans/prd-S000-bootstrap-scene-reader.md` + `.omx/plans/test-spec-S000-bootstrap-scene-reader.md`.
- 2026-04-21: Testing phase locked MoonBit blackbox coverage for AC1-AC7 plus all six story failure modes; initial red run failed on missing signed-envelope API as expected.
- 2026-04-21: Implementation phase added signed envelope constructors, upstream signer/causation validation, and audit projection in `moonbit/cdda_native_contract`; `moon info && moon fmt && moon test` passed (13/13).
- 2026-04-21: Quality Check passed inline: every `failure-mode:` in the story has direct test evidence; no server/browser files were touched; no `/api/*` progress path is required for success.
- 2026-04-21: Dev Testing skipped as n/a (local demo only); CI/CD marked n/a because this repo worktree has no `origin` remote for `gh pr create`.

---

## Blocked

（暂无）

---

## Upstream Gaps （本仓库特有段，非 skillset 模板）

> 在下游层发现上游文档漏了某条原则时，**不要**偷偷在下游修。
> 把它登记在这里，然后用 `/hr <教训>` 把它回写到对应的上游 skill / 文档。
> 见 `_mynot/AGENTS.md §7`。

| # | 发现于 | 缺失的上游条目 | 目标位置 | `/hr` 是否已跑 |
|---|---|---|---|---|
| — | — | — | — | — |

---

## Lessons To Route （本仓库特有段）

> 这些是**已经知道**、但还没回路进上游文档的原则。
> `/conduct` 启动时如果看到这里非空，会先提醒你跑一次 `/hr`。

- [pre-2026-04] **"每个功能都是单向的, 由 agent 来处理"** — 上版 server-authored jsonl 违反；要回写到未来 PRD 的"通信原则"节 + skillset `/architect` 的 checklist。
- [pre-2026-04] **"web 只是一个展示层"** — 上版浏览器调 `/api/*` 违反；要回写到未来 ARCHITECTURE 的"组件角色"节 + `/architect` checklist。
- [pre-2026-04] **"CDDA demo 是 test bench，不是产品"** — 上版把 demo 当完工目标违反；要回写到 `_mynot/1-intent/README.md` 和未来 PRD 的"范畴"节。
- [pre-2026-04] **"消息必须由真正发出者签名"** — 上版 server 代 writer 写 channel 事件违反；要回写到 PRD 的"信任模型"节 + `/architect` checklist。

---

## Branching Workflow

**Strategy**: feature 分支 → main（本仓库没有 dev 环境；skillset 里的 "merge to dev" / "Dev Testing" 阶段对本仓库是 **n/a**，`/conduct` 跑到那里直接跳过即可）。

**Daily Flow**:
1. `/conduct` 推到 Setup 阶段时，它会 `git worktree add` 出 `new-real-100-commits-S<NUM>-<slug>` 分支。
2. Testing + Implementation 阶段由 `$ralph` 驱动（**不是** skillset 默认的 tester/coder 子 agent；详见 `_mynot/AGENTS.md §4`）。
3. QC 过了以后 `/conduct` 自动 commit，然后提示你 `gh pr create`。

**Commands**（你只会直接敲这三个，其他都是 `/conduct` 自动调的）:
- `/conduct` — 推进下一阶段
- `/hr <教训>` — 发现上游丢了原则时回路
- `$ralph`（在 OMX 终端里）— Layer 5 执行环；`/conduct` 到 Testing 阶段会暂停并提示你开这个

---

## Usage Guidelines

**When to Update**: 阶段完成 / 里程碑 / 发现 upstream gap 时。每一次小改不用写。
**Who Updates**: `/conduct` 自己改，子 agent / `$ralph` **只报告不直接写**。
STORY-DONE: S000-bootstrap-scene-reader — 2026-04-21 — branch `S000-bootstrap-scene-reader`; verification `moon info && moon fmt && moon test` passed (13/13); CI/CD n/a (no origin remote).
