# `_mynot/_ops/` — 把 agents-zone-skillset 装进 OMX/Codex 的 ops 资产

## 这里是什么

本目录**只装工具**，不是文档也不是计划。里面的文件让 agents-zone-skillset 跑在
**Codex + OMX** 体系下（不是 Claude Code —— 别再混了）。

结构：

```
_mynot/_ops/
├── README.md                      # 本文件
├── install-skillset.sh            # 一次性 install 脚本（幂等）
└── skills/
    └── conduct.md                 # 仓库定制的 conduct skill 体
                                   # install 脚本把它 cat 进 ~/.codex/skills/conduct/SKILL.md
```

## 它解决什么

上一版遗留问题：

- agents-zone-skillset 原生给 **Claude Code**（`~/.claude/skills/*.md`、slash command `/conduct`）
- 你的环境是 **Codex + OMX**（`~/.codex/skills/<name>/SKILL.md`、`omx ralph`、description-match 触发）
- 两者格式不同：skill 要带 YAML frontmatter、要放在子目录下、不是用 slash command 触发而是描述触发
- 另外本仓库的 5 层路径（`_mynot/1-intent/` / `_mynot/2-architecture/` / …）在 stock `conduct.md` 里完全没被考虑
- Layer 5 执行要用 **OMX `$ralph`**（keyword 触发同会话工作流）而不是 Claude Code 的 `tester` + `coder` 子 agent

本目录把这些一次修好。

## 怎么装（第一次）

```bash
# 从仓库根跑：
bash _mynot/_ops/install-skillset.sh
```

脚本会：

1. 把 `agents-zone-skillset/skills/{prd,architect,story,qc,auto_qc,follow,hr,mentor,setup}.md` 一个一个转成 `~/.codex/skills/<name>/SKILL.md`，加上 Codex 要求的 frontmatter（`name:` + `description:`）；
2. 把 `agents-zone-skillset/agents/{tester,coder}.md` 装成 `~/.codex/skills/tester-agent/` 和 `~/.codex/skills/coder-agent/`（名字加 `-agent` 后缀避免 OMX 的 `$ralph` 混淆）——这俩是 **fallback**，正常路径用 `$ralph` 顶替；
3. 把本目录的 **`skills/conduct.md`** 装成 `~/.codex/skills/conduct/SKILL.md`——这份是**仓库定制版**，知道 5 层路径、用 `$ralph` / `$ralplan` / `$deep-interview` 做相位切换。

预览不写入：

```bash
bash _mynot/_ops/install-skillset.sh --dry-run
```

卸载（只删本脚本装的那些 skill，不碰 `~/.codex/skills/` 其他东西）：

```bash
bash _mynot/_ops/install-skillset.sh --uninstall
```

## 装完怎么验

```bash
# 看是否都在位
ls ~/.codex/skills | grep -E 'prd|architect|story|conduct|qc|hr|tester-agent|coder-agent'

# 看 frontmatter 对不对（至少 name/description 要齐）
head -6 ~/.codex/skills/conduct/SKILL.md

# OMX 自查
omx doctor
```

## 改了怎么重装

- **改 conduct 行为** → 改 `_mynot/_ops/skills/conduct.md`（版本控制里的这一份），然后 `bash _mynot/_ops/install-skillset.sh`，脚本会覆盖 `~/.codex/skills/conduct/SKILL.md`。
- **改其他 skill 的 description**（触发条件）→ 改 `install-skillset.sh` 里的 `describe()` 分支，重装。
- **skillset 本体有更新** → 在 `agents-zone-skillset` 那边 `git pull`，然后重装。

绝不要直接改 `~/.codex/skills/<name>/SKILL.md`——那份是安装产物，下次 install 就被冲掉。

## 装了之后怎么用（真正的调用方式）

在 Codex/OMX 会话里（不是 shell）：

| 你说 | OMX/Codex 做什么 |
|---|---|
| `conduct` / `drive the pipeline` / `继续上次停的地方` | Codex 按 description 匹配加载 `conduct` skill → 读仓库根 `PROGRESS.md` → 自动推进下一 phase |
| `写 PRD` / `产品需求` / `新功能的 PRD` | 匹配 `prd` skill description → 加载；但通常 `conduct` 自己会在 Design phase 调到它 |
| 会话里 **conduct 到了 Setup / Testing / Implementation phase 时**，它会在输出里发出 `$ralplan` 或 `$ralph` | OMX 的 `<keyword_detection>`（根 `/AGENTS.md`）接管，进入对应 workflow。**你不用在 shell 里敲 `omx ralph`**——整件事都在同一个 Codex/OMX 会话里发生。 |
| 发现原则在产物里走丢了 | 说 `/hr <教训的一句话>`（或者 `hr: <教训>`），匹配 `hr` skill → 把教训回写到对应 skill 的 SKILL.md |

**你手动敲 shell 命令的场景**（不靠 Codex 会话自动）：
- `bash _mynot/_ops/install-skillset.sh`（装 / 更新 skill）
- `git worktree list` / `gh pr create`（偶尔手工 git）
- 调试 `.omx/state/` / `.omx/plans/` 文件时
- 其他时候都应该在 Codex/OMX 会话里走

## 和根 `/AGENTS.md` 的关系

根 `/AGENTS.md` `<keyword_detection>` 段定义了 `$ralph` / `$ralplan` / `$deep-interview` 怎么触发、什么时候阻塞（`Ralph / Ralplan execution gate`）。**本目录不覆盖那些规则**，只是让 `conduct` skill 在正确的 phase 发出正确的 keyword，让 OMX 自己走它自己的 gate。

两边冲突时：根 `/AGENTS.md` 的 `<keyword_detection>` 胜。
