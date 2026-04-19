#!/usr/bin/env node
import { execFileSync } from "node:child_process";
import { appendFile, mkdir, readFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import path from "node:path";

function safeString(value) {
  return typeof value === "string" ? value : "";
}

async function readStdinJson() {
  const chunks = [];
  for await (const chunk of process.stdin) {
    chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(String(chunk)));
  }

  const raw = Buffer.concat(chunks).toString("utf8").trim();
  if (!raw) {
    return {};
  }

  try {
    return JSON.parse(raw);
  } catch {
    return {};
  }
}

function readHookEventName(payload) {
  return safeString(
    payload.hook_event_name
      ?? payload.hookEventName
      ?? payload.event
      ?? payload.name,
  ).trim();
}

function readPrompt(payload) {
  return safeString(
    payload.prompt
      ?? payload.user_prompt
      ?? payload.userPrompt,
  ).trim();
}

function readSessionId(payload) {
  const candidates = [
    payload.session_id,
    payload.sessionId,
    payload.native_session_id,
    payload.nativeSessionId,
  ];

  for (const candidate of candidates) {
    const value = safeString(candidate).trim();
    if (value) {
      return value;
    }
  }

  return "";
}

function promptRequestsAutopilot(prompt) {
  if (!prompt) {
    return false;
  }
  return /(^|[^\w$])\$?autopilot\b/i.test(prompt);
}

async function appendLog(cwd, entry) {
  const logDir = path.join(cwd, ".omx", "logs");
  const logPath = path.join(
    logDir,
    `autopilot-followthrough-${new Date().toISOString().slice(0, 10)}.jsonl`,
  );

  await mkdir(logDir, { recursive: true });
  await appendFile(logPath, `${JSON.stringify(entry)}\n`, "utf8");
}

async function readSessionAutopilotSeed(cwd, sessionId) {
  if (!sessionId) {
    return null;
  }

  const statePath = path.join(
    cwd,
    ".omx",
    "state",
    "sessions",
    sessionId,
    "autopilot-state.json",
  );

  if (!existsSync(statePath)) {
    return null;
  }

  try {
    const raw = await readFile(statePath, "utf8");
    const parsed = JSON.parse(raw);
    return parsed && parsed.active === true ? parsed : null;
  } catch {
    return null;
  }
}

function run(command, args, cwd) {
  return execFileSync(command, args, {
    cwd,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  }).trim();
}

function buildArgs(sessionId, prompt) {
  const args = [];

  if (sessionId) {
    args.push("--session", sessionId);
  }
  if (prompt) {
    args.push("--task", prompt);
  }

  return args;
}

function summarizeOutput(output) {
  return output
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean)
    .filter((line) => {
      return (
        line.startsWith("session=")
        || line.startsWith("task=")
        || line.startsWith("status=")
        || line.startsWith("report=")
        || line.startsWith("team=")
        || line.startsWith("ralph=")
        || line.startsWith("team_name=")
        || line.startsWith("team_runtime_started=")
        || line.startsWith("next_official_step=")
        || line.startsWith("note=")
      );
    });
}

function isBenignHookError(message) {
  return (
    message.includes("No active session-scoped autopilot seed found.")
    || message.includes("Official follow-through is blocked:")
    || message.includes("Unsupported workflow overlap:")
    || message.includes("Current state is unchanged.")
  );
}

async function main() {
  const cwd = process.cwd();
  const payload = await readStdinJson();
  const hookEventName = readHookEventName(payload);
  const prompt = readPrompt(payload);
  const sessionId = readSessionId(payload);

  if (hookEventName !== "UserPromptSubmit" || !promptRequestsAutopilot(prompt)) {
    return;
  }

  const activeSeed = await readSessionAutopilotSeed(cwd, sessionId);
  if (!activeSeed && sessionId) {
    await appendLog(cwd, {
      timestamp: new Date().toISOString(),
      type: "autopilot_followthrough_skipped",
      reason: "no_active_seed_for_session",
      session_id: sessionId,
      prompt,
    });
    return;
  }

  const args = buildArgs(sessionId, prompt);
  const timestamp = new Date().toISOString();

  try {
    if (safeString(process.env.TMUX).trim()) {
      const followthroughOutput = run(
        "node",
        ["./scripts/run-autopilot-official-followthrough.mjs", ...args],
        cwd,
      );

      await appendLog(cwd, {
        timestamp,
        type: "autopilot_followthrough_started",
        mode: "official_tmux_followthrough",
        session_id: sessionId || null,
        prompt,
        summary: summarizeOutput(followthroughOutput),
      });
      return;
    }

    const reconcileOutput = run(
      "node",
      ["./scripts/reconcile-autopilot-entry.mjs", ...args],
      cwd,
    );

    await appendLog(cwd, {
      timestamp,
      type: "autopilot_followthrough_started",
      mode: "bridge_only_non_tmux",
      session_id: sessionId || null,
      prompt,
      summary: summarizeOutput(reconcileOutput),
      note: "Live omx team follow-through remains deferred outside tmux.",
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    const benign = isBenignHookError(message);

    await appendLog(cwd, {
      timestamp,
      type: benign ? "autopilot_followthrough_deferred" : "autopilot_followthrough_error",
      session_id: sessionId || null,
      prompt,
      error: message,
    });
  }
}

main().catch(async (error) => {
  const cwd = process.cwd();
  const message = error instanceof Error ? error.message : String(error);

  try {
    await appendLog(cwd, {
      timestamp: new Date().toISOString(),
      type: "autopilot_followthrough_error",
      error: message,
    });
  } catch {
    // Best-effort logging only.
  }
});
