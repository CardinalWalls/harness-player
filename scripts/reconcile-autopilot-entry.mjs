#!/usr/bin/env node
import { execFileSync } from "node:child_process";
import { readdir, readFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import path from "node:path";

function safeJsonParse(raw) {
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function parseArgs(argv) {
  const parsed = {
    task: "",
    sessionId: "",
  };

  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (token === "--task") {
      parsed.task = argv[i + 1] ?? "";
      i += 1;
      continue;
    }
    if (token === "--session") {
      parsed.sessionId = argv[i + 1] ?? "";
      i += 1;
      continue;
    }
  }

  return parsed;
}

async function readAutopilotSeed(statePath) {
  if (!existsSync(statePath)) {
    return null;
  }
  const raw = await readFile(statePath, "utf8");
  const parsed = safeJsonParse(raw);
  if (!parsed || parsed.active !== true) {
    return null;
  }
  return parsed;
}

async function findLatestSessionSeed(cwd) {
  const sessionsRoot = path.join(cwd, ".omx", "state", "sessions");
  if (!existsSync(sessionsRoot)) {
    return null;
  }

  const entries = await readdir(sessionsRoot, { withFileTypes: true });
  const candidates = [];

  for (const entry of entries) {
    if (!entry.isDirectory()) {
      continue;
    }
    const sessionId = entry.name;
    const autopilotPath = path.join(sessionsRoot, sessionId, "autopilot-state.json");
    const skillPath = path.join(sessionsRoot, sessionId, "skill-active-state.json");
    const [autopilot, skill] = await Promise.all([
      readAutopilotSeed(autopilotPath),
      existsSync(skillPath)
        ? readFile(skillPath, "utf8").then(safeJsonParse).catch(() => null)
        : Promise.resolve(null),
    ]);

    if (!autopilot) {
      continue;
    }
    if (skill && skill.skill !== "autopilot") {
      continue;
    }

    candidates.push({
      sessionId,
      startedAt: autopilot.started_at ?? "",
      autopilot,
    });
  }

  candidates.sort((a, b) => String(b.startedAt).localeCompare(String(a.startedAt)));
  return candidates[0] ?? null;
}

async function findLatestBridgeTask(cwd) {
  const plansDir = path.join(cwd, ".omx", "plans");
  if (!existsSync(plansDir)) {
    return "";
  }

  const entries = await readdir(plansDir, { withFileTypes: true });
  const reports = entries
    .filter((entry) => entry.isFile() && /^autopilot-pipeline-bridge-.*\.md$/.test(entry.name))
    .map((entry) => entry.name)
    .sort()
    .reverse();

  for (const report of reports) {
    const raw = await readFile(path.join(plansDir, report), "utf8");
    const match = raw.match(/^- Task: `(.*)`$/m);
    if (match?.[1]?.trim()) {
      return match[1].trim();
    }
  }

  return "";
}

async function readTakeoverBaselineTask(cwd) {
  const baselinePath = path.join(cwd, "docs", "plans", "takeover-baseline-2026-04-19.md");
  if (!existsSync(baselinePath)) {
    return "";
  }

  const raw = await readFile(baselinePath, "utf8");
  const match = raw.match(/^Advance from the current CLI-visible materialized export report toward the first true persisted export\/materialization write path\.$/m);
  if (match?.[0]) {
    return match[0];
  }
  return "";
}

function run(command, args, cwd) {
  return execFileSync(command, args, {
    cwd,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  }).trim();
}

async function main() {
  const cwd = process.cwd();
  const args = parseArgs(process.argv.slice(2));
  const chosen = args.sessionId
    ? {
        sessionId: args.sessionId,
        autopilot: await readAutopilotSeed(
          path.join(cwd, ".omx", "state", "sessions", args.sessionId, "autopilot-state.json"),
        ),
      }
    : await findLatestSessionSeed(cwd);

  if (!chosen || !chosen.autopilot) {
    throw new Error("No active session-scoped autopilot seed found.");
  }

  const task =
    args.task.trim()
    || String(chosen.autopilot.task_description ?? "").trim()
    || await findLatestBridgeTask(cwd)
    || await readTakeoverBaselineTask(cwd);

  if (!task) {
    throw new Error(
      `Active autopilot seed ${chosen.sessionId} has no recoverable task_description; rerun with --task "<task>"`,
    );
  }

  const bridgeOutput = run(
    "node",
    ["./scripts/run-autopilot-pipeline-bridge.mjs", "--task", task],
    cwd,
  );

  const clearAutopilotOutput = run(
    "omx",
    ["state", "clear", "--input", JSON.stringify({ mode: "autopilot", session_id: chosen.sessionId }), "--json"],
    cwd,
  );
  const clearSkillOutput = run(
    "omx",
    ["state", "clear", "--input", JSON.stringify({ mode: "skill-active", session_id: chosen.sessionId }), "--json"],
    cwd,
  );

  process.stdout.write(
    [
      `session=${chosen.sessionId}`,
      `task=${task}`,
      bridgeOutput,
      `clear_autopilot=${clearAutopilotOutput}`,
      `clear_skill_active=${clearSkillOutput}`,
    ].join("\n") + "\n",
  );
}

main().catch((error) => {
  const message = error instanceof Error ? error.stack ?? error.message : String(error);
  process.stderr.write(`${message}\n`);
  process.exitCode = 1;
});
