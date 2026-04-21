#!/usr/bin/env python3
"""Helpers for the public live commentary state consumed by the dashboard."""

from __future__ import annotations

import argparse
import json
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_STATE_DIR = ROOT / "tmp/live/current"
VALID_REFLECTION_LEVELS = ("plain", "reflective", "story")


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def state_dir_from(value: str | None) -> Path:
    if value:
        return Path(value).expanduser().resolve()
    return DEFAULT_STATE_DIR


def control_path(state_dir: Path) -> Path:
    return state_dir / "control.json"


def commentary_path(state_dir: Path) -> Path:
    return state_dir / "commentary.log"


def latest_path(state_dir: Path) -> Path:
    return state_dir / "latest.json"


def exec_status_path(state_dir: Path) -> Path:
    return state_dir / "exec-status.json"


def inbox_path(state_dir: Path) -> Path:
    return state_dir / "human-inbox.jsonl"


def human_log_path(state_dir: Path) -> Path:
    return state_dir / "human-messages.log"


def game_state_path(state_dir: Path) -> Path:
    return state_dir / "game-state.md"


def read_json_file(path: Path, default: Any) -> Any:
    if not path.exists():
        return default
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return default


def write_json_file(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def append_text_line(path: Path, line: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(line.rstrip("\n") + "\n")


def read_text_tail(path: Path, limit: int = 16) -> list[str]:
    if not path.exists():
        return []
    lines = path.read_text(encoding="utf-8").splitlines()
    return lines[-limit:]


def read_jsonl(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    rows: list[dict[str, Any]] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        try:
            payload = json.loads(line)
        except json.JSONDecodeError:
            continue
        if isinstance(payload, dict):
            rows.append(payload)
    return rows


def write_jsonl(path: Path, rows: list[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    content = "".join(json.dumps(row, ensure_ascii=False) + "\n" for row in rows)
    path.write_text(content, encoding="utf-8")


def validate_reflection_level(value: str | None) -> str:
    if not value:
        return "plain"
    normalized = value.strip().lower()
    if normalized not in VALID_REFLECTION_LEVELS:
        raise ValueError(
            f"reflection_level must be one of {', '.join(VALID_REFLECTION_LEVELS)}"
        )
    return normalized


def default_control() -> dict[str, Any]:
    return {
        "reflection_level": "plain",
        "interrupt_requested": False,
        "interrupt_reason": "",
        "updated_at": utc_now(),
    }


def ensure_control(state_dir: Path) -> dict[str, Any]:
    current = read_json_file(control_path(state_dir), {})
    payload = default_control()
    if isinstance(current, dict):
        payload.update(current)
    payload["reflection_level"] = validate_reflection_level(payload.get("reflection_level"))
    payload["interrupt_requested"] = bool(payload.get("interrupt_requested", False))
    payload["interrupt_reason"] = str(payload.get("interrupt_reason", "") or "")
    payload["updated_at"] = str(payload.get("updated_at", "") or utc_now())
    write_json_file(control_path(state_dir), payload)
    return payload


def set_control(
    state_dir: Path,
    *,
    reflection_level: str | None = None,
    interrupt_requested: bool | None = None,
    interrupt_reason: str | None = None,
) -> dict[str, Any]:
    payload = ensure_control(state_dir)
    if reflection_level is not None:
        payload["reflection_level"] = validate_reflection_level(reflection_level)
    if interrupt_requested is not None:
        payload["interrupt_requested"] = bool(interrupt_requested)
    if interrupt_reason is not None:
        payload["interrupt_reason"] = interrupt_reason
    payload["updated_at"] = utc_now()
    write_json_file(control_path(state_dir), payload)
    return payload


def reset_interrupt(state_dir: Path) -> dict[str, Any]:
    return set_control(
        state_dir,
        interrupt_requested=False,
        interrupt_reason="",
    )


def queue_human_message(
    state_dir: Path,
    *,
    text: str,
    interrupt: bool = True,
) -> dict[str, Any]:
    message_text = text.strip()
    if not message_text:
        raise ValueError("human message text is required")
    row = {
        "id": f"human-{uuid.uuid4().hex[:12]}",
        "created_at": utc_now(),
        "text": message_text,
        "interrupt": bool(interrupt),
        "consumed_by_round": None,
    }
    append_text_line(inbox_path(state_dir), json.dumps(row, ensure_ascii=False))
    if interrupt:
        set_control(
            state_dir,
            interrupt_requested=True,
            interrupt_reason="human_message",
        )
    return row


def pending_human_messages(state_dir: Path) -> list[dict[str, Any]]:
    return [row for row in read_jsonl(inbox_path(state_dir)) if row.get("consumed_by_round") is None]


def mark_messages_consumed(
    state_dir: Path,
    message_ids: list[str],
    round_number: int,
) -> list[dict[str, Any]]:
    rows = read_jsonl(inbox_path(state_dir))
    id_set = set(message_ids)
    for row in rows:
        if row.get("id") in id_set and row.get("consumed_by_round") is None:
            row["consumed_by_round"] = round_number
    write_jsonl(inbox_path(state_dir), rows)
    return rows


def append_commentary(
    state_dir: Path,
    *,
    round_number: int,
    channel: str,
    text: str,
) -> None:
    state_dir.mkdir(parents=True, exist_ok=True)
    commentary_text = text.strip()
    if not commentary_text:
        return
    line = f"[{utc_now()}] round {round_number} {channel}: {commentary_text}"
    append_text_line(commentary_path(state_dir), line)


def write_latest_payload(
    state_dir: Path,
    *,
    run_id: str,
    round_number: int,
    model: str,
    keys: str,
    plan: str,
    reflection: str,
    result: str,
    mode: str,
    location: str,
    action_count: int = 0,
    round_outcome: str = "running",
    reflection_level: str = "plain",
) -> dict[str, Any]:
    payload = {
        "updated_at": utc_now(),
        "run_id": run_id,
        "round": round_number,
        "model": model,
        "last_keys": keys,
        "last_plan": plan,
        "last_reflection": reflection,
        "last_result": result,
        "mode": mode,
        "location": location,
        "action_count": int(action_count),
        "round_outcome": round_outcome,
        "reflection_level": validate_reflection_level(reflection_level),
    }
    write_json_file(latest_path(state_dir), payload)
    return payload


def update_latest_fields(
    state_dir: Path,
    *,
    expected_round: int,
    action_count: int,
    round_outcome: str,
    reflection_level: str,
) -> dict[str, Any]:
    payload = read_json_file(latest_path(state_dir), {})
    if not isinstance(payload, dict) or int(payload.get("round", -1)) != expected_round:
        payload = {
            "updated_at": utc_now(),
            "run_id": "",
            "round": expected_round,
            "model": "",
            "last_keys": "",
            "last_plan": "",
            "last_reflection": "",
            "last_result": "",
            "mode": "unknown",
            "location": "",
        }
    payload["updated_at"] = utc_now()
    payload["action_count"] = int(action_count)
    payload["round_outcome"] = round_outcome
    payload["reflection_level"] = validate_reflection_level(reflection_level)
    write_json_file(latest_path(state_dir), payload)
    return payload


def write_exec_status(state_dir: Path, payload: dict[str, Any]) -> dict[str, Any]:
    data = dict(payload)
    data.setdefault("updated_at", utc_now())
    write_json_file(exec_status_path(state_dir), data)
    return data


def summarize_round_events(round_dir: Path) -> dict[str, Any]:
    rows = read_jsonl(round_dir / "events.jsonl")
    action_events = [row for row in rows if row.get("kind") == "acted"]
    action_count = len(action_events)
    keys_sent = 0
    last_keys = ""
    for row in action_events:
        keys = row.get("keys") or []
        repeat = int(row.get("repeat", 1) or 1)
        keys_sent += len(keys) * repeat
        if keys:
            last_keys = ",".join(str(key) for key in keys)
    return {
        "event_count": len(rows),
        "action_count": action_count,
        "keys_sent": keys_sent,
        "last_keys": last_keys,
    }


def write_round_summary(round_dir: Path, payload: dict[str, Any]) -> dict[str, Any]:
    round_dir.mkdir(parents=True, exist_ok=True)
    data = dict(payload)
    data.setdefault("updated_at", utc_now())
    write_json_file(round_dir / "round-summary.json", data)
    return data


def ensure_game_state_template(state_dir: Path) -> Path:
    path = game_state_path(state_dir)
    if path.exists():
        return path
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        "\n".join(
            [
                "# Game State",
                "",
                "Last Updated: unknown",
                "",
                "## Current Location",
                "- unknown",
                "",
                "## Visible Situation",
                "- No round has summarized the scene yet.",
                "",
                "## Short-Term Intent",
                "- Reach a stable playable loop.",
                "",
                "## Wield / Gear Notes",
                "- unknown",
                "",
                "## Open Questions / Risks",
                "- unknown",
                "",
                "## Recent Round Recap",
                "- No recap yet.",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return path


def build_round_request(
    *,
    run_id: str,
    round_number: int,
    model: str,
    game_session: str,
    reflection_level: str,
    last_round_action_count: int,
    last_round_outcome: str,
    pending_messages: list[dict[str, Any]],
    game_state_text: str,
) -> str:
    message_lines = [
        f"- [{row.get('id', 'unknown')}] {row.get('text', '').strip()}"
        for row in pending_messages
        if str(row.get("text", "")).strip()
    ]
    reflection_contract = {
        "plain": "公开反思写 1 句中文，直接描述当前动作和屏幕事实。",
        "reflective": "公开反思写 2-3 句中文，包含你看到的局面和为什么这样做。",
        "story": "公开反思写 3-5 句中文，允许更有故事感，但必须严格基于当前真实观察。",
    }[validate_reflection_level(reflection_level)]
    return "\n".join(
        [
            f"运行 ID: {run_id}",
            f"回合: {round_number}",
            f"模型: {model}",
            f"游戏会话: {game_session}",
            f"直播风格: {reflection_level}",
            "直播风格要求:",
            f"- {reflection_contract}",
            f"上一轮动作数: {last_round_action_count}",
            f"上一轮结果: {last_round_outcome}",
            "待处理的人类消息:",
            *(message_lines or ["- 无"]),
            "",
            "本轮只保留这些同步要求：",
            "- 正常继续游戏，自由决策，不预设固定动作数或固定路线。",
            "- 用 live_state.py 追加 commentary / reflection / result 三类公开直播文本。",
            "- 结束前更新 tmp/live/current/game-state.md。",
            "- 结束前更新 tmp/live/current/latest.json。",
            "",
            "当前 game-state 文档:",
            game_state_text.strip() or "(missing)",
            "",
        ]
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    append_parser = subparsers.add_parser("append")
    append_parser.add_argument("--state-dir")
    append_parser.add_argument("--round", type=int, required=True)
    append_parser.add_argument(
        "--channel",
        choices=["commentary", "reflection", "result"],
        required=True,
    )
    append_parser.add_argument("--text", required=True)
    append_parser.set_defaults(func=append_command)

    latest_parser = subparsers.add_parser("latest")
    latest_parser.add_argument("--state-dir")
    latest_parser.add_argument("--run-id", required=True)
    latest_parser.add_argument("--round", type=int, required=True)
    latest_parser.add_argument("--model", required=True)
    latest_parser.add_argument("--keys", required=True)
    latest_parser.add_argument("--plan", required=True)
    latest_parser.add_argument("--reflection", required=True)
    latest_parser.add_argument("--result", required=True)
    latest_parser.add_argument("--mode", required=True)
    latest_parser.add_argument("--location", required=True)
    latest_parser.add_argument("--action-count", type=int, default=0)
    latest_parser.add_argument("--round-outcome", default="running")
    latest_parser.add_argument("--reflection-level", default="plain")
    latest_parser.set_defaults(func=latest_command)

    control_parser = subparsers.add_parser("set-control")
    control_parser.add_argument("--state-dir")
    control_parser.add_argument("--reflection-level")
    control_parser.add_argument("--interrupt-requested")
    control_parser.add_argument("--interrupt-reason")
    control_parser.set_defaults(func=set_control_command)

    queue_parser = subparsers.add_parser("queue-human")
    queue_parser.add_argument("--state-dir")
    queue_parser.add_argument("--text", required=True)
    queue_parser.add_argument("--no-interrupt", action="store_true")
    queue_parser.set_defaults(func=queue_human_command)

    return parser


def parse_bool(value: str | None) -> bool | None:
    if value is None:
        return None
    normalized = value.strip().lower()
    if normalized in {"1", "true", "yes", "on"}:
        return True
    if normalized in {"0", "false", "no", "off"}:
        return False
    raise ValueError("boolean value must be true/false")


def append_command(args: argparse.Namespace) -> int:
    state_dir = state_dir_from(args.state_dir)
    append_commentary(
        state_dir,
        round_number=args.round,
        channel=args.channel,
        text=args.text,
    )
    return 0


def latest_command(args: argparse.Namespace) -> int:
    state_dir = state_dir_from(args.state_dir)
    write_latest_payload(
        state_dir,
        run_id=args.run_id,
        round_number=args.round,
        model=args.model,
        keys=args.keys,
        plan=args.plan,
        reflection=args.reflection,
        result=args.result,
        mode=args.mode,
        location=args.location,
        action_count=args.action_count,
        round_outcome=args.round_outcome,
        reflection_level=args.reflection_level,
    )
    return 0


def set_control_command(args: argparse.Namespace) -> int:
    state_dir = state_dir_from(args.state_dir)
    payload = set_control(
        state_dir,
        reflection_level=args.reflection_level,
        interrupt_requested=parse_bool(args.interrupt_requested),
        interrupt_reason=args.interrupt_reason,
    )
    print(json.dumps(payload, ensure_ascii=False))
    return 0


def queue_human_command(args: argparse.Namespace) -> int:
    state_dir = state_dir_from(args.state_dir)
    payload = queue_human_message(
        state_dir,
        text=args.text,
        interrupt=not args.no_interrupt,
    )
    print(json.dumps(payload, ensure_ascii=False))
    return 0


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
