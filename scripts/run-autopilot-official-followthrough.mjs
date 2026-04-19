#!/usr/bin/env node
import { execFileSync } from "node:child_process";

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

function run(command, args, cwd) {
  return execFileSync(command, args, {
    cwd,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  }).trim();
}

function extractLine(prefix, text) {
  const line = text
    .split("\n")
    .find((entry) => entry.startsWith(prefix));
  return line ? line.slice(prefix.length).trim() : "";
}

function stripInlineComment(command) {
  const idx = command.indexOf(" # ");
  return idx >= 0 ? command.slice(0, idx).trim() : command.trim();
}

function splitCommand(command) {
  const parts = [];
  let current = "";
  let quote = "";

  for (let i = 0; i < command.length; i += 1) {
    const ch = command[i];
    if (quote) {
      if (ch === quote) {
        quote = "";
        continue;
      }
      current += ch;
      continue;
    }
    if (ch === "'" || ch === "\"") {
      quote = ch;
      continue;
    }
    if (/\s/.test(ch)) {
      if (current) {
        parts.push(current);
        current = "";
      }
      continue;
    }
    current += ch;
  }

  if (quote) {
    throw new Error(`Unterminated quote while parsing command: ${command}`);
  }
  if (current) {
    parts.push(current);
  }
  return parts;
}

async function main() {
  const cwd = process.cwd();
  const args = parseArgs(process.argv.slice(2));
  const reconcileArgs = ["./scripts/reconcile-autopilot-entry.mjs"];
  if (args.task.trim()) {
    reconcileArgs.push("--task", args.task.trim());
  }
  if (args.sessionId.trim()) {
    reconcileArgs.push("--session", args.sessionId.trim());
  }

  const reconcileOutput = run("node", reconcileArgs, cwd);
  const teamInstruction = stripInlineComment(extractLine("team=", reconcileOutput));
  const ralphInstruction = stripInlineComment(extractLine("ralph=", reconcileOutput));

  if (!teamInstruction) {
    throw new Error("Pipeline bridge did not emit an `omx team ...` instruction.");
  }
  if (!ralphInstruction) {
    throw new Error("Pipeline bridge did not emit an `omx ralph ...` instruction.");
  }

  if (!process.env.TMUX?.trim()) {
    throw new Error(
      "Official follow-through is blocked: `omx team` requires running inside a tmux leader pane in the current OMX implementation.",
    );
  }

  const teamParts = splitCommand(teamInstruction);
  const ralphParts = splitCommand(ralphInstruction);

  const teamOutput = run(teamParts[0], teamParts.slice(1), cwd);
  const teamName = extractLine("Team started: ", teamOutput);

  if (!teamName) {
    throw new Error(`Unable to parse team name from output:\n${teamOutput}`);
  }

  process.stdout.write(
    [
      reconcileOutput,
      `official_team_output=${teamOutput}`,
      `team_name=${teamName}`,
      "team_runtime_started=true",
      `next_official_step=${ralphInstruction}`,
      "note=Official `omx ralph` remains an interactive Codex launch surface; this wrapper intentionally stops after live team startup.",
    ].join("\n") + "\n",
  );
}

main().catch((error) => {
  const message = error instanceof Error ? error.stack ?? error.message : String(error);
  process.stderr.write(`${message}\n`);
  process.exitCode = 1;
});
