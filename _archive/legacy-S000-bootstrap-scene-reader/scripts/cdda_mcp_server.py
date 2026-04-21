#!/usr/bin/env python3
"""Minimal stdio MCP server for a tmux-backed CDDA curses runtime."""

from __future__ import annotations

import json
import os
import re
import shlex
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Optional


PROTOCOL_VERSION = "2025-06-18"
SERVER_NAME = "cdda-runtime"
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


class CddaRuntime:
    def __init__(self) -> None:
        root = Path(os.environ.get("CDDA_ROOT", Path(__file__).resolve().parents[1]))
        self.root = root.resolve()
        self.install_dir = Path(
            os.environ.get("CDDA_INSTALL_DIR", self.root / "tmp/runtime/cdda-terminal")
        ).resolve()
        self.home_dir = Path(
            os.environ.get("CDDA_HOME_DIR", self.root / "tmp/runtime/home")
        ).resolve()
        self.event_log = Path(
            os.environ.get("CDDA_EVENT_LOG", self.root / "tmp/runtime/events.jsonl")
        ).resolve()
        self.debug_log = Path(
            os.environ.get("CDDA_DEBUG_LOG", self.root / "tmp/runtime/mcp-debug.log")
        ).resolve()
        self.default_session_name = os.environ.get("CDDA_SESSION_NAME", "cdda-curses")
        self.fixed_session_name = os.environ.get("CDDA_FIXED_SESSION_NAME", "").lower() in {
            "1",
            "true",
            "yes",
            "on",
        }
        self.default_width = int(os.environ.get("CDDA_TMUX_WIDTH", "120"))
        self.default_height = int(os.environ.get("CDDA_TMUX_HEIGHT", "40"))
        self.locale = os.environ.get("CDDA_LOCALE", "en_US.UTF-8")

    def event(self, kind: str, **payload: Any) -> None:
        self.event_log.parent.mkdir(parents=True, exist_ok=True)
        row = {"ts": utc_now(), "kind": kind, **payload}
        with self.event_log.open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(row, ensure_ascii=True) + "\n")

    def debug(self, message: str) -> None:
        self.debug_log.parent.mkdir(parents=True, exist_ok=True)
        with self.debug_log.open("a", encoding="utf-8") as handle:
            handle.write(f"{utc_now()} {message}\n")

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

    def session_name(self, override: Optional[str]) -> str:
        if self.fixed_session_name:
            return self.default_session_name
        return override or self.default_session_name

    def session_exists(self, session_name: str) -> bool:
        proc = subprocess.run(
            ["tmux", "has-session", "-t", session_name],
            check=False,
            capture_output=True,
            text=True,
        )
        return proc.returncode == 0

    def resolve_game_command(self) -> str:
        explicit = os.environ.get("CDDA_GAME_CMD")
        if explicit:
            return explicit
        binary = self.install_dir / "cataclysm"
        if binary.exists():
            return "./cataclysm"
        raise McpError(
            f"CDDA runtime is not installed at {self.install_dir}. "
            "Run scripts/install-cdda-terminal.sh first or set CDDA_GAME_CMD."
        )

    def launch_shell_command(self) -> str:
        game_command = self.resolve_game_command()
        env = {
            "HOME": str(self.home_dir),
            "TERM": "xterm-256color",
            "LANG": self.locale,
            "LC_ALL": self.locale,
            "DYLD_LIBRARY_PATH": str(self.install_dir),
            "DYLD_FRAMEWORK_PATH": str(self.install_dir),
        }
        exports = " ".join(f"{key}={shlex.quote(value)}" for key, value in env.items())
        return (
            f"mkdir -p {shlex.quote(str(self.home_dir))} && "
            f"cd {shlex.quote(str(self.install_dir))} && "
            f"export {exports} && "
            f"exec {game_command}"
        )

    def pane_text(self, session_name: str, history_lines: int = 220) -> str:
        proc = self.tmux(
            "capture-pane",
            "-p",
            "-J",
            "-t",
            session_name,
            "-S",
            f"-{history_lines}",
        )
        return proc.stdout

    def classify_mode(self, text: str) -> str:
        if "You don't seem to have a valid Unicode locale" in text:
            return "startup_warning"
        if "An error has occurred!" in text and "Press space bar to continue the game." in text:
            return "error_popup"
        if "Use the Tiger Kung Fu style?" in text and "[Y]es" in text and "[N]o" in text:
            return "kung_fu_popup"
        if "Loading files" in text:
            return "loading_files"
        if "has no characters to load!" in text:
            return "load_empty_popup"
        if "Pick a world to enter game" in text:
            return "world_selection"
        if "< Create World >" in text:
            return "create_world"
        if "Are you SURE you're finished?" in text:
            return "confirmation"
        if "Press TAB to finish character creation" in text:
            return "character_creation_finish"
        if "Press TAB to go to the next tab" in text or "xPOINTSx" in text:
            return "character_creation_tabs"
        if "Play Now!  (Default Scenario)" in text or "Play Now! (Default Scenario)" in text:
            return "new_game_menu"
        if "[MOTD]" in text and "[New Game]" in text:
            return "main_menu"
        if "Lighting:" in text and "Place:" in text:
            return "in_game"
        return "unknown"

    def recommended_keys(self, mode: str, text: str) -> Optional[list[str]]:
        if mode == "startup_warning":
            return ["Enter"]
        if mode == "error_popup":
            return ["Space"]
        if mode == "kung_fu_popup":
            return ["N"]
        if mode == "load_empty_popup":
            return ["Escape"]
        if mode == "main_menu":
            return ["Left", "Enter"]
        if mode == "world_selection":
            return ["Enter"]
        if mode == "new_game_menu":
            return ["Down", "Down", "Enter"]
        if mode == "create_world":
            return ["f", "Y"]
        if mode == "character_creation_tabs":
            return ["Tab"]
        if mode == "character_creation_finish":
            return ["Tab", "Y"]
        if mode == "confirmation":
            return ["Y"]
        if mode == "in_game":
            return []
        return None

    def summarize(self, text: str) -> Dict[str, Any]:
        mode = self.classify_mode(text)
        recommended_keys = self.recommended_keys(mode, text)
        location = None
        wield = None
        recent_messages: list[str] = []
        for line in text.splitlines():
            stripped = line.strip()
            if not stripped:
                continue
            if "Place:" in stripped and location is None:
                match = re.search(r"Place:\s+(.+?)\s{2,}", stripped)
                location = match.group(1).strip() if match else stripped.split("Place:", 1)[1].strip()
            if "Wield:" in stripped and wield is None:
                wield = stripped.split("Wield:", 1)[1].strip()
        nonempty = [line.rstrip() for line in text.splitlines() if line.strip()]
        if mode == "in_game":
            recent_messages = nonempty[-8:]
        else:
            recent_messages = nonempty[-6:]
        return {
            "mode": mode,
            "is_playable": mode == "in_game",
            "recommended_keys": recommended_keys,
            "location": location,
            "wield": wield,
            "recent_lines": recent_messages,
        }

    def session_info(self, session_name: str) -> Dict[str, Any]:
        if not self.session_exists(session_name):
            return {
                "session_name": session_name,
                "exists": False,
                "install_dir": str(self.install_dir),
                "home_dir": str(self.home_dir),
            }
        proc = self.tmux(
            "display-message",
            "-p",
            "-t",
            session_name,
            "#{session_name}\t#{pane_id}\t#{pane_current_command}\t#{pane_dead}\t#{pane_width}\t#{pane_height}\t#{pane_current_path}",
        )
        session, pane_id, current_command, pane_dead, width, height, cwd = proc.stdout.strip().split("\t")
        return {
            "session_name": session,
            "exists": True,
            "pane_id": pane_id,
            "pane_current_command": current_command,
            "pane_dead": pane_dead == "1",
            "width": int(width),
            "height": int(height),
            "cwd": cwd,
            "install_dir": str(self.install_dir),
            "home_dir": str(self.home_dir),
        }

    def ensure_game(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        session_name = self.session_name(arguments.get("session_name"))
        restart = bool(arguments.get("restart", False))
        wait_ms = clamp_int(arguments.get("wait_ms"), default=3500, minimum=0, maximum=10000)
        width = clamp_int(arguments.get("width"), default=self.default_width, minimum=60, maximum=240)
        height = clamp_int(arguments.get("height"), default=self.default_height, minimum=20, maximum=80)
        history_lines = clamp_int(arguments.get("history_lines"), default=220, minimum=20, maximum=400)
        self.debug(
            "ensure_game "
            + json.dumps(
                {
                    "session_name": session_name,
                    "restart": restart,
                    "wait_ms": wait_ms,
                    "width": width,
                    "height": height,
                    "history_lines": history_lines,
                },
                ensure_ascii=True,
            )
        )
        if restart and self.session_exists(session_name):
            self.tmux("kill-session", "-t", session_name)
            self.event("session_killed", session_name=session_name, reason="restart")
        if not self.session_exists(session_name):
            self.install_dir.mkdir(parents=True, exist_ok=True)
            self.home_dir.mkdir(parents=True, exist_ok=True)
            launch_command = self.launch_shell_command()
            self.tmux(
                "new-session",
                "-d",
                "-s",
                session_name,
                "-x",
                str(width),
                "-y",
                str(height),
                "sh",
                "-lc",
                launch_command,
            )
            self.event(
                "session_started",
                session_name=session_name,
                width=width,
                height=height,
                install_dir=str(self.install_dir),
            )
        time.sleep(wait_ms / 1000.0)
        observed = self.observe({"session_name": session_name, "history_lines": history_lines})
        info = self.session_info(session_name)
        return {**info, **observed["structuredContent"]}

    def observe(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        session_name = self.session_name(arguments.get("session_name"))
        if not self.session_exists(session_name):
            raise McpError(f"tmux session {session_name!r} does not exist")
        history_lines = clamp_int(arguments.get("history_lines"), default=220, minimum=20, maximum=400)
        self.debug(
            "observe "
            + json.dumps(
                {"session_name": session_name, "history_lines": history_lines},
                ensure_ascii=True,
            )
        )
        raw_text = self.pane_text(session_name, history_lines=history_lines)
        summary = self.summarize(raw_text)
        self.event(
            "observed",
            session_name=session_name,
            mode=summary["mode"],
            location=summary["location"],
        )
        return {
            "content": [
                {"type": "text", "text": raw_text},
            ],
            "structuredContent": {
                "session_name": session_name,
                "raw_text": raw_text,
                **summary,
            },
        }

    def act(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        session_name = self.session_name(arguments.get("session_name"))
        if not self.session_exists(session_name):
            raise McpError(f"tmux session {session_name!r} does not exist")
        keys = arguments.get("keys")
        if isinstance(keys, str):
            keys = [keys]
        if not isinstance(keys, list) or not keys:
            raise McpError("act requires a non-empty keys list")
        wait_ms = clamp_int(arguments.get("wait_ms"), default=900, minimum=0, maximum=5000)
        literal = bool(arguments.get("literal", False))
        repeat = clamp_int(arguments.get("repeat"), default=1, minimum=1, maximum=20)
        history_lines = clamp_int(arguments.get("history_lines"), default=220, minimum=20, maximum=400)
        if repeat < 1:
            raise McpError("repeat must be at least 1")
        self.debug(
            "act "
            + json.dumps(
                {
                    "session_name": session_name,
                    "keys": keys,
                    "literal": literal,
                    "repeat": repeat,
                    "wait_ms": wait_ms,
                    "history_lines": history_lines,
                },
                ensure_ascii=True,
            )
        )
        for _ in range(repeat):
            if literal:
                for key in keys:
                    self.tmux("send-keys", "-t", session_name, "-l", str(key))
            else:
                self.tmux("send-keys", "-t", session_name, *(str(key) for key in keys))
        self.event(
            "acted",
            session_name=session_name,
            keys=keys,
            literal=literal,
            repeat=repeat,
        )
        time.sleep(wait_ms / 1000.0)
        return self.observe({"session_name": session_name, "history_lines": history_lines})

    def stop_session(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        session_name = self.session_name(arguments.get("session_name"))
        existed = self.session_exists(session_name)
        if existed:
            self.tmux("kill-session", "-t", session_name)
            self.event("session_killed", session_name=session_name, reason="tool_call")
        return {
            "content": [
                {
                    "type": "text",
                    "text": f"session {session_name} {'stopped' if existed else 'was already absent'}",
                }
            ],
            "structuredContent": {
                "session_name": session_name,
                "stopped": existed,
            },
        }

    def reach_playable(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        session_name = self.session_name(arguments.get("session_name"))
        max_steps = clamp_int(arguments.get("max_steps"), default=8, minimum=1, maximum=16)
        wait_ms = clamp_int(arguments.get("wait_ms"), default=1200, minimum=0, maximum=5000)
        history_lines = clamp_int(arguments.get("history_lines"), default=220, minimum=20, maximum=400)
        trace: list[Dict[str, Any]] = []

        state = self.ensure_game(
            {
                "session_name": session_name,
                "restart": bool(arguments.get("restart", False)),
                "wait_ms": arguments.get("startup_wait_ms", 3500),
                "width": arguments.get("width", self.default_width),
                "height": arguments.get("height", self.default_height),
                "history_lines": history_lines,
            }
        )
        if state.get("is_playable"):
            return {
                "content": [{"type": "text", "text": json.dumps(state, ensure_ascii=False, indent=2)}],
                "structuredContent": {
                    **state,
                    "steps_taken": trace,
                    "reached_playable": True,
                },
            }

        for _ in range(max_steps):
            mode = state.get("mode", "unknown")
            keys = state.get("recommended_keys")
            if keys is None:
                break
            if mode == "in_game" or keys == []:
                break
            trace.append({"mode_before": mode, "keys": keys})
            observed = self.act(
                {
                    "session_name": session_name,
                    "keys": keys,
                    "wait_ms": wait_ms,
                    "history_lines": history_lines,
                }
            )["structuredContent"]
            trace[-1]["mode_after"] = observed.get("mode")
            state = {**self.session_info(session_name), **observed}
            if state.get("is_playable"):
                break

        payload = {
            **state,
            "steps_taken": trace,
            "reached_playable": bool(state.get("is_playable")),
        }
        return {
            "content": [{"type": "text", "text": json.dumps(payload, ensure_ascii=False, indent=2)}],
            "structuredContent": payload,
        }


TOOLS = [
    {
        "name": "session_status",
        "title": "Session Status",
        "description": "Inspect the configured tmux-backed CDDA runtime session without changing it.",
        "annotations": {
            "readOnlyHint": True,
            "destructiveHint": False,
            "openWorldHint": False,
            "idempotentHint": True,
        },
        "inputSchema": {
            "type": "object",
            "properties": {
                "session_name": {"type": "string"},
            },
            "additionalProperties": False,
        },
    },
    {
        "name": "ensure_game",
        "title": "Ensure Game",
        "description": "Launch or reconnect to a tmux session running the CDDA terminal build.",
        "annotations": {
            "readOnlyHint": False,
            "destructiveHint": False,
            "openWorldHint": False,
        },
        "inputSchema": {
            "type": "object",
            "properties": {
                "session_name": {"type": "string"},
                "restart": {"type": "boolean"},
                "wait_ms": {"type": "integer"},
                "history_lines": {"type": "integer"},
                "width": {"type": "integer"},
                "height": {"type": "integer"},
            },
            "additionalProperties": False,
        },
    },
    {
        "name": "observe",
        "title": "Observe Screen",
        "description": "Capture the current tmux pane text and return raw plus lightly structured state.",
        "annotations": {
            "readOnlyHint": True,
            "destructiveHint": False,
            "openWorldHint": False,
            "idempotentHint": True,
        },
        "inputSchema": {
            "type": "object",
            "properties": {
                "session_name": {"type": "string"},
                "history_lines": {"type": "integer"},
            },
            "additionalProperties": False,
        },
    },
    {
        "name": "act",
        "title": "Send Keys",
        "description": "Send one or more tmux key tokens to the CDDA session and observe the result.",
        "annotations": {
            "readOnlyHint": False,
            "destructiveHint": False,
            "openWorldHint": False,
        },
        "inputSchema": {
            "type": "object",
            "properties": {
                "session_name": {"type": "string"},
                "keys": {
                    "oneOf": [
                        {"type": "array", "items": {"type": "string"}},
                        {"type": "string"},
                    ]
                },
                "literal": {"type": "boolean"},
                "repeat": {"type": "integer"},
                "wait_ms": {"type": "integer"},
                "history_lines": {"type": "integer"},
            },
            "required": ["keys"],
            "additionalProperties": False,
        },
    },
    {
        "name": "reach_playable",
        "title": "Reach Playable State",
        "description": "Use the validated shortest path to drive CDDA from startup screens into an in-game playable state.",
        "annotations": {
            "readOnlyHint": False,
            "destructiveHint": False,
            "openWorldHint": False,
        },
        "inputSchema": {
            "type": "object",
            "properties": {
                "session_name": {"type": "string"},
                "restart": {"type": "boolean"},
                "startup_wait_ms": {"type": "integer"},
                "wait_ms": {"type": "integer"},
                "history_lines": {"type": "integer"},
                "max_steps": {"type": "integer"},
                "width": {"type": "integer"},
                "height": {"type": "integer"},
            },
            "additionalProperties": False,
        },
    },
    {
        "name": "stop_session",
        "title": "Stop Session",
        "description": "Kill the tmux session used for the CDDA runtime.",
        "annotations": {
            "readOnlyHint": False,
            "destructiveHint": True,
            "openWorldHint": False,
        },
        "inputSchema": {
            "type": "object",
            "properties": {
                "session_name": {"type": "string"},
            },
            "additionalProperties": False,
        },
    },
]


class StdioMcpServer:
    def __init__(self) -> None:
        self.runtime = CddaRuntime()
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
            if name == "session_status":
                structured = self.runtime.session_info(self.runtime.session_name(arguments.get("session_name")))
                text = json.dumps(structured, ensure_ascii=False, indent=2)
                result = {"content": [{"type": "text", "text": text}], "structuredContent": structured}
            elif name == "ensure_game":
                structured = self.runtime.ensure_game(arguments)
                text = json.dumps(structured, ensure_ascii=False, indent=2)
                result = {"content": [{"type": "text", "text": text}], "structuredContent": structured}
            elif name == "observe":
                result = self.runtime.observe(arguments)
            elif name == "act":
                result = self.runtime.act(arguments)
            elif name == "reach_playable":
                result = self.runtime.reach_playable(arguments)
            elif name == "stop_session":
                result = self.runtime.stop_session(arguments)
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
            except Exception as exc:  # pragma: no cover - defensive server boundary
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
