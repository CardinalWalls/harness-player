#!/usr/bin/env node
import { execFileSync } from "node:child_process";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import path from "node:path";

function parseArgs(argv) {
  const parsed = {
    task: "",
    workerCount: 2,
    agentType: "executor",
    maxRalphIterations: 10,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (token === "--task") {
      parsed.task = argv[i + 1] ?? "";
      i += 1;
      continue;
    }
    if (token === "--workers") {
      parsed.workerCount = Number.parseInt(argv[i + 1] ?? "", 10);
      i += 1;
      continue;
    }
    if (token === "--agent-type") {
      parsed.agentType = argv[i + 1] ?? parsed.agentType;
      i += 1;
      continue;
    }
    if (token === "--max-ralph-iterations") {
      parsed.maxRalphIterations = Number.parseInt(argv[i + 1] ?? "", 10);
      i += 1;
      continue;
    }
    if (!parsed.task && !token.startsWith("--")) {
      parsed.task = token;
    }
  }

  if (!parsed.task.trim()) {
    throw new Error(
      'Usage: node scripts/run-autopilot-pipeline-bridge.mjs --task "<task text>" [--workers N] [--agent-type ROLE] [--max-ralph-iterations N]',
    );
  }
  if (!Number.isInteger(parsed.workerCount) || parsed.workerCount <= 0) {
    throw new Error("--workers must be a positive integer");
  }
  if (!Number.isInteger(parsed.maxRalphIterations) || parsed.maxRalphIterations <= 0) {
    throw new Error("--max-ralph-iterations must be a positive integer");
  }

  return parsed;
}

function resolveInstalledOmxRoot(cwd) {
  const envRoot = process.env.OMX_PACKAGE_ROOT?.trim();
  if (envRoot) {
    return envRoot;
  }

  const omxPath = execFileSync("which", ["omx"], {
    cwd,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  }).trim();

  if (!omxPath) {
    throw new Error("Unable to resolve `omx` on PATH");
  }

  const realOmxPath = execFileSync("realpath", [omxPath], {
    cwd,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  }).trim();

  return path.resolve(realOmxPath, "..", "..", "..");
}

function safeJson(value) {
  try {
    return JSON.stringify(value, null, 2);
  } catch {
    return String(value);
  }
}

async function readPackageVersion(packageRoot) {
  const packageJsonPath = path.join(packageRoot, "package.json");
  const raw = await readFile(packageJsonPath, "utf8");
  return JSON.parse(raw).version;
}

async function main() {
  const cwd = process.cwd();
  const args = parseArgs(process.argv.slice(2));
  const packageRoot = resolveInstalledOmxRoot(cwd);
  const packageVersion = await readPackageVersion(packageRoot);
  const pipelineModulePath = path.join(packageRoot, "dist", "pipeline", "index.js");

  if (!existsSync(pipelineModulePath)) {
    throw new Error(`Pipeline module not found at ${pipelineModulePath}`);
  }

  const pipeline = await import(`file://${pipelineModulePath}`);
  const {
    runPipeline,
    readPipelineState,
    createAutopilotPipelineConfig,
    createRalplanStage,
    createTeamExecStage,
    createRalphVerifyStage,
  } = pipeline;

  const stages = [
    createRalplanStage(),
    createTeamExecStage({
      workerCount: args.workerCount,
      agentType: args.agentType,
    }),
    createRalphVerifyStage({
      maxIterations: args.maxRalphIterations,
    }),
  ];

  const config = createAutopilotPipelineConfig(args.task, {
    stages,
    cwd,
    workerCount: args.workerCount,
    agentType: args.agentType,
    maxRalphIterations: args.maxRalphIterations,
  });

  const result = await runPipeline(config);
  const pipelineState = await readPipelineState(cwd);

  const teamArtifacts = result.artifacts?.["team-exec"] ?? null;
  const ralphArtifacts = result.artifacts?.["ralph-verify"] ?? null;
  const teamInstruction = teamArtifacts?.instruction ?? null;
  const ralphInstruction = ralphArtifacts?.instruction ?? null;

  const timestamp = new Date().toISOString().replace(/[:]/g, "").replace(/\.\d+Z$/, "Z");
  const plansDir = path.join(cwd, ".omx", "plans");
  const reportPath = path.join(plansDir, `autopilot-pipeline-bridge-${timestamp}.md`);
  await mkdir(plansDir, { recursive: true });

  const lines = [
    "# Autopilot Pipeline Bridge Report",
    "",
    `- Date: \`${new Date().toISOString()}\``,
    `- Installed OMX root: \`${packageRoot}\``,
    `- Installed OMX version: \`${packageVersion}\``,
    `- Working directory: \`${cwd}\``,
    `- Task: \`${args.task}\``,
    "",
    "## Result",
    "",
    `- Pipeline status: \`${result.status}\``,
    `- Worker count: \`${args.workerCount}\``,
    `- Agent type: \`${args.agentType}\``,
    `- Ralph max iterations: \`${args.maxRalphIterations}\``,
    "",
    "## Stage Results",
    "",
    ...Object.entries(result.stageResults).map(
      ([name, stageResult]) =>
        `- \`${name}\`: \`${stageResult.status}\`${stageResult.error ? ` — ${stageResult.error}` : ""}`,
    ),
    "",
    "## Pipeline State Snapshot",
    "",
    "```json",
    safeJson(pipelineState),
    "```",
    "",
    "## Generated Launch Instructions",
    "",
    `- team-exec instruction: ${teamInstruction ? `\`${teamInstruction}\`` : "_none_"}`,
    `- ralph-verify instruction: ${ralphInstruction ? `\`${ralphInstruction}\`` : "_none_"}`,
    "",
    "## Important Limitation",
    "",
    "This bridge proves that the installed pipeline orchestrator API can be invoked from the repository and that it emits canonical stage artifacts/state.",
    "",
    "It does **not** prove that upstream `v0.13.2` has already wired prompt-side `$autopilot` activation to this runner.",
    "",
    "It also does **not** make `team-exec` or `ralph-verify` launch the live runtimes automatically. In the current installed API, those stages produce descriptors/instructions unless a higher-level runtime bridge is added.",
    "",
    "## Raw Artifacts",
    "",
    "```json",
    safeJson(result.artifacts),
    "```",
  ];

  await writeFile(reportPath, `${lines.join("\n")}\n`);

  process.stdout.write(
    [
      "Autopilot pipeline bridge completed.",
      `status=${result.status}`,
      `report=${reportPath}`,
      teamInstruction ? `team=${teamInstruction}` : "team=",
      ralphInstruction ? `ralph=${ralphInstruction}` : "ralph=",
    ].join("\n") + "\n",
  );
}

main().catch((error) => {
  const message = error instanceof Error ? error.stack ?? error.message : String(error);
  process.stderr.write(`${message}\n`);
  process.exitCode = 1;
});
