#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
URL="${CDDA_WEB_URL:-http://127.0.0.1:8875}"

for _ in $(seq 1 20); do
  if curl -fsS "$URL/api/health" >/dev/null 2>&1 \
    && curl -fsS "$URL/api/state" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

python3 - <<'PY' "$URL"
import json
import sys
import time
import urllib.request

url = sys.argv[1]

with urllib.request.urlopen(f"{url}/api/state", timeout=10) as response:
    payload = json.loads(response.read().decode())

with urllib.request.urlopen(f"{url}/api/nostr/events", timeout=10) as response:
    relay_payload = json.loads(response.read().decode())

assert payload.get("ok") is True, payload
assert relay_payload.get("ok") is True, relay_payload
state = payload["state"]
tmux_views = state.get("tmux_views", [])
human_events = state.get("human_channel_events", [])
clone_events = state.get("clone_channel_events", [])
supervisor_events = state.get("supervisor_channel_events", [])
channel_snapshots = state.get("channel_snapshots", {})
flow_topology = state.get("flow_topology", {})
relay_timeline = state.get("relay_timeline", {})
relay_events = relay_payload.get("events", [])

names = [view.get("session_name") for view in tmux_views]
required = {
    "hermes-cdda",
    "clone_hermes",
    "supervisor",
    "cdda-mcp-proxy",
    "clone-hermes-mcp-proxy",
    "human_hermes_web",
}
missing = sorted(required.difference(names))
assert not missing, {"missing_tmux_views": missing, "names": names}

assert state.get("human_hermes", {}).get("exists") is True, state.get("human_hermes")
assert len(human_events) > 0, "no human channel events"
assert len(clone_events) > 0, "no clone channel events"
assert len(supervisor_events) > 0, "no supervisor channel events"
assert len(relay_events) > 0, "no relay events"
assert {"human-hermes", "clone-hermes", "supervisor-hermes"}.issubset(channel_snapshots.keys()), channel_snapshots
assert len(flow_topology.get("rows", [])) >= 4, flow_topology
assert len(relay_timeline.get("events", [])) > 0, relay_timeline
relay_channels = {
    tag[1]
    for event in relay_events
    for tag in event.get("tags", [])
    if isinstance(tag, list) and len(tag) >= 2 and tag[0] == "channel"
}
assert {"human-hermes", "clone-hermes", "supervisor-hermes"}.issubset(relay_channels), relay_channels
human_event_count_before = len(human_events)

for label, events in [
    ("human", human_events),
    ("clone", clone_events),
    ("supervisor", supervisor_events),
]:
    last = events[-1]
    assert last.get("kind") == 24102 or label == "human", (label, last)
    assert "channel" in [tag[0] for tag in last.get("tags", []) if isinstance(tag, list) and tag], (label, last)
    assert last.get("content"), (label, last)
    parsed = json.loads(last.get("content"))
    assert parsed.get("observation"), (label, "missing observation", parsed)
    assert parsed.get("plan"), (label, "missing plan", parsed)
    assert parsed.get("result"), (label, "missing result", parsed)
    assert parsed.get("health"), (label, "missing health", parsed)
    assert parsed.get("structured") is True, (label, "channel not structured enough", parsed)
    if label == "human":
        assert parsed.get("health") == "healthy", (label, "unexpected health", parsed)
    else:
        assert parsed.get("health") == "degraded", (label, "unexpected health", parsed)

message = f"proof ping {int(time.time())}: 请按结构化格式一句话确认 scene 仍然存活。"
request = urllib.request.Request(
    f"{url}/api/human-hermes/send",
    data=json.dumps(
        {
            "text": message,
            "press_enter": True,
            "wait_ms": 1800,
            "await_snapshot_ms": 45000,
        }
    ).encode(),
    headers={"Content-Type": "application/json"},
    method="POST",
)
with urllib.request.urlopen(request, timeout=60) as response:
    payload = json.loads(response.read().decode())

assert payload.get("ok") is True, payload
state = payload["state"]
human_events = state.get("human_channel_events", [])
matching_human_messages = [
    event for event in human_events
    if event.get("kind") == 24101 and event.get("content") == message
]
assert matching_human_messages, {
    "error": "human message did not appear in live channel",
    "message": message,
    "recent_human_events": human_events[-5:],
}
latest_message = matching_human_messages[-1]
latest_human_event = None
for _ in range(45):
    with urllib.request.urlopen(f"{url}/api/state", timeout=10) as response:
        payload = json.loads(response.read().decode())
    state = payload["state"]
    human_events = state.get("human_channel_events", [])
    latest_human_event = next(
        (
            event for event in reversed(human_events)
            if event.get("kind") == 24102
            and event.get("created_at", 0) >= latest_message.get("created_at", 0)
        ),
        None,
    )
    if latest_human_event is not None:
        break
    time.sleep(1)
assert latest_human_event is not None, human_events[-5:]
latest_human = json.loads(latest_human_event["content"])
assert latest_human.get("observation"), latest_human
assert latest_human.get("plan"), latest_human
assert latest_human.get("result"), latest_human
assert latest_human.get("health"), latest_human

print("dashboard channel proof ok")
print(json.dumps(
    {
        "tmux_views": names,
        "human_events_before": human_event_count_before,
        "human_events_after": len(human_events),
        "human_message_seen": True,
        "human_snapshot_after_message": True,
        "clone_events": len(clone_events),
        "supervisor_events": len(supervisor_events),
        "relay_event_count": len(relay_events),
        "relay_timeline_events": len(relay_timeline.get("events", [])),
        "flow_topology_rows": len(flow_topology.get("rows", [])),
        "clone_health": json.loads(clone_events[-1]["content"]).get("health"),
        "supervisor_health": json.loads(supervisor_events[-1]["content"]).get("health"),
        "latest_human_result": latest_human.get("result"),
    },
    ensure_ascii=False,
    indent=2,
))
PY
