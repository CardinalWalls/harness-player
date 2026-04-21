#!/usr/bin/env python3
"""Interruptible controller for bounded CDDA live-loop rounds."""

from __future__ import annotations

import os
import signal
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path

from live_state import (
    build_round_request,
    ensure_control,
    ensure_game_state_template,
    game_state_path,
    mark_messages_consumed,
    pending_human_messages,
    read_json_file,
    reset_interrupt,
    summarize_round_events,
    update_latest_fields,
    utc_now,
    write_exec_status,
    write_json_file,
    write_round_summary,
)


ROOT = Path(__file__).resolve().parents[1]
STATE_DIR = ROOT / "tmp/live/current"
RUN_ID = os.environ.get("CDDA_LIVE_RUN_ID", time.strftime("%Y%m%d-%H%M%S"))
RUN_DIR = ROOT / "artifacts/live-loop" / RUN_ID
PROMPT_FILE = ROOT / "prompts/cdda-live-round.md"
REQUEST_FILE = STATE_DIR / "request.txt"
STATUS_FILE = STATE_DIR / "loop-status.json"
RUN_FILE = STATE_DIR / "run-id.txt"
ARTIFACT_FILE = STATE_DIR / "artifact-dir.txt"
SESSION_FILE = STATE_DIR / "tmux-session.txt"
URL_FILE = STATE_DIR / "dashboard-url.txt"
MODEL_FILE = STATE_DIR / "model.txt"
ROUND_FILE = STATE_DIR / "round.txt"
EXEC_STATUS_FILE = STATE_DIR / "exec-status.json"
LOOP_SESSION = os.environ.get("CDDA_LIVE_LOOP_SESSION", "cdda-live-loop")
GAME_SESSION = os.environ.get("CDDA_LIVE_GAME_SESSION", "cdda-smoke")
MODEL_CHOICE = os.environ.get("CDDA_LIVE_MODEL", "spark")


def resolve_model_id(choice: str) -> str:
    if choice == "spark":
        return "gpt-5.3-codex-spark"
    if choice == "mini":
        return "gpt-5.4-mini"
    return choice


MODEL_ID = resolve_model_id(MODEL_CHOICE)
ROUND_SLEEP_MS = int(os.environ.get("CDDA_LIVE_ROUND_SLEEP_MS", "1200"))
WAIT_MS = int(os.environ.get("CDDA_LIVE_WAIT_MS", "900"))
STARTUP_WAIT_MS = int(os.environ.get("CDDA_LIVE_STARTUP_WAIT_MS", "3000"))
PROMPT_TEXT = PROMPT_FILE.read_text(encoding="utf-8")


@dataclass
class LoopState:
    round_number: int = 0
    last_exit_code: int = 0
    last_completed_round: int = 0
    last_round_action_count: int = 0
    last_round_outcome: str = "none"
    current_exec_pid: int = 0
    current_exec_round: int = 0


def read_control() -> dict:
    return ensure_control(STATE_DIR)


def pending_count() -> int:
    return len(pending_human_messages(STATE_DIR))


def write_loop_status(loop: LoopState, *, active: bool, round_status: str) -> None:
    control = read_control()
    payload = {
        "updated_at": utc_now(),
        "active": active,
        "run_id": RUN_ID,
        "round": loop.round_number,
        "round_status": round_status,
        "model": MODEL_ID,
        "model_choice": MODEL_CHOICE,
        "loop_session": LOOP_SESSION,
        "game_session": GAME_SESSION,
        "artifact_dir": str(RUN_DIR),
        "last_exit_code": loop.last_exit_code,
        "current_exec_pid": loop.current_exec_pid,
        "current_exec_round": loop.current_exec_round,
        "pending_human_message_count": pending_count(),
        "reflection_level": control.get("reflection_level", "plain"),
        "last_completed_round": loop.last_completed_round,
        "last_round_action_count": loop.last_round_action_count,
        "last_round_outcome": loop.last_round_outcome,
    }
    write_json_file(STATUS_FILE, payload)


def build_codex_command(round_dir: Path) -> list[str]:
    env_cfg = (
        "{"
        f'CDDA_ROOT="{ROOT}",'
        f'CDDA_INSTALL_DIR="{ROOT / "tmp/runtime/cdda-terminal"}",'
        f'CDDA_HOME_DIR="{ROOT / "tmp/runtime/home"}",'
        f'CDDA_SESSION_NAME="{GAME_SESSION}",'
        'CDDA_FIXED_SESSION_NAME="1",'
        f'CDDA_EVENT_LOG="{round_dir / "events.jsonl"}"'
        "}"
    )
    return [
        "codex",
        "exec",
        "-C",
        str(ROOT),
        "-s",
        "workspace-write",
        "--skip-git-repo-check",
        "--ephemeral",
        "-m",
        MODEL_ID,
        "--enable",
        "apps",
        "-c",
        'approval_policy="never"',
        "-c",
        'model_reasoning_effort="high"',
        "-c",
        'apps._default.default_tools_approval_mode="approve"',
        "-c",
        "apps._default.open_world_enabled=true",
        "-c",
        "apps._default.destructive_enabled=true",
        "-c",
        "apps.cdda.enabled=true",
        "-c",
        "apps.cdda.default_tools_enabled=true",
        "-c",
        'apps.cdda.default_tools_approval_mode="approve"',
        "-c",
        "apps.cdda.open_world_enabled=true",
        "-c",
        "apps.cdda.destructive_enabled=true",
        "-c",
        'apps.cdda.tools.session_status.approval_mode="approve"',
        "-c",
        'apps.cdda.tools.ensure_game.approval_mode="approve"',
        "-c",
        'apps.cdda.tools.observe.approval_mode="approve"',
        "-c",
        'apps.cdda.tools.act.approval_mode="approve"',
        "-c",
        'apps.cdda.tools.reach_playable.approval_mode="approve"',
        "-c",
        'apps.cdda.tools.stop_session.approval_mode="approve"',
        "-c",
        "apps.mcp__cdda.enabled=true",
        "-c",
        "apps.mcp__cdda.default_tools_enabled=true",
        "-c",
        'apps.mcp__cdda.default_tools_approval_mode="approve"',
        "-c",
        "apps.mcp__cdda.open_world_enabled=true",
        "-c",
        "apps.mcp__cdda.destructive_enabled=true",
        "-c",
        'apps.mcp__cdda.tools.session_status.approval_mode="approve"',
        "-c",
        'apps.mcp__cdda.tools.ensure_game.approval_mode="approve"',
        "-c",
        'apps.mcp__cdda.tools.observe.approval_mode="approve"',
        "-c",
        'apps.mcp__cdda.tools.act.approval_mode="approve"',
        "-c",
        'apps.mcp__cdda.tools.reach_playable.approval_mode="approve"',
        "-c",
        'apps.mcp__cdda.tools.stop_session.approval_mode="approve"',
        "-c",
        "mcp_servers.openaiDeveloperDocs.enabled=false",
        "-c",
        "mcp_servers.cdda.required=true",
        "-c",
        f'mcp_servers.cdda.command="{ROOT / "scripts/start-cdda-mcp.sh"}"',
        "-c",
        "mcp_servers.cdda.startup_timeout_sec=60",
        "-c",
        "mcp_servers.cdda.tool_timeout_sec=120",
        "-c",
        f"mcp_servers.cdda.env={env_cfg}",
        PROMPT_TEXT,
    ]


def safe_kill_process_group(process: subprocess.Popen[str]) -> None:
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except ProcessLookupError:
        return
    deadline = time.time() + 5
    while time.time() < deadline:
        if process.poll() is not None:
            return
        time.sleep(0.1)
    try:
        os.killpg(process.pid, signal.SIGKILL)
    except ProcessLookupError:
        return


def initialize_state(loop: LoopState) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    RUN_DIR.mkdir(parents=True, exist_ok=True)
    ensure_game_state_template(STATE_DIR)
    control = ensure_control(STATE_DIR)
    if control.get("interrupt_requested"):
        reset_interrupt(STATE_DIR)
    (STATE_DIR / "commentary.log").write_text("", encoding="utf-8")
    if (STATE_DIR / "latest.json").exists():
        (STATE_DIR / "latest.json").unlink()
    RUN_FILE.write_text(RUN_ID + "\n", encoding="utf-8")
    ARTIFACT_FILE.write_text(str(RUN_DIR) + "\n", encoding="utf-8")
    SESSION_FILE.write_text(LOOP_SESSION + "\n", encoding="utf-8")
    MODEL_FILE.write_text(MODEL_ID + "\n", encoding="utf-8")
    if (ROOT / "tmp/web/dashboard-url.txt").exists():
        URL_FILE.write_text((ROOT / "tmp/web/dashboard-url.txt").read_text(encoding="utf-8"), encoding="utf-8")
    write_exec_status(
        STATE_DIR,
        {
            "run_id": RUN_ID,
            "round": 0,
            "pid": 0,
            "status": "idle",
            "updated_at": utc_now(),
            "output_file": "",
            "error_file": "",
            "events_file": "",
            "round_dir": "",
        },
    )
    write_loop_status(loop, active=True, round_status="starting")


def prepare_round_request(loop: LoopState) -> tuple[str, list[dict]]:
    control = read_control()
    pending = pending_human_messages(STATE_DIR)
    game_state_text = game_state_path(STATE_DIR).read_text(encoding="utf-8")
    request_text = build_round_request(
        run_id=RUN_ID,
        round_number=loop.round_number,
        model=MODEL_ID,
        game_session=GAME_SESSION,
        reflection_level=control.get("reflection_level", "plain"),
        last_round_action_count=loop.last_round_action_count,
        last_round_outcome=loop.last_round_outcome,
        pending_messages=pending,
        game_state_text=game_state_text,
    )
    REQUEST_FILE.write_text(request_text + "\n", encoding="utf-8")
    if pending:
        mark_messages_consumed(
            STATE_DIR,
            [str(row.get("id")) for row in pending if row.get("id")],
            loop.round_number,
        )
        pending = [{**row, "consumed_by_round": loop.round_number} for row in pending]
    reset_interrupt(STATE_DIR)
    return control.get("reflection_level", "plain"), pending


def finalize_round(
    loop: LoopState,
    *,
    round_dir: Path,
    exit_code: int,
    outcome: str,
    reflection_level: str,
    consumed_messages: list[dict],
) -> None:
    event_summary = summarize_round_events(round_dir)
    loop.last_exit_code = exit_code
    loop.last_completed_round = loop.round_number
    loop.last_round_action_count = int(event_summary.get("action_count", 0))
    loop.last_round_outcome = outcome
    update_latest_fields(
        STATE_DIR,
        expected_round=loop.round_number,
        action_count=loop.last_round_action_count,
        round_outcome=outcome,
        reflection_level=reflection_level,
    )
    latest_payload = read_json_file(STATE_DIR / "latest.json", {})
    write_round_summary(
        round_dir,
        {
            "run_id": RUN_ID,
            "round": loop.round_number,
            "model": MODEL_ID,
            "reflection_level": reflection_level,
            "exit_code": exit_code,
            "round_outcome": outcome,
            "action_count": loop.last_round_action_count,
            "keys_sent": int(event_summary.get("keys_sent", 0)),
            "last_keys": event_summary.get("last_keys", ""),
            "event_count": int(event_summary.get("event_count", 0)),
            "consumed_human_messages": consumed_messages,
            "request_file": str(REQUEST_FILE),
            "latest_snapshot": latest_payload,
        },
    )


def run_round(loop: LoopState) -> None:
    loop.round_number += 1
    ROUND_FILE.write_text(f"{loop.round_number}\n", encoding="utf-8")
    reflection_level, consumed_messages = prepare_round_request(loop)
    round_label = f"round-{loop.round_number:04d}"
    round_dir = RUN_DIR / round_label
    round_dir.mkdir(parents=True, exist_ok=True)
    output_file = round_dir / "codex-output.txt"
    error_file = round_dir / "codex-error.txt"

    with output_file.open("w", encoding="utf-8") as stdout_handle, error_file.open(
        "w", encoding="utf-8"
    ) as stderr_handle:
        process = subprocess.Popen(
            build_codex_command(round_dir),
            cwd=ROOT,
            stdout=stdout_handle,
            stderr=stderr_handle,
            text=True,
            start_new_session=True,
        )
        loop.current_exec_pid = process.pid
        loop.current_exec_round = loop.round_number
        write_exec_status(
            STATE_DIR,
            {
                "run_id": RUN_ID,
                "round": loop.round_number,
                "pid": process.pid,
                "status": "running",
                "started_at": utc_now(),
                "output_file": str(output_file),
                "error_file": str(error_file),
                "events_file": str(round_dir / "events.jsonl"),
                "round_dir": str(round_dir),
            },
        )
        write_loop_status(loop, active=True, round_status="running")

        interrupted = False
        interrupt_reason = ""
        exit_code = 0
        while True:
            polled = process.poll()
            if polled is not None:
                exit_code = polled
                break
            control = read_control()
            if control.get("interrupt_requested"):
                interrupted = True
                interrupt_reason = str(control.get("interrupt_reason", "") or "interrupt")
                safe_kill_process_group(process)
                exit_code = process.wait()
                break
            time.sleep(0.4)

    outcome = "completed"
    if interrupted:
        outcome = "interrupted"
    elif exit_code != 0:
        outcome = "failed"

    write_exec_status(
        STATE_DIR,
        {
            "run_id": RUN_ID,
            "round": loop.round_number,
            "pid": loop.current_exec_pid,
            "status": outcome,
            "exit_code": exit_code,
            "finished_at": utc_now(),
            "interrupt_reason": interrupt_reason,
            "output_file": str(output_file),
            "error_file": str(error_file),
            "events_file": str(round_dir / "events.jsonl"),
            "round_dir": str(round_dir),
        },
    )

    finalize_round(
        loop,
        round_dir=round_dir,
        exit_code=exit_code,
        outcome=outcome,
        reflection_level=reflection_level,
        consumed_messages=consumed_messages,
    )

    loop.current_exec_pid = 0
    loop.current_exec_round = 0
    write_loop_status(loop, active=True, round_status="interrupted" if interrupted else "idle")
    reset_interrupt(STATE_DIR)
    time.sleep(ROUND_SLEEP_MS / 1000.0)


def main() -> int:
    loop = LoopState()
    initialize_state(loop)
    try:
        while True:
            run_round(loop)
    except KeyboardInterrupt:
        pass
    finally:
        loop.current_exec_pid = 0
        loop.current_exec_round = 0
        write_exec_status(
            STATE_DIR,
            {
                "run_id": RUN_ID,
                "round": loop.round_number,
                "pid": 0,
                "status": "stopped",
                "updated_at": utc_now(),
                "output_file": "",
                "error_file": "",
                "events_file": "",
                "round_dir": "",
            },
        )
        write_loop_status(loop, active=False, round_status="stopped")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
