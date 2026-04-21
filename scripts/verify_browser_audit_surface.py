#!/usr/bin/env python3
"""Static verification for S002 browser audit surface.

This intentionally uses only Python standard library so S002 does not add a
browser-test dependency. It verifies the story contract from
_mynot/3-plan/stories/S002-browser-audit-surface.md.
"""
from __future__ import annotations

import json
import re
import sys
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HTML_PATH = ROOT / "web" / "index.html"
STORY_PATH = ROOT / "_mynot" / "3-plan" / "stories" / "S002-browser-audit-surface.md"
REQUIRED_FIELDS = [
    "channel",
    "signer_actor_id",
    "signer_role",
    "causation_ids",
    "correlation_id",
    "payload",
    "valid",
]
SYSTEM_CHANNELS = {
    "human_input",
    "scene_observation",
    "action_decision",
    "action_effect",
}
FORBIDDEN_ACCEPTED_SIGNERS = {"browser", "server", "relay"}
FORBIDDEN_CALL_MARKERS = ["fetch(", "XMLHttpRequest", "sendBeacon("]
GUARDRAIL_TERMS = ["render/input only", "/api/*", "MCP", "server-authored", "scripted-screen"]


class AuditSurfaceParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.in_demo = False
        self.demo_json_parts: list[str] = []
        self.ids: set[str] = set()
        self.data_tests: set[str] = set()
        self.text_parts: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        attr = {k: v or "" for k, v in attrs}
        if "id" in attr:
            self.ids.add(attr["id"])
        if "data-test" in attr:
            self.data_tests.add(attr["data-test"])
        if tag == "script" and attr.get("id") == "demo-envelopes" and attr.get("type") == "application/json":
            self.in_demo = True

    def handle_endtag(self, tag: str) -> None:
        if tag == "script" and self.in_demo:
            self.in_demo = False

    def handle_data(self, data: str) -> None:
        self.text_parts.append(data)
        if self.in_demo:
            self.demo_json_parts.append(data)


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    raise SystemExit(1)


def assert_true(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def load_surface() -> tuple[str, AuditSurfaceParser, list[dict]]:
    assert_true(STORY_PATH.exists(), f"missing story file: {STORY_PATH}")
    assert_true(HTML_PATH.exists(), f"missing browser surface: {HTML_PATH}")
    html = HTML_PATH.read_text(encoding="utf-8")
    parser = AuditSurfaceParser()
    parser.feed(html)
    raw_json = "".join(parser.demo_json_parts).strip()
    assert_true(bool(raw_json), "missing <script id=\"demo-envelopes\" type=\"application/json\"> data")
    try:
        envelopes = json.loads(raw_json)
    except json.JSONDecodeError as exc:
        fail(f"demo envelope JSON is invalid: {exc}")
    assert_true(isinstance(envelopes, list), "demo envelopes must be a JSON list")
    return html, parser, envelopes


def verify_envelopes(envelopes: list[dict]) -> None:
    assert_true(len(envelopes) >= 6, "expected at least six accepted envelopes covering S000 and S001")
    channels = {e.get("channel") for e in envelopes}
    for required in ["scene_observation", "action_decision", "action_effect", "human_input"]:
        assert_true(required in channels, f"missing accepted channel {required}")
    for index, envelope in enumerate(envelopes):
        assert_true(isinstance(envelope, dict), f"envelope {index} must be an object")
        for field in REQUIRED_FIELDS:
            assert_true(field in envelope, f"envelope {index} missing field {field}")
        assert_true(envelope.get("valid") is True, f"envelope {index} must be marked valid=true")
        assert_true(envelope.get("signature"), f"envelope {index} missing signature")
        assert_true(envelope.get("signature") == f"sig:{envelope.get('signer_actor_id')}:{envelope.get('channel')}:{envelope.get('id')}", f"envelope {index} signature does not match semantic format")
        assert_true(envelope.get("causation_ids"), f"envelope {index} needs causation evidence")
        if envelope.get("channel") in SYSTEM_CHANNELS:
            assert_true(envelope.get("signer_actor_id") not in FORBIDDEN_ACCEPTED_SIGNERS, f"forbidden accepted signer {envelope.get('signer_actor_id')} on {envelope.get('channel')}")
        payload = envelope.get("payload")
        assert_true(isinstance(payload, dict), f"envelope {index} payload must be an object for inspectable summaries")
        payload_text = json.dumps(payload, sort_keys=True)
        assert_true("/api/" not in payload_text, f"envelope {index} payload contains privileged /api/ path")
        assert_true("scripted_authority" not in payload_text, f"envelope {index} payload contains scripted authority marker")


def verify_dom_and_source(html: str, parser: AuditSurfaceParser) -> None:
    visible_text = " ".join(part.strip() for part in parser.text_parts if part.strip())
    for term in GUARDRAIL_TERMS:
        assert_true(term in visible_text or term in html, f"missing guardrail term: {term}")
    for field in REQUIRED_FIELDS:
        assert_true(field in html, f"missing visible/source field label: {field}")
    required_tests = {
        "guardrail",
        "envelope-list",
        "human-input-form",
        "human-input-preview",
        "human-input-error",
    }
    missing_tests = required_tests - parser.data_tests
    assert_true(not missing_tests, f"missing data-test hooks: {sorted(missing_tests)}")
    for marker in FORBIDDEN_CALL_MARKERS:
        assert_true(marker not in html, f"forbidden browser network call marker present: {marker}")
    for marker in ["function signatureFor", "function validateHumanInput", "function createHumanInputPreview", "function renderEnvelopes"]:
        assert_true(marker in html, f"missing composer/render function marker: {marker}")
    assert_true('signer_actor_id: "human"' in html or "signer_actor_id: 'human'" in html, "composer must fix signer_actor_id to human")
    assert_true('channel: "human_input"' in html or "channel: 'human_input'" in html, "composer must create human_input channel")
    assert_true("includes('/api/')" in html or 'includes("/api/")' in html, "composer must reject /api/ text or context")
    assert_true(re.search(r"text\.trim\(\)\.length\s*===\s*0", html), "composer must reject empty text")


def main() -> int:
    html, parser, envelopes = load_surface()
    verify_envelopes(envelopes)
    verify_dom_and_source(html, parser)
    print("PASS: S002 browser audit surface satisfies static contract")
    return 0


if __name__ == "__main__":
    sys.exit(main())
