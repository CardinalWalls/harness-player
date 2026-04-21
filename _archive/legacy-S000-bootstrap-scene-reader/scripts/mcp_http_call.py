#!/usr/bin/env python3
"""Minimal HTTP client for the local MCP proxy."""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.request
from typing import Any


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("method", help="JSON-RPC method to call")
    parser.add_argument(
        "--params",
        default="{}",
        help="JSON object used as the request params (default: {})",
    )
    parser.add_argument(
        "--url",
        default="http://127.0.0.1:8766/mcp",
        help="HTTP MCP endpoint (default: http://127.0.0.1:8766/mcp)",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=45.0,
        help="Request timeout in seconds (default: 45)",
    )
    return parser.parse_args()


def parse_response(body: str) -> Any:
    stripped = body.lstrip()
    if stripped.startswith("{"):
        payload = json.loads(stripped)
        if payload.get("error"):
            raise RuntimeError(payload["error"].get("message", "MCP request failed"))
        return payload.get("result", payload)

    events: list[str] = []
    for line in body.splitlines():
        if line.startswith("data: "):
            events.append(line[6:])
    if not events:
        raise RuntimeError(f"unexpected MCP response body: {body[:240]}")

    payload = json.loads(events[-1])
    if payload.get("error"):
        raise RuntimeError(payload["error"].get("message", "MCP request failed"))
    return payload.get("result", payload)


def main() -> int:
    args = parse_args()
    try:
        params = json.loads(args.params)
    except json.JSONDecodeError as exc:
        print(f"invalid --params JSON: {exc}", file=sys.stderr)
        return 2

    request_body = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": args.method,
        "params": params,
    }
    data = json.dumps(request_body).encode("utf-8")
    request = urllib.request.Request(
        args.url,
        data=data,
        headers={
            "content-type": "application/json",
            "accept": "application/json, text/event-stream",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=args.timeout) as response:
            body = response.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        details = exc.read().decode("utf-8", errors="replace")
        print(f"http error {exc.code}: {details}", file=sys.stderr)
        return 1
    except urllib.error.URLError as exc:
        print(f"url error: {exc.reason}", file=sys.stderr)
        return 1

    try:
        result = parse_response(body)
    except Exception as exc:  # pragma: no cover - CLI boundary
        print(str(exc), file=sys.stderr)
        return 1

    json.dump(result, sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
