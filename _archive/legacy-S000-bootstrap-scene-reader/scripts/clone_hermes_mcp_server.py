#!/usr/bin/env python3
"""MCP server for supervising a tmux-backed Hermes clone session."""

from __future__ import annotations

import json
import os
import shlex
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Optional


PROTOCOL_VERSION = "2025-06-18"
SERVER_NAME = "clone-hermes"
SERVER_VERSION = "0.1.0"


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def clamp_int(value: Any, *, default: int, minimum: int, maximum: int) -> int:
    try:
        parsed = int(value)
    except (TypeError, ValueError):
        parsed = default
    return max(minimum, min(maximum, parsed))


class McpError(Exception):
    def __init__(self, message: str, code: int = -32000) -> None:
        super().__init__(message)
        self.code = code


class CloneHermesRuntime:
    def __init__(self) -> None:
        root = Path(os.environ.get("CDDA_ROOT", Path(__file__).resolve().parents[1]))
        self.root = root.resolve()
        self.clone_session = os.environ.get("CLONE_HERMES_SESSION_NAME", "clone_hermes")
        self.clone_command = os.environ.get("CLONE_HERMES_COMMAND", "hermes")
        self.clone_width = int(os.environ.get("CLONE_HERMES_WIDTH", "140"))
        self.clone_height = int(os.environ.get("CLONE_HERMES_HEIGHT", "50"))
        self.game_session = os.environ.get("CDDA_SESSION_NAME", "hermes-cdda")
        self.cdda_mcp_url = os.environ.get("CDDA_MCP_URL", "http://127.0.0.1:8766/mcp")
        self.skill_path = Path(
            os.environ.get(
                "CLONE_HERMES_SKILL_PATH",
                str(Path.home() / ".hermes/skills/gaming/cdda-agent/SKILL.md"),
            )
        ).expanduser()
        self.state_dir = Path(
            os.environ.get("CLONE_HERMES_STATE_DIR", self.root / "tmp/clone-hermes")
        ).resolve()
        self.event_log = Path(
            os.environ.get("CLONE_HERMES_EVENT_LOG", self.state_dir / "events.jsonl")
        ).resolve()
        self.debug_log = Path(
            os.environ.get("CLONE_HERMES_DEBUG_LOG", self.state_dir / "mcp-debug.log")
        ).resolve()
        self.last_capture_file = self.state_dir / "last-capture.txt"
        self.last_command_file = self.state_dir / "last-command.txt"
        self.last_prompt_file = self.state_dir / "last-prompt.txt"
        self.last_reflection_file = self.state_dir / "last-reflection.md"
        self.status_file = self.state_dir / "status.json"

    def ensure_state_dir(self) -> None:
        self.state_dir.mkdir(parents=True, exist_ok=True)

    def event(self, kind: str, **payload: Any) -> None:
        self.ensure_state_dir()
        row = {"ts": utc_now(), "kind": kind, **payload}
        with self.event_log.open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(row, ensure_ascii=True) + "\n")

    def debug(self, message: str) -> None:
        self.ensure_state_dir()
        with self.debug_log.open("a", encoding="utf-8") as handle:
            handle.write(f"{utc_now()} {message}\n")

    def write_text(self, path: Path, text: str) -> None:
        self.ensure_state_dir()
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")

    def write_status(self, payload: Dict[str, Any]) -> None:
        self.ensure_state_dir()
        self.status_file.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    def tmux(self, *args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
        try:
            proc = subprocess.run(
                ["tmux", *args],
                check=check,
                capture_output=True,
                text=True,
            )
        except subprocess.CalledProcessError as exc:
            raise McpError(exc.stderr.strip() or exc.stdout.strip() or "tmux command failed")
        return proc

    def session_exists(self) -> bool:
        proc = subprocess.run(
            ["tmux", "has-session", "-t", self.clone_session],
            check=False,
            capture_output=True,
            text=True,
        )
        return proc.returncode == 0

    def pane_text(self, history_lines: int = 220) -> str:
        if not self.session_exists():
            raise McpError(f"tmux session {self.clone_session!r} does not exist")
        proc = self.tmux(
            "capture-pane",
            "-p",
            "-J",
            "-t",
            self.clone_session,
            "-S",
            f"-{history_lines}",
        )
        text = proc.stdout
        self.write_text(self.last_capture_file, text)
        return text

    def session_info(self) -> Dict[str, Any]:
        base = {
            "clone_session_name": self.clone_session,
            "game_session_name": self.game_session,
            "cdda_mcp_url": self.cdda_mcp_url,
            "skill_path": str(self.skill_path),
            "state_dir": str(self.state_dir),
        }
        if not self.session_exists():
            payload = {**base, "exists": False}
            self.write_status(payload)
            return payload
        proc = self.tmux(
            "display-message",
            "-p",
            "-t",
            self.clone_session,
            "#{session_name}\t#{pane_id}\t#{pane_current_command}\t#{pane_dead}\t#{pane_width}\t#{pane_height}\t#{pane_current_path}",
        )
        session, pane_id, current_command, pane_dead, width, height, cwd = proc.stdout.strip().split("\t")
        skill_exists = self.skill_path.exists()
        skill_mtime = self.skill_path.stat().st_mtime if skill_exists else None
        payload = {
            **base,
            "exists": True,
            "session_name": session,
            "pane_id": pane_id,
            "pane_current_command": current_command,
            "pane_dead": pane_dead == "1",
            "width": int(width),
            "height": int(height),
            "cwd": cwd,
            "skill_exists": skill_exists,
            "skill_mtime": skill_mtime,
            "last_capture_path": str(self.last_capture_file),
            "last_command_path": str(self.last_command_file),
            "last_prompt_path": str(self.last_prompt_file),
            "last_reflection_path": str(self.last_reflection_file),
        }
        self.write_status(payload)
        return payload

    def classify_phase(self, text: str) -> str:
        stripped = text.strip()
        if not stripped:
            return "booting"
        lowered = stripped.lower()
        if stripped.endswith("❯") or "Iteration budget exhausted" in text or "Summary" in text:
            return "waiting_input"
        if "error" in lowered or "traceback" in lowered or "failed" in lowered:
            return "errored"
        if "mcporter" in lowered or "reach_playable" in lowered or "explore loop" in lowered:
            return "running"
        return "running"

    def summarize_capture(self, text: str) -> Dict[str, Any]:
        lines = [line.rstrip() for line in text.splitlines() if line.strip()]
        tail = lines[-12:]
        lowered = text.lower()
        repeated_tail = False
        if len(tail) >= 6:
            half = len(tail) // 2
            repeated_tail = tail[:half] == tail[-half:]
        summary = {
            "phase": self.classify_phase(text),
            "mentions_mcp": "mcp" in lowered or "mcporter" in lowered,
            "mentions_reach_playable": "reach_playable" in lowered,
            "mentions_loop": "loop" in lowered or "repeat forever" in lowered or "explore loop" in lowered,
            "mentions_reset": "/reset" in text,
            "last_visible_lines": tail[-8:],
            "line_count": len(lines),
            "repeated_tail": repeated_tail,
        }
        return summary

    def build_prompt(self) -> str:
        return (
            f"Connect to {self.cdda_mcp_url} via mcporter, attach to session {self.game_session}, "
            "call reach_playable to confirm playable, then enter a CONTINUOUS EXPLORE LOOP: "
            "observe → decide → act → repeat forever. Never stop unless you die. Start the loop now."
        )

    def start_clone(self, *, inject_prompt: bool) -> Dict[str, Any]:
        if self.session_exists():
            return {"started": False, "reason": "session already exists", **self.session_info()}
        self.tmux(
            "new-session",
            "-d",
            "-s",
            self.clone_session,
            "-x",
            str(self.clone_width),
            "-y",
            str(self.clone_height),
            self.clone_command,
        )
        self.event("clone_started", session_name=self.clone_session, command=self.clone_command)
        time.sleep(1.5)
        if inject_prompt:
            self.send_text({"text": self.build_prompt(), "press_enter": True, "record_as_prompt": True})
        info = self.session_info()
        return {"started": True, **info}

    def send_text(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        if not self.session_exists():
            raise McpError(f"tmux session {self.clone_session!r} does not exist")
        text = arguments.get("text")
        if not isinstance(text, str) or not text:
            raise McpError("clone_send requires non-empty text")
        press_enter = bool(arguments.get("press_enter", True))
        literal = bool(arguments.get("literal", True))
        wait_ms = clamp_int(arguments.get("wait_ms"), default=600, minimum=0, maximum=10000)
        record_as_prompt = bool(arguments.get("record_as_prompt", False))
        if literal:
            self.tmux("send-keys", "-t", self.clone_session, "-l", text)
        else:
            self.tmux("send-keys", "-t", self.clone_session, text)
        if press_enter:
            self.tmux("send-keys", "-t", self.clone_session, "Enter")
        if record_as_prompt:
            self.write_text(self.last_prompt_file, text)
        self.write_text(self.last_command_file, text)
        self.event("clone_send", session_name=self.clone_session, press_enter=press_enter, chars=len(text))
        time.sleep(wait_ms / 1000.0)
        observed = self.capture({"history_lines": arguments.get("history_lines", 220)})
        return observed

    def capture(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        history_lines = clamp_int(arguments.get("history_lines"), default=220, minimum=40, maximum=1200)
        text = self.pane_text(history_lines=history_lines)
        summary = self.summarize_capture(text)
        payload = {
            **self.session_info(),
            "raw_text": text,
            **summary,
        }
        self.event("clone_capture", session_name=self.clone_session, phase=summary["phase"])
        return {
            "content": [{"type": "text", "text": text}],
            "structuredContent": payload,
        }

    def reset_clone(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        prompt_after_reset = bool(arguments.get("prompt_after_reset", True))
        wait_ms = clamp_int(arguments.get("wait_ms"), default=1500, minimum=0, maximum=15000)
        self.send_text({"text": "/reset", "press_enter": True, "wait_ms": wait_ms, "record_as_prompt": False})
        self.event("clone_reset", session_name=self.clone_session)
        if prompt_after_reset:
            self.send_text(
                {
                    "text": self.build_prompt(),
                    "press_enter": True,
                    "wait_ms": clamp_int(arguments.get("prompt_wait_ms"), default=1200, minimum=0, maximum=15000),
                    "record_as_prompt": True,
                }
            )
        return self.capture({"history_lines": arguments.get("history_lines", 260)})

    def restart_clone(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        if self.session_exists():
            self.tmux("kill-session", "-t", self.clone_session)
            self.event("clone_killed", session_name=self.clone_session, reason="restart")
            time.sleep(0.5)
        return self.start_clone(inject_prompt=bool(arguments.get("inject_prompt", True)))

    def write_skill(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        content = arguments.get("content")
        if not isinstance(content, str) or not content:
            raise McpError("clone_write_skill requires non-empty content")
        self.skill_path.parent.mkdir(parents=True, exist_ok=True)
        previous = self.skill_path.read_text(encoding="utf-8") if self.skill_path.exists() else ""
        backup_dir = self.state_dir / "skill-backup"
        backup_dir.mkdir(parents=True, exist_ok=True)
        if previous:
            backup_path = backup_dir / f"SKILL.{datetime.now().strftime('%Y%m%d-%H%M%S')}.md"
            backup_path.write_text(previous, encoding="utf-8")
        tmp_path = self.skill_path.with_suffix(".md.tmp")
        tmp_path.write_text(content, encoding="utf-8")
        tmp_path.replace(self.skill_path)
        preview_lines = [line for line in content.splitlines() if line.strip()][:12]
        payload = {
            "skill_path": str(self.skill_path),
            "previous_length": len(previous),
            "new_length": len(content),
            "preview_lines": preview_lines,
        }
        self.event("clone_write_skill", skill_path=str(self.skill_path), new_length=len(content))
        return {
            "content": [{"type": "text", "text": json.dumps(payload, ensure_ascii=False, indent=2)}],
            "structuredContent": payload,
        }

    def reflect(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        clone_capture = self.capture({"history_lines": arguments.get("clone_history_lines", 260)})["structuredContent"]
        game_status = subprocess.run(
            [
                "python3",
                str(self.root / "scripts/mcp_http_call.py"),
                "--url",
                self.cdda_mcp_url,
                "tools/call",
                "--params",
                json.dumps(
                    {
                        "name": "observe",
                        "arguments": {"session_name": self.game_session, "history_lines": 220},
                    },
                    ensure_ascii=False,
                ),
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        game_payload: Dict[str, Any]
        if game_status.returncode == 0:
            try:
                game_payload = json.loads(game_status.stdout)
            except json.JSONDecodeError:
                game_payload = {"raw": game_status.stdout}
        else:
            game_payload = {"error": game_status.stderr.strip() or game_status.stdout.strip()}
        reflection = {
            "clone_phase": clone_capture.get("phase"),
            "clone_mentions_loop": clone_capture.get("mentions_loop"),
            "clone_repeated_tail": clone_capture.get("repeated_tail"),
            "clone_last_lines": clone_capture.get("last_visible_lines"),
            "game_snapshot": game_payload.get("structuredContent", game_payload),
        }
        text = json.dumps(reflection, ensure_ascii=False, indent=2)
        self.write_text(self.last_reflection_file, text)
        self.event("clone_reflect", session_name=self.clone_session, phase=clone_capture.get("phase"))
        return {
            "content": [{"type": "text", "text": text}],
            "structuredContent": reflection,
        }

    def apply_skill_and_reset(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        self.write_skill({"content": arguments.get("content")})
        return self.reset_clone(arguments)


TOOLS = [
    {
        "name": "clone_status",
        "title": "Clone Status",
        "description": "Inspect the configured tmux-backed Hermes clone session without changing it.",
        "annotations": {
            "readOnlyHint": True,
            "destructiveHint": False,
            "openWorldHint": False,
            "idempotentHint": True,
        },
        "inputSchema": {"type": "object", "properties": {}, "additionalProperties": False},
    },
    {
        "name": "clone_capture",
        "title": "Capture Clone Pane",
        "description": "Capture the current clone tmux pane output and return raw plus lightly structured state.",
        "annotations": {
            "readOnlyHint": True,
            "destructiveHint": False,
            "openWorldHint": False,
            "idempotentHint": True,
        },
        "inputSchema": {
            "type": "object",
            "properties": {"history_lines": {"type": "integer"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "clone_send",
        "title": "Send Clone Text",
        "description": "Send literal text into the Hermes clone tmux session, optionally followed by Enter.",
        "annotations": {"readOnlyHint": False, "destructiveHint": False, "openWorldHint": False},
        "inputSchema": {
            "type": "object",
            "properties": {
                "text": {"type": "string"},
                "press_enter": {"type": "boolean"},
                "literal": {"type": "boolean"},
                "wait_ms": {"type": "integer"},
                "history_lines": {"type": "integer"},
            },
            "required": ["text"],
            "additionalProperties": False,
        },
    },
    {
        "name": "clone_reset",
        "title": "Reset Clone",
        "description": "Send /reset to the clone, then optionally re-send the main CDDA loop prompt.",
        "annotations": {"readOnlyHint": False, "destructiveHint": False, "openWorldHint": False},
        "inputSchema": {
            "type": "object",
            "properties": {
                "prompt_after_reset": {"type": "boolean"},
                "wait_ms": {"type": "integer"},
                "prompt_wait_ms": {"type": "integer"},
                "history_lines": {"type": "integer"},
            },
            "additionalProperties": False,
        },
    },
    {
        "name": "clone_restart",
        "title": "Restart Clone",
        "description": "Kill and recreate the clone tmux session, then optionally inject the main CDDA loop prompt.",
        "annotations": {"readOnlyHint": False, "destructiveHint": True, "openWorldHint": False},
        "inputSchema": {
            "type": "object",
            "properties": {"inject_prompt": {"type": "boolean"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "clone_write_skill",
        "title": "Write Clone Skill",
        "description": "Replace the clone CDDA skill file so future clone resets load updated instructions.",
        "annotations": {"readOnlyHint": False, "destructiveHint": False, "openWorldHint": False},
        "inputSchema": {
            "type": "object",
            "properties": {"content": {"type": "string"}},
            "required": ["content"],
            "additionalProperties": False,
        },
    },
    {
        "name": "clone_reflect",
        "title": "Reflect On Clone",
        "description": "Capture clone output and the current game view together for supervisory reflection.",
        "annotations": {"readOnlyHint": True, "destructiveHint": False, "openWorldHint": False},
        "inputSchema": {
            "type": "object",
            "properties": {"clone_history_lines": {"type": "integer"}},
            "additionalProperties": False,
        },
    },
    {
        "name": "clone_apply_skill_and_reset",
        "title": "Apply Skill And Reset",
        "description": "Update the clone skill file, then reset the clone so the new skill takes effect.",
        "annotations": {"readOnlyHint": False, "destructiveHint": False, "openWorldHint": False},
        "inputSchema": {
            "type": "object",
            "properties": {
                "content": {"type": "string"},
                "prompt_after_reset": {"type": "boolean"},
                "wait_ms": {"type": "integer"},
                "prompt_wait_ms": {"type": "integer"},
                "history_lines": {"type": "integer"},
            },
            "required": ["content"],
            "additionalProperties": False,
        },
    },
]


class StdioMcpServer:
    def __init__(self) -> None:
        self.runtime = CloneHermesRuntime()
        self.runtime.debug("server_start")

    def write_message(self, payload: Dict[str, Any]) -> None:
        sys.stdout.write(json.dumps(payload, ensure_ascii=False, separators=(",", ":")) + "\n")
        sys.stdout.flush()

    def read_message(self) -> Optional[Dict[str, Any]]:
        line = sys.stdin.buffer.readline()
        while line in (b"\r\n", b"\n"):
            line = sys.stdin.buffer.readline()
        if not line:
            self.runtime.debug("stdin_eof")
            return None

        if line.lower().startswith(b"content-length:"):
            headers: Dict[str, str] = {}
            while line not in (b"\r\n", b"\n", b""):
                key, value = line.decode("utf-8").split(":", 1)
                headers[key.lower().strip()] = value.strip()
                line = sys.stdin.buffer.readline()
            length = int(headers.get("content-length", "0"))
            if length <= 0:
                self.runtime.debug(f"empty_or_missing_content_length headers={headers}")
                return None
            body = sys.stdin.buffer.read(length)
            message = json.loads(body.decode("utf-8"))
        else:
            message = json.loads(line.decode("utf-8"))
        self.runtime.debug(f"recv method={message.get('method')} id={message.get('id')}")
        return message

    def handle_request(self, message: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        method = message.get("method")
        msg_id = message.get("id")
        params = message.get("params") or {}
        if method == "initialize":
            self.runtime.debug("handle initialize")
            return {
                "jsonrpc": "2.0",
                "id": msg_id,
                "result": {
                    "protocolVersion": params.get("protocolVersion", PROTOCOL_VERSION),
                    "capabilities": {"tools": {}},
                    "serverInfo": {"name": SERVER_NAME, "version": SERVER_VERSION},
                },
            }
        if method == "ping":
            self.runtime.debug("handle ping")
            return {"jsonrpc": "2.0", "id": msg_id, "result": {}}
        if method == "tools/list":
            self.runtime.debug("handle tools/list")
            return {"jsonrpc": "2.0", "id": msg_id, "result": {"tools": TOOLS}}
        if method == "tools/call":
            name = params.get("name")
            arguments = params.get("arguments") or {}
            self.runtime.debug(f"handle tools/call name={name}")
            if name == "clone_status":
                structured = self.runtime.session_info()
                text = json.dumps(structured, ensure_ascii=False, indent=2)
                result = {"content": [{"type": "text", "text": text}], "structuredContent": structured}
            elif name == "clone_capture":
                result = self.runtime.capture(arguments)
            elif name == "clone_send":
                result = self.runtime.send_text(arguments)
            elif name == "clone_reset":
                result = self.runtime.reset_clone(arguments)
            elif name == "clone_restart":
                structured = self.runtime.restart_clone(arguments)
                text = json.dumps(structured, ensure_ascii=False, indent=2)
                result = {"content": [{"type": "text", "text": text}], "structuredContent": structured}
            elif name == "clone_write_skill":
                result = self.runtime.write_skill(arguments)
            elif name == "clone_reflect":
                result = self.runtime.reflect(arguments)
            elif name == "clone_apply_skill_and_reset":
                result = self.runtime.apply_skill_and_reset(arguments)
            else:
                raise McpError(f"unknown tool: {name}", code=-32601)
            return {"jsonrpc": "2.0", "id": msg_id, "result": result}
        if method in {
            "notifications/initialized",
            "resources/list",
            "resources/templates/list",
            "prompts/list",
        }:
            self.runtime.debug(f"handle {method}")
            if msg_id is None:
                return None
            empty_key = {
                "resources/list": "resources",
                "resources/templates/list": "resourceTemplates",
                "prompts/list": "prompts",
            }.get(method)
            result = {} if empty_key is None else {empty_key: []}
            return {"jsonrpc": "2.0", "id": msg_id, "result": result}
        raise McpError(f"unsupported method: {method}", code=-32601)

    def serve_forever(self) -> int:
        while True:
            message = self.read_message()
            if message is None:
                return 0
            msg_id = message.get("id")
            try:
                response = self.handle_request(message)
                if response is not None:
                    self.runtime.debug(f"send id={response.get('id')}")
                    self.write_message(response)
            except McpError as exc:
                self.runtime.debug(f"mcp_error id={msg_id} code={exc.code} message={exc}")
                if msg_id is not None:
                    self.write_message(
                        {
                            "jsonrpc": "2.0",
                            "id": msg_id,
                            "error": {"code": exc.code, "message": str(exc)},
                        }
                    )
            except Exception as exc:  # pragma: no cover - defensive boundary
                self.runtime.debug(f"internal_error id={msg_id} message={exc}")
                if msg_id is not None:
                    self.write_message(
                        {
                            "jsonrpc": "2.0",
                            "id": msg_id,
                            "error": {"code": -32603, "message": f"internal error: {exc}"},
                        }
                    )


def main() -> int:
    server = StdioMcpServer()
    return server.serve_forever()


if __name__ == "__main__":
    raise SystemExit(main())
