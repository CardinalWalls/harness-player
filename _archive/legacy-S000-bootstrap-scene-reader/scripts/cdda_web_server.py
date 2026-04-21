#!/usr/bin/env python3
"""Tiny local web dashboard for the tmux-backed CDDA runtime."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import threading
import time
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any, Dict, List

from cdda_mcp_server import CddaRuntime
from live_state import (
    ensure_control,
    human_log_path,
    pending_human_messages,
    queue_human_message,
    read_json_file,
    read_text_tail,
    set_control,
    state_dir_from,
)


ROOT = Path(__file__).resolve().parents[1]
HTML_PATH = ROOT / "web" / "index.html"
LIVE_DIR = ROOT / "tmp" / "live" / "current"
NOSTR_DIR = ROOT / "tmp" / "nostr" / "current"
NOSTR_EVENTS_FILE = NOSTR_DIR / "events.jsonl"
NOSTR_HUMAN_LAST_HASH = NOSTR_DIR / "human-hermes-last-hash.txt"
NOSTR_CLONE_LAST_HASH = NOSTR_DIR / "clone-last-hash.txt"
NOSTR_SUPERVISOR_LAST_HASH = NOSTR_DIR / "supervisor-last-hash.txt"
NOSTR_CHANNEL_STORE_DIR = NOSTR_DIR / "channels"
NOSTR_CHANNEL_STORE_FILE = NOSTR_DIR / "channel-store.json"
NOSTR_RELAY_TIMELINE_FILE = NOSTR_DIR / "relay-timeline.json"
NOSTR_FLOW_TOPOLOGY_FILE = NOSTR_DIR / "flow-topology.json"
CHANNEL_SNAPSHOT_VERSION = "v2"
CHANNEL_STORE_VERSION = "v3"
HUMAN_HERMES_SESSION = "human_hermes_web"
HUMAN_HERMES_COMMAND = "hermes -p cdda"
TRACKED_TMUX_SESSIONS = [
    {"session_name": "hermes-cdda", "title": "CDDA Game", "role": "game"},
    {"session_name": "clone_hermes", "title": "Clone Hermes", "role": "actor"},
    {"session_name": "supervisor", "title": "Supervisor Hermes", "role": "supervisor"},
    {"session_name": "cdda-mcp-proxy", "title": "CDDA MCP Proxy", "role": "proxy"},
    {"session_name": "clone-hermes-mcp-proxy", "title": "Clone MCP Proxy", "role": "proxy"},
    {"session_name": HUMAN_HERMES_SESSION, "title": "Human Hermes", "role": "human"},
]
CHANNEL_DEFINITIONS = [
    {
        "channel": "human-hermes",
        "session_name": HUMAN_HERMES_SESSION,
        "role": "human",
        "title": "Human Hermes",
        "pubkey": "human-hermes-web",
        "hash_file": NOSTR_HUMAN_LAST_HASH,
    },
    {
        "channel": "clone-hermes",
        "session_name": "clone_hermes",
        "role": "actor",
        "title": "Clone Hermes",
        "pubkey": "clone-hermes-web",
        "hash_file": NOSTR_CLONE_LAST_HASH,
    },
    {
        "channel": "supervisor-hermes",
        "session_name": "supervisor",
        "role": "supervisor",
        "title": "Supervisor Hermes",
        "pubkey": "supervisor-hermes-web",
        "hash_file": NOSTR_SUPERVISOR_LAST_HASH,
    },
]
CHANNEL_SECTION_RE = re.compile(
    r"^(?:[-*]\s*)?(?:\*\*)?(Observation|Plan|Result)(?:\*\*)?\s*:\s*(.*)$",
    re.IGNORECASE,
)
CHANNEL_BOX_RE = re.compile(
    r"╭─[^\n]*Hermes[^\n]*╮(?P<body>.*?)╰[^\n]*╯",
    re.DOTALL,
)


def tmux_exists(session_name: str) -> bool:
    proc = subprocess.run(
        ["tmux", "has-session", "-t", session_name],
        check=False,
        capture_output=True,
        text=True,
    )
    return proc.returncode == 0


def tmux_capture(session_name: str, history_lines: int = 220) -> Dict[str, Any]:
    base = {"session_name": session_name, "exists": False, "raw_text": ""}
    if not tmux_exists(session_name):
        return base
    proc = subprocess.run(
        [
            "tmux",
            "display-message",
            "-p",
            "-t",
            session_name,
            "#{session_name}\t#{pane_id}\t#{pane_current_command}\t#{pane_dead}\t#{pane_width}\t#{pane_height}\t#{pane_current_path}",
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    session, pane_id, current_command, pane_dead, width, height, cwd = proc.stdout.strip().split("\t")
    captured = subprocess.run(
        ["tmux", "capture-pane", "-p", "-J", "-t", session_name, "-S", f"-{history_lines}"],
        check=True,
        capture_output=True,
        text=True,
    )
    return {
        **base,
        "exists": True,
        "session_name": session,
        "pane_id": pane_id,
        "pane_current_command": current_command,
        "pane_dead": pane_dead == "1",
        "width": int(width),
        "height": int(height),
        "cwd": cwd,
        "raw_text": captured.stdout,
    }


def human_hermes_bootstrap() -> str:
    return (
        "You are the human-input Hermes for the live CDDA tmux scene.\n"
        "Available tmux sessions:\n"
        "- hermes-cdda: game\n"
        "- clone_hermes: actor Hermes\n"
        "- supervisor: supervisor Hermes\n"
        "- cdda-mcp-proxy: game MCP proxy\n"
        "- clone-hermes-mcp-proxy: clone MCP proxy\n"
        "The human will type instructions here. Use the existing tmux and runtime surfaces to inspect and interact with the other sessions.\n"
        "When replying, keep your meaning structured and concise.\n"
        "Output using this shape:\n"
        "OBSERVATION: <what you see>\n"
        "PLAN: <what you will do next>\n"
        "RESULT: <what happened or your current answer>\n"
        "Acknowledge briefly and wait for the human's next instruction."
    )


def ensure_nostr_dir() -> None:
    NOSTR_DIR.mkdir(parents=True, exist_ok=True)
    NOSTR_CHANNEL_STORE_DIR.mkdir(parents=True, exist_ok=True)


def _write_json_file(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def _channel_store_path(channel_name: str) -> Path:
    return NOSTR_CHANNEL_STORE_DIR / f"{channel_name}.json"


def _channel_tag_value(event: dict[str, Any], key: str) -> str:
    for tag in event.get("tags", []):
        if isinstance(tag, list) and len(tag) >= 2 and tag[0] == key:
            return str(tag[1])
    return ""


def _latest_snapshot_event(events: list[dict[str, Any]]) -> dict[str, Any] | None:
    for event in reversed(events):
        if int(event.get("kind", 0) or 0) == 24102:
            return event
    return None


def _decode_snapshot_content(event: dict[str, Any] | None) -> dict[str, Any]:
    if not isinstance(event, dict):
        return {}
    try:
        payload = json.loads(str(event.get("content", "") or ""))
    except json.JSONDecodeError:
        return {}
    return payload if isinstance(payload, dict) else {}


def _timeline_entry(event: dict[str, Any]) -> dict[str, Any]:
    snapshot = _decode_snapshot_content(event)
    return {
        "id": event.get("id", ""),
        "created_at": int(event.get("created_at", 0) or 0),
        "kind": int(event.get("kind", 0) or 0),
        "pubkey": event.get("pubkey", ""),
        "channel": _channel_tag_value(event, "channel"),
        "event_type": _channel_tag_value(event, "type"),
        "session": _channel_tag_value(event, "session"),
        "role": _channel_tag_value(event, "role"),
        "tags": event.get("tags", []),
        "content": event.get("content", ""),
        "summary": (
            snapshot.get("result")
            or snapshot.get("excerpt")
            or str(event.get("content", "") or "")[:200]
        ),
        "snapshot": snapshot or None,
    }


def _empty_snapshot(*, channel_name: str, session_name: str, role: str) -> dict[str, Any]:
    return {
        "channel": channel_name,
        "session_name": session_name,
        "role": role,
        "observation": "",
        "plan": "",
        "result": "",
        "health": "unknown",
        "health_detail": "",
        "tail": "",
        "excerpt": "",
        "messages": [],
        "structured": False,
        "source": "nostr-store",
        "block_count": 0,
        "latest_block": "",
    }


def _event_id(created_at: int, kind: int, tags: list[list[str]], content: str, pubkey: str) -> str:
    payload = json.dumps([0, pubkey, created_at, kind, tags, content], ensure_ascii=False, separators=(",", ":"))
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def append_local_nostr_event(
    *,
    kind: int,
    pubkey: str,
    tags: list[list[str]],
    content: str,
) -> dict[str, Any]:
    ensure_nostr_dir()
    created_at = int(time.time())
    event = {
        "id": _event_id(created_at, kind, tags, content, pubkey),
        "pubkey": pubkey,
        "created_at": created_at,
        "kind": kind,
        "tags": tags,
        "content": content,
        "sig": "",
        "local": True,
    }
    with NOSTR_EVENTS_FILE.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(event, ensure_ascii=False) + "\n")
    return event


def read_local_nostr_events(*, channel: str | None = None, limit: int = 40) -> list[dict[str, Any]]:
    if not NOSTR_EVENTS_FILE.exists():
        return []
    rows: list[dict[str, Any]] = []
    for line in NOSTR_EVENTS_FILE.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue
        if not isinstance(row, dict):
            continue
        if channel is not None:
            tags = row.get("tags", [])
            channel_tags = [tag[1] for tag in tags if isinstance(tag, list) and len(tag) >= 2 and tag[0] == "channel"]
            if channel not in channel_tags:
                continue
        rows.append(row)
    return rows[-limit:]


def _normalize_channel_line(line: str) -> str:
    normalized = line.replace("**", "").strip()
    normalized = re.sub(r"^[│┊]\s*", "", normalized)
    normalized = re.sub(r"^\s+", "", normalized)
    return normalized.strip()


def _clean_channel_lines(lines: list[str]) -> list[str]:
    cleaned: list[str] = []
    for line in lines:
        normalized = _normalize_channel_line(line)
        if not normalized:
            continue
        if normalized.startswith("⚕ ") or normalized.startswith("cdda ❯"):
            continue
        if set(normalized) <= {"─"}:
            continue
        cleaned.append(normalized)
    return cleaned


def _extract_channel_blocks(raw_text: str) -> list[list[str]]:
    blocks: list[list[str]] = []
    for match in CHANNEL_BOX_RE.finditer(raw_text):
        lines = _clean_channel_lines(match.group("body").splitlines())
        if lines:
            blocks.append(lines)
    return blocks


def _parse_channel_sections(lines: list[str]) -> dict[str, str]:
    sections: dict[str, list[str]] = {"observation": [], "plan": [], "result": []}
    current: str | None = None
    for line in lines:
        match = CHANNEL_SECTION_RE.match(line)
        if match:
            current = match.group(1).lower()
            value = match.group(2).strip()
            if value:
                sections[current].append(value)
            continue
        if current:
            sections[current].append(line)
    return {key: "\n".join(value).strip() for key, value in sections.items()}


def _infer_plan_from_messages(messages: list[str]) -> str:
    for message in messages:
        collapsed = message.strip().strip("-").strip().lower()
        if collapsed in {"loop continues", "loop continue"}:
            continue
        if lowered := message.lower():
            if "game is live" in lowered and "npc present" in lowered:
                continue
        lowered = message.lower()
        if any(keyword in lowered for keyword in ("monitor", "wait", "restart", "check", "explor", "continue")):
            return message
        if any(keyword in message for keyword in ("监控", "等待", "重启", "继续", "检查")):
            return message
    return ""


def _infer_health_from_messages(messages: list[str], *, session_name: str) -> str:
    if session_name == HUMAN_HERMES_SESSION:
        return "healthy"
    for message in messages:
        lowered = message.lower()
        if any(
            keyword in lowered
            for keyword in (
                "budget",
                "low resource",
                "stuck",
                "looping",
                "loop continues",
                "loop active",
                "dead",
                "errored",
            )
        ):
            return "degraded"
        if any(keyword in message for keyword in ("预算", "卡住", "循环", "低资源", "监控")):
            return "degraded"
    return "healthy"


def _infer_health_detail_from_messages(messages: list[str], *, session_name: str) -> str:
    for message in messages:
        lowered = message.lower()
        if any(keyword in lowered for keyword in ("budget", "low resource", "stuck", "looping", "dead", "errored")):
            return message
        if any(keyword in message for keyword in ("预算", "卡住", "循环", "低资源", "监控")):
            return message
    if session_name == HUMAN_HERMES_SESSION:
        return "human Hermes running"
    return "session alive"


def extract_channel_summary(
    raw_text: str,
    *,
    channel_name: str,
    session_name: str,
    role: str,
) -> dict[str, Any]:
    blocks = _extract_channel_blocks(raw_text)
    recent_blocks = blocks[-3:]
    recent_messages = list(dict.fromkeys("\n".join(block).strip() for block in reversed(recent_blocks) if block))

    structured_sections: dict[str, str] | None = None
    structured_block: list[str] = []
    for block in reversed(blocks):
        parsed = _parse_channel_sections(block)
        if any(parsed.values()):
            structured_sections = parsed
            structured_block = block
            break

    observation = structured_sections["observation"] if structured_sections else ""
    plan = structured_sections["plan"] if structured_sections else ""
    result = structured_sections["result"] if structured_sections else ""
    health = ""
    health_detail = ""

    if not result and recent_messages:
        result = recent_messages[0]
    if not observation and len(recent_messages) > 1:
        observation = recent_messages[1]
    if not plan:
        plan = _infer_plan_from_messages(recent_messages)
    if not observation and recent_messages:
        observation = recent_messages[0]
    if not result and plan:
        result = plan
    if channel_name == "clone-hermes" and observation == plan:
        plan = "continue controlled game interaction"
    if not plan and channel_name == "clone-hermes":
        plan = "continue controlled game interaction"
    if not result and channel_name == "clone-hermes":
        result = "loop active"
    if not plan and channel_name == "supervisor-hermes":
        plan = "continue monitoring clone and game state"
    if not result and channel_name == "supervisor-hermes":
        result = "monitoring active"
    health = _infer_health_from_messages(recent_messages, session_name=session_name)
    health_detail = _infer_health_detail_from_messages(recent_messages, session_name=session_name)

    tail_lines: list[str] = []
    for block in recent_blocks:
        tail_lines.extend(block)
    tail = "\n".join(tail_lines[-12:])
    if not tail:
        tail = "\n".join(_clean_channel_lines(raw_text.splitlines())[-12:])

    return {
        "channel": channel_name,
        "session_name": session_name,
        "role": role,
        "observation": observation,
        "plan": plan,
        "result": result,
        "health": health,
        "health_detail": health_detail,
        "tail": tail,
        "excerpt": recent_messages[0] if recent_messages else "",
        "messages": recent_messages[:3],
        "structured": bool(
            (structured_sections and any(structured_sections.values()))
            or (observation and plan and result and health)
        ),
        "source": "hermes-box" if blocks else "tmux-tail",
        "block_count": len(blocks),
        "latest_block": "\n".join(structured_block or (recent_blocks[-1] if recent_blocks else [])),
    }


def _channel_snapshot_digest(summary: dict[str, Any]) -> str:
    payload = json.dumps(
        {
            "version": CHANNEL_SNAPSHOT_VERSION,
            "channel": summary.get("channel", ""),
            "session_name": summary.get("session_name", ""),
            "role": summary.get("role", ""),
            "observation": summary.get("observation", ""),
            "plan": summary.get("plan", ""),
            "result": summary.get("result", ""),
            "health": summary.get("health", ""),
            "tail": summary.get("tail", ""),
            "excerpt": summary.get("excerpt", ""),
        },
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    )
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def extract_human_hermes_summary(raw_text: str) -> dict[str, Any]:
    return extract_channel_summary(
        raw_text,
        channel_name="human-hermes",
        session_name=HUMAN_HERMES_SESSION,
        role="human",
    )


def extract_agent_channel_summary(raw_text: str, *, channel_name: str, session_name: str, role: str) -> dict[str, Any]:
    return extract_channel_summary(
        raw_text,
        channel_name=channel_name,
        session_name=session_name,
        role=role,
    )


class CddaDashboardHandler(BaseHTTPRequestHandler):
    runtime = CddaRuntime()
    _channel_store_lock = threading.Lock()

    def _tracked_tmux_views(self) -> list[Dict[str, Any]]:
        views: list[Dict[str, Any]] = []
        for entry in TRACKED_TMUX_SESSIONS:
            captured = tmux_capture(entry["session_name"], history_lines=220)
            views.append({**entry, **captured})
        return views

    def _ensure_human_hermes(self, inject_bootstrap: bool = True) -> Dict[str, Any]:
        if not tmux_exists(HUMAN_HERMES_SESSION):
            subprocess.run(
                [
                    "tmux",
                    "new-session",
                    "-d",
                    "-s",
                    HUMAN_HERMES_SESSION,
                    "-x",
                    "140",
                    "-y",
                    "50",
                    "-c",
                    str(ROOT),
                    HUMAN_HERMES_COMMAND,
                ],
                check=True,
                capture_output=True,
                text=True,
            )
            time.sleep(1.5)
            if inject_bootstrap:
                self._send_human_hermes_text(
                    human_hermes_bootstrap(),
                    press_enter=True,
                    wait_ms=1500,
                )
            append_local_nostr_event(
                kind=24100,
                pubkey="human-hermes-web",
                tags=[["channel", "human-hermes"], ["type", "system.started"]],
                content="human_hermes_web session started",
            )
        return tmux_capture(HUMAN_HERMES_SESSION, history_lines=220)

    def _send_human_hermes_text(
        self,
        text: str,
        *,
        press_enter: bool = True,
        wait_ms: int = 600,
    ) -> tuple[Dict[str, Any], Dict[str, Any]]:
        self._ensure_human_hermes(inject_bootstrap=False)
        message_event = append_local_nostr_event(
            kind=24101,
            pubkey="human-operator",
            tags=[["channel", "human-hermes"], ["type", "human.message"], ["target", HUMAN_HERMES_SESSION]],
            content=text,
        )
        subprocess.run(
            ["tmux", "send-keys", "-t", HUMAN_HERMES_SESSION, "-l", text],
            check=True,
            capture_output=True,
            text=True,
        )
        if press_enter:
            subprocess.run(
                ["tmux", "send-keys", "-t", HUMAN_HERMES_SESSION, "Enter"],
                check=True,
                capture_output=True,
                text=True,
            )
        time.sleep(max(wait_ms, 0) / 1000.0)
        return message_event, tmux_capture(HUMAN_HERMES_SESSION, history_lines=220)

    def _wait_for_human_hermes_snapshot(
        self,
        *,
        message_created_at: int,
        timeout_ms: int = 0,
        poll_interval_ms: int = 500,
    ) -> Dict[str, Any]:
        deadline = time.time() + max(timeout_ms, 0) / 1000.0
        while True:
            payload = self._session_payload()
            human_events = payload.get("human_channel_events", [])
            if any(
                event.get("kind") == 24102
                and int(event.get("created_at", 0) or 0) >= message_created_at
                for event in human_events
            ):
                return payload
            if timeout_ms <= 0 or time.time() >= deadline:
                return payload
            time.sleep(max(poll_interval_ms, 50) / 1000.0)

    def _sync_human_hermes_channel(self, human_hermes: Dict[str, Any]) -> List[Dict[str, Any]]:
        ensure_nostr_dir()
        raw_text = str(human_hermes.get("raw_text", "") or "")
        summary = extract_human_hermes_summary(raw_text)
        digest = _channel_snapshot_digest(summary)
        previous = NOSTR_HUMAN_LAST_HASH.read_text(encoding="utf-8").strip() if NOSTR_HUMAN_LAST_HASH.exists() else ""
        if human_hermes.get("exists") and raw_text and digest != previous and summary.get("tail"):
            NOSTR_HUMAN_LAST_HASH.write_text(digest, encoding="utf-8")
            content = json.dumps(
                {
                    "channel": summary["channel"],
                    "session_name": summary["session_name"],
                    "role": summary["role"],
                    "observation": summary["observation"],
                    "plan": summary["plan"],
                    "result": summary["result"],
                    "health": summary["health"],
                    "tail": summary["tail"],
                    "excerpt": summary["excerpt"],
                    "messages": summary["messages"],
                    "structured": summary["structured"],
                    "source": summary["source"],
                    "block_count": summary["block_count"],
                    "latest_block": summary["latest_block"],
                },
                ensure_ascii=False,
            )
            append_local_nostr_event(
                kind=24102,
                pubkey="human-hermes-web",
                tags=[["channel", "human-hermes"], ["type", "agent.snapshot"], ["session", HUMAN_HERMES_SESSION]],
                content=content,
            )
        return read_local_nostr_events(channel="human-hermes", limit=30)

    def _sync_tmux_agent_channel(
        self,
        *,
        session_name: str,
        channel_name: str,
        pubkey: str,
        hash_file: Path,
        role: str,
        tmux_views: List[Dict[str, Any]],
    ) -> List[Dict[str, Any]]:
        ensure_nostr_dir()
        target = next(
            (view for view in tmux_views if view.get("session_name") == session_name),
            {"session_name": session_name, "exists": False, "raw_text": ""},
        )
        raw_text = str(target.get("raw_text", "") or "")
        summary = extract_agent_channel_summary(
            raw_text,
            channel_name=channel_name,
            session_name=session_name,
            role=role,
        )
        digest = _channel_snapshot_digest(summary)
        previous = hash_file.read_text(encoding="utf-8").strip() if hash_file.exists() else ""
        if target.get("exists") and raw_text and digest != previous and summary.get("tail"):
            hash_file.write_text(digest, encoding="utf-8")
            content = json.dumps(
                {
                    "channel": summary["channel"],
                    "session_name": summary["session_name"],
                    "role": summary["role"],
                    "observation": summary["observation"],
                    "plan": summary["plan"],
                    "result": summary["result"],
                    "health": summary["health"],
                    "tail": summary["tail"],
                    "excerpt": summary["excerpt"],
                    "messages": summary["messages"],
                    "structured": summary["structured"],
                    "source": summary["source"],
                    "block_count": summary["block_count"],
                    "latest_block": summary["latest_block"],
                },
                ensure_ascii=False,
            )
            append_local_nostr_event(
                kind=24102,
                pubkey=pubkey,
                tags=[["channel", channel_name], ["type", "agent.snapshot"], ["session", session_name], ["role", role]],
                content=content,
            )
        return read_local_nostr_events(channel=channel_name, limit=30)

    def _channel_record(
        self,
        *,
        channel_name: str,
        title: str,
        session_name: str,
        role: str,
        tmux_view: Dict[str, Any],
        events: list[dict[str, Any]],
    ) -> dict[str, Any]:
        latest_snapshot_event = _latest_snapshot_event(events)
        latest_snapshot = _decode_snapshot_content(latest_snapshot_event)
        previous_record = self._read_json_file(_channel_store_path(channel_name))
        previous_snapshot = previous_record.get("snapshot", {}) if isinstance(previous_record, dict) else {}
        snapshot = latest_snapshot or previous_snapshot or _empty_snapshot(
            channel_name=channel_name,
            session_name=session_name,
            role=role,
        )
        snapshot = {
            **snapshot,
            "channel": channel_name,
            "session_name": session_name,
            "role": role,
            "tmux_exists": bool(tmux_view.get("exists", False)),
            "source": snapshot.get("source", "nostr-store"),
            "snapshot_event_id": latest_snapshot_event.get("id", "") if latest_snapshot_event else "",
            "snapshot_created_at": int(latest_snapshot_event.get("created_at", 0) or 0)
            if latest_snapshot_event
            else int(snapshot.get("snapshot_created_at", 0) or 0),
            "stale": bool(previous_snapshot) and not bool(tmux_view.get("exists", False)),
        }
        latest_event = events[-1] if events else {}
        record = {
            "version": CHANNEL_STORE_VERSION,
            "channel": channel_name,
            "title": title,
            "session_name": session_name,
            "role": role,
            "tmux_exists": bool(tmux_view.get("exists", False)),
            "tmux_role": tmux_view.get("role", role),
            "snapshot": snapshot,
            "latest_event": latest_event,
            "latest_snapshot_event": latest_snapshot_event or {},
            "event_count": len(events),
            "recent_events": events[-10:],
            "updated_at": int(time.time()),
            "store_path": str(_channel_store_path(channel_name)),
        }
        _write_json_file(_channel_store_path(channel_name), record)
        return record

    def _build_relay_timeline(self, channel_records: list[dict[str, Any]]) -> dict[str, Any]:
        merged: list[dict[str, Any]] = []
        for record in channel_records:
            for event in record.get("recent_events", []):
                if isinstance(event, dict):
                    merged.append(_timeline_entry(event))
        merged.sort(key=lambda entry: int(entry.get("created_at", 0) or 0), reverse=True)
        payload = {
            "version": CHANNEL_STORE_VERSION,
            "updated_at": int(time.time()),
            "events": merged[:12],
        }
        _write_json_file(NOSTR_RELAY_TIMELINE_FILE, payload)
        return payload

    def _build_flow_topology(
        self,
        *,
        tmux_views: list[Dict[str, Any]],
        channel_records: list[dict[str, Any]],
    ) -> dict[str, Any]:
        game_view = next((view for view in tmux_views if view.get("session_name") == "hermes-cdda"), {})
        channel_map = {record.get("channel", ""): record for record in channel_records}
        human_record = channel_map.get("human-hermes", {})
        clone_record = channel_map.get("clone-hermes", {})
        supervisor_record = channel_map.get("supervisor-hermes", {})

        def _channel_active(record: dict[str, Any]) -> bool:
            snapshot = record.get("snapshot", {})
            return bool(record.get("event_count")) and bool(snapshot.get("result") or snapshot.get("tail"))

        rows = [
            {
                "from": "CDDA Raw",
                "to": "clone-hermes",
                "relation": "capture / observe",
                "status": "active" if game_view.get("exists") and _channel_active(clone_record) else "waiting",
                "source_kind": "raw-panel",
                "target_kind": "channel",
            },
            {
                "from": "clone-hermes",
                "to": "supervisor-hermes",
                "relation": "monitor / diagnose",
                "status": "active"
                if _channel_active(clone_record) and _channel_active(supervisor_record)
                else "waiting",
                "source_kind": "channel",
                "target_kind": "channel",
            },
            {
                "from": "human input",
                "to": "human-hermes",
                "relation": "instruction",
                "status": "active" if human_record.get("tmux_exists") else "waiting",
                "source_kind": "operator",
                "target_kind": "channel",
            },
            {
                "from": "human-hermes",
                "to": "relay-store",
                "relation": "publish snapshot",
                "status": "active" if _channel_active(human_record) else "waiting",
                "source_kind": "channel",
                "target_kind": "relay-store",
            },
            {
                "from": "clone-hermes",
                "to": "relay-store",
                "relation": "publish snapshot",
                "status": "active" if _channel_active(clone_record) else "waiting",
                "source_kind": "channel",
                "target_kind": "relay-store",
            },
            {
                "from": "supervisor-hermes",
                "to": "relay-store",
                "relation": "publish snapshot",
                "status": "active" if _channel_active(supervisor_record) else "waiting",
                "source_kind": "channel",
                "target_kind": "relay-store",
            },
        ]
        payload = {
            "version": CHANNEL_STORE_VERSION,
            "updated_at": int(time.time()),
            "nodes": [
                {"id": "cdda-raw", "title": "CDDA Raw", "kind": "raw-panel"},
                {"id": "human-input", "title": "human input", "kind": "operator"},
                {"id": "human-hermes", "title": "Human Hermes", "kind": "channel"},
                {"id": "clone-hermes", "title": "Clone Hermes", "kind": "channel"},
                {"id": "supervisor-hermes", "title": "Supervisor Hermes", "kind": "channel"},
                {"id": "relay-store", "title": "Local Relay Store", "kind": "relay-store"},
            ],
            "rows": rows,
        }
        _write_json_file(NOSTR_FLOW_TOPOLOGY_FILE, payload)
        return payload

    def _sync_channel_store(self, tmux_views: list[Dict[str, Any]]) -> dict[str, Any]:
        with self._channel_store_lock:
            human_hermes = next(
                (view for view in tmux_views if view.get("session_name") == HUMAN_HERMES_SESSION),
                {"session_name": HUMAN_HERMES_SESSION, "exists": False, "raw_text": "", "role": "human"},
            )
            channel_events = {
                "human-hermes": self._sync_human_hermes_channel(human_hermes),
                "clone-hermes": self._sync_tmux_agent_channel(
                    session_name="clone_hermes",
                    channel_name="clone-hermes",
                    pubkey="clone-hermes-web",
                    hash_file=NOSTR_CLONE_LAST_HASH,
                    role="actor",
                    tmux_views=tmux_views,
                ),
                "supervisor-hermes": self._sync_tmux_agent_channel(
                    session_name="supervisor",
                    channel_name="supervisor-hermes",
                    pubkey="supervisor-hermes-web",
                    hash_file=NOSTR_SUPERVISOR_LAST_HASH,
                    role="supervisor",
                    tmux_views=tmux_views,
                ),
            }
            tmux_by_session = {view.get("session_name", ""): view for view in tmux_views}
            channel_records = [
                self._channel_record(
                    channel_name=entry["channel"],
                    title=entry["title"],
                    session_name=entry["session_name"],
                    role=entry["role"],
                    tmux_view=tmux_by_session.get(entry["session_name"], {"session_name": entry["session_name"]}),
                    events=channel_events.get(entry["channel"], []),
                )
                for entry in CHANNEL_DEFINITIONS
            ]
            relay_timeline = self._build_relay_timeline(channel_records)
            flow_topology = self._build_flow_topology(
                tmux_views=tmux_views,
                channel_records=channel_records,
            )
            payload = {
                "version": CHANNEL_STORE_VERSION,
                "updated_at": int(time.time()),
                "base_dir": str(NOSTR_DIR),
                "channels": {record["channel"]: record for record in channel_records},
                "channel_order": [entry["channel"] for entry in CHANNEL_DEFINITIONS],
                "channel_snapshots": {
                    record["channel"]: record.get("snapshot", {})
                    for record in channel_records
                },
                "flow_topology": flow_topology,
                "relay_timeline": relay_timeline,
            }
            _write_json_file(NOSTR_CHANNEL_STORE_FILE, payload)
            return {
                "human_hermes": human_hermes,
                "human_channel_events": channel_events["human-hermes"],
                "clone_channel_events": channel_events["clone-hermes"],
                "supervisor_channel_events": channel_events["supervisor-hermes"],
                "channel_store": payload,
                "channel_snapshots": payload["channel_snapshots"],
                "flow_topology": flow_topology,
                "relay_timeline": relay_timeline,
            }

    def _read_json_file(self, path: Path) -> Dict[str, Any]:
        payload = read_json_file(path, {})
        return payload if isinstance(payload, dict) else {}

    def _read_commentary_tail(self, path: Path, limit: int = 16) -> list[str]:
        return read_text_tail(path, limit=limit)

    def _append_line(self, path: Path, line: str) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a", encoding="utf-8") as handle:
            handle.write(line + "\n")

    def _latest_round_dir(self, artifact_dir: str) -> Path | None:
        if not artifact_dir:
            return None
        base = Path(artifact_dir)
        if not base.exists():
            return None
        round_dirs = sorted(
            [path for path in base.iterdir() if path.is_dir() and path.name.startswith("round-")]
        )
        if not round_dirs:
            return None
        return round_dirs[-1]

    def _system_feed(self, artifact_dir: str) -> Dict[str, Any]:
        round_dir = self._latest_round_dir(artifact_dir)
        if round_dir is None:
            return {"round_dir": "", "event_lines": [], "tool_lines": []}

        event_lines: list[str] = []
        tool_lines: list[str] = []

        events_path = round_dir / "events.jsonl"
        if events_path.exists():
            rows = events_path.read_text(encoding="utf-8").splitlines()[-12:]
            for row in rows:
                try:
                    payload = json.loads(row)
                except json.JSONDecodeError:
                    continue
                kind = payload.get("kind", "event")
                if kind == "observed":
                    event_lines.append(
                        f"observed mode={payload.get('mode', '?')} location={payload.get('location', '-')}"
                    )
                elif kind == "acted":
                    keys = ",".join(payload.get("keys", []))
                    event_lines.append(f"acted keys={keys or '-'} repeat={payload.get('repeat', 1)}")
                elif kind == "session_started":
                    event_lines.append(
                        f"session_started size={payload.get('width', '?')}x{payload.get('height', '?')}"
                    )
                elif kind == "session_killed":
                    event_lines.append(f"session_killed reason={payload.get('reason', '-')}")
                else:
                    event_lines.append(kind)

        error_path = round_dir / "codex-error.txt"
        if error_path.exists():
            for line in error_path.read_text(encoding="utf-8").splitlines():
                stripped = line.strip()
                if stripped.startswith("mcp: "):
                    tool_lines.append(stripped)
            tool_lines = tool_lines[-12:]

        return {
            "round_dir": str(round_dir),
            "event_lines": event_lines[-12:],
            "tool_lines": tool_lines,
        }

    def _live_payload(self) -> Dict[str, Any]:
        state_dir = state_dir_from(str(LIVE_DIR))
        status = self._read_json_file(LIVE_DIR / "loop-status.json")
        latest = self._read_json_file(LIVE_DIR / "latest.json")
        commentary = self._read_commentary_tail(LIVE_DIR / "commentary.log")
        human_messages = self._read_commentary_tail(human_log_path(state_dir), limit=10)
        control = ensure_control(state_dir)
        pending_messages = pending_human_messages(state_dir)
        artifact_dir = status.get("artifact_dir", "")
        return {
            "active": bool(status.get("active", False)),
            "run_id": status.get("run_id", ""),
            "round": status.get("round", 0),
            "round_status": status.get("round_status", "inactive"),
            "model": status.get("model", ""),
            "model_choice": status.get("model_choice", ""),
            "loop_session": status.get("loop_session", ""),
            "game_session": status.get("game_session", ""),
            "artifact_dir": artifact_dir,
            "last_exit_code": status.get("last_exit_code", 0),
            "updated_at": status.get("updated_at", ""),
            "reflection_level": status.get(
                "reflection_level",
                control.get("reflection_level", "plain"),
            ),
            "pending_human_message_count": status.get(
                "pending_human_message_count",
                len(pending_messages),
            ),
            "current_exec_pid": status.get("current_exec_pid", 0),
            "current_exec_round": status.get("current_exec_round", 0),
            "last_completed_round": status.get("last_completed_round", 0),
            "last_round_action_count": status.get("last_round_action_count", 0),
            "last_round_outcome": status.get("last_round_outcome", "none"),
            "latest": latest,
            "commentary_tail": commentary,
            "human_messages_tail": human_messages,
            "system": self._system_feed(artifact_dir),
        }

    def _read_json_body(self) -> Dict[str, Any]:
        length = int(self.headers.get("Content-Length", "0"))
        if length <= 0:
            return {}
        raw = self.rfile.read(length)
        if not raw:
            return {}
        return json.loads(raw.decode("utf-8"))

    def _send_json(self, payload: Dict[str, Any], status: int = HTTPStatus.OK) -> None:
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def _send_html(self) -> None:
        body = HTML_PATH.read_bytes()
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def _session_payload(self, history_lines: int = 220) -> Dict[str, Any]:
        session_name = self.runtime.session_name(None)
        info = self.runtime.session_info(session_name)
        tmux_views = self._tracked_tmux_views()
        game_view = next(
            (view for view in tmux_views if view.get("session_name") == "hermes-cdda"),
            {"session_name": "hermes-cdda", "exists": False, "raw_text": ""},
        )
        channel_payload = self._sync_channel_store(tmux_views)
        if not info["exists"]:
            return {
                **info,
                "live": self._live_payload(),
                "raw_panel_view": game_view,
                "debug_tmux_views": tmux_views,
                "tmux_views": tmux_views,
                **channel_payload,
            }
        observed = self.runtime.observe(
            {"session_name": session_name, "history_lines": history_lines}
        )["structuredContent"]
        return {
            **info,
            **observed,
            "live": self._live_payload(),
            "raw_panel_view": game_view,
            "debug_tmux_views": tmux_views,
            "tmux_views": tmux_views,
            **channel_payload,
        }

    def do_GET(self) -> None:  # noqa: N802
        if self.path in {"/", "/index.html"}:
            self._send_html()
            return
        if self.path.startswith("/api/state"):
            try:
                payload = self._session_payload()
                self._send_json({"ok": True, "state": payload})
            except Exception as exc:  # pragma: no cover - handler boundary
                self._send_json({"ok": False, "error": str(exc)}, status=HTTPStatus.INTERNAL_SERVER_ERROR)
            return
        if self.path.startswith("/api/nostr/events"):
            try:
                channel = None
                if "?" in self.path:
                    query = self.path.split("?", 1)[1]
                    for part in query.split("&"):
                        if part.startswith("channel="):
                            channel = part.split("=", 1)[1] or None
                tmux_views = self._tracked_tmux_views()
                channel_payload = self._sync_channel_store(tmux_views)
                self._send_json(
                    {
                        "ok": True,
                        "events": read_local_nostr_events(channel=channel, limit=40),
                        "channel_store": channel_payload.get("channel_store", {}),
                        "channel_snapshots": channel_payload.get("channel_snapshots", {}),
                        "relay_timeline": channel_payload.get("relay_timeline", {}),
                        "flow_topology": channel_payload.get("flow_topology", {}),
                    }
                )
            except Exception as exc:  # pragma: no cover - handler boundary
                self._send_json({"ok": False, "error": str(exc)}, status=HTTPStatus.INTERNAL_SERVER_ERROR)
            return
        if self.path.startswith("/api/health"):
            self._send_json({"ok": True})
            return
        self.send_error(HTTPStatus.NOT_FOUND)

    def do_POST(self) -> None:  # noqa: N802
        try:
            body = self._read_json_body()
            if self.path == "/api/ensure-game":
                payload = self.runtime.ensure_game(body)
                self._send_json({"ok": True, "state": payload})
                return
            if self.path == "/api/reach-playable":
                payload = self.runtime.reach_playable(body)["structuredContent"]
                self._send_json({"ok": True, "state": payload})
                return
            if self.path == "/api/act":
                payload = self.runtime.act(body)["structuredContent"]
                self._send_json({"ok": True, "state": payload})
                return
            if self.path == "/api/stop-session":
                payload = self.runtime.stop_session(body)["structuredContent"]
                self._send_json({"ok": True, "state": payload})
                return
            if self.path == "/api/human-message":
                text = str(body.get("text", "")).strip()
                if not text:
                    self._send_json(
                        {"ok": False, "error": "human message text is required"},
                        status=HTTPStatus.BAD_REQUEST,
                    )
                    return
                self._append_line(human_log_path(state_dir_from(str(LIVE_DIR))), text)
                queue_human_message(
                    state_dir_from(str(LIVE_DIR)),
                    text=text,
                    interrupt=True,
                )
                self._send_json({"ok": True, "state": self._session_payload()})
                return
            if self.path == "/api/human-hermes/start":
                self._ensure_human_hermes(inject_bootstrap=True)
                self._send_json({"ok": True, "state": self._session_payload()})
                return
            if self.path == "/api/human-hermes/send":
                text = str(body.get("text", "")).strip()
                if not text:
                    self._send_json(
                        {"ok": False, "error": "human Hermes text is required"},
                        status=HTTPStatus.BAD_REQUEST,
                    )
                    return
                message_event, _ = self._send_human_hermes_text(
                    text,
                    press_enter=bool(body.get("press_enter", True)),
                    wait_ms=int(body.get("wait_ms", 800)),
                )
                state = self._wait_for_human_hermes_snapshot(
                    message_created_at=int(message_event.get("created_at", 0) or 0),
                    timeout_ms=int(body.get("await_snapshot_ms", 15000)),
                )
                self._send_json({"ok": True, "state": state})
                return
            if self.path == "/api/live-config":
                reflection_level = body.get("reflection_level")
                payload = set_control(
                    state_dir_from(str(LIVE_DIR)),
                    reflection_level=str(reflection_level) if reflection_level is not None else None,
                )
                self._send_json(
                    {
                        "ok": True,
                        "control": payload,
                        "state": self._session_payload(),
                    }
                )
                return
            self.send_error(HTTPStatus.NOT_FOUND)
        except Exception as exc:  # pragma: no cover - handler boundary
            self._send_json({"ok": False, "error": str(exc)}, status=HTTPStatus.INTERNAL_SERVER_ERROR)

    def log_message(self, format: str, *args: Any) -> None:  # noqa: A003
        self.runtime.debug("web " + format % args)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()

    server = ThreadingHTTPServer((args.host, args.port), CddaDashboardHandler)
    print(f"http://{args.host}:{args.port}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
