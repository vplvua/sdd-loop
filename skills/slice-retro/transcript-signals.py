#!/usr/bin/env python3
"""Retro signals from one Claude Code session transcript (stdlib only).

Usage: python3 transcript-signals.py <session>.jsonl [verify command]
Prints time bounds, commands and model switches, owner turns, rejected
tool calls with what they asked, verify-gate blocks, pasted /cost, and
idle gaps over 30 min after the agent's last turn. Output is for the
retro author's eyes: quote sparingly, never paste it into the artifact.
"""
import json, sys
from datetime import datetime

path, verify = sys.argv[1], (sys.argv[2] if len(sys.argv) > 2 else "verify")
REJECT = "The user doesn't want to proceed with this tool use"
ts = lambda e: datetime.fromisoformat(e["timestamp"].replace("Z", "+00:00")).astimezone()
entries = [json.loads(l) for l in open(path) if l.strip()]
entries = [e for e in entries if "timestamp" in e and not e.get("isSidechain")]
uses, asked_at, model = {}, None, None
print(f"{path}\n  {ts(entries[0]):%m-%d %H:%M} -> {ts(entries[-1]):%m-%d %H:%M} local")
for e in entries:
    if e.get("type") == "assistant":
        asked_at = e
        if e["message"].get("model") not in (model, "<synthetic>"):
            model = e["message"]["model"]
            print(f"  MODEL {ts(e):%H:%M}: {model}")
    if e.get("type") not in ("user", "assistant"):
        continue
    if e["type"] == "user" and asked_at and (ts(e) - ts(asked_at)).total_seconds() > 1800:
        print(f"  IDLE {ts(asked_at):%m-%d %H:%M} -> {ts(e):%m-%d %H:%M}")
    c = e["message"]["content"]
    for b in [{"type": "text", "text": c}] if isinstance(c, str) else c:
        text = b.get("text", "")
        if b.get("type") == "tool_use":
            uses[b["id"]] = b
        elif b.get("type") == "tool_result":
            body = json.dumps(b.get("content"), ensure_ascii=False)
            if REJECT in body:
                asked = uses.get(b["tool_use_id"], {})
                print(f"  REJECTED {asked.get('name')}: {json.dumps(asked.get('input'), ensure_ascii=False)[:300]}")
            if "PreToolUse" in body and "BLOCKED" in body and verify in body:
                print(f"  GATE BLOCK {ts(e):%H:%M}: {body[-300:]}")
        elif e["type"] == "user" and text and not e.get("isMeta"):
            if "<command-name>" in text or "<local-command-stdout>" in text:
                print(f"  COMMAND {ts(e):%H:%M}: {text[:160]!r}")
            elif text.startswith("Session\n\nTotal cost:"):
                print(f"  PASTED /cost: {text[:200]!r}")
            elif not text.startswith("<local-command-caveat>"):
                print(f"  OWNER {ts(e):%m-%d %H:%M}: {text[:200]!r}")
