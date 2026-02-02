#!/usr/bin/env python3
"""A minimal "agentic loop" runner that iterates in-container.

Purpose:
- Let an LLM propose shell commands and file edits.
- Execute commands in the container workspace.
- Re-feed outputs until success criteria are met.

This is intentionally simple and conservative:
- It will ONLY execute commands you approve (interactive prompt).
- It logs actions to .agent/ for traceability.

Usage:
  python /opt/agent/agent_loop.py --goal "make tests pass" --success "ALL TESTS PASSED"
"""

from __future__ import annotations

import argparse
import json
import os
import pathlib
import subprocess
import sys
from typing import Any, Dict, List

import httpx

DEFAULT_MODEL = os.environ.get("OLLAMA_MODEL", "qwen2.5-coder:7b")
OLLAMA_BASE_URL = os.environ.get("OLLAMA_BASE_URL", "http://ollama:11434")


def call_ollama(messages: List[Dict[str, str]], model: str) -> str:
    url = f"{OLLAMA_BASE_URL.rstrip('/')}/api/chat"
    payload: Dict[str, Any] = {"model": model, "messages": messages, "stream": False}
    with httpx.Client(timeout=300) as client:
        r = client.post(url, json=payload)
        r.raise_for_status()
        data = r.json()
    return data["message"]["content"]


def run_cmd(cmd: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, shell=True, text=True, capture_output=True)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--goal", required=True, help="High-level goal for the agent.")
    ap.add_argument(
        "--success",
        required=True,
        help="Success signal substring to detect in the latest command output.",
    )
    ap.add_argument("--model", default=DEFAULT_MODEL)
    ap.add_argument("--max-steps", type=int, default=20)
    args = ap.parse_args()

    logdir = pathlib.Path(".agent")
    logdir.mkdir(exist_ok=True)

    system = {
        "role": "system",
        "content": (
            "You are a coding agent running INSIDE a sandbox container. "
            "Propose ONE step at a time as JSON with keys: "
            "action (one of: 'run', 'write', 'read', 'done'), "
            "command (for run), "
            "path (for read/write), "
            "content (for write), "
            "rationale (short). "
            "Never propose destructive commands like rm -rf / or modifying system packages."
        ),
    }

    messages: List[Dict[str, str]] = [system, {"role": "user", "content": args.goal}]
    last_output = ""

    for step in range(1, args.max_steps + 1):
        if args.success in last_output:
            print("Success criteria met.")
            return 0

        assistant = call_ollama(messages, args.model)
        (logdir / f"step_{step:02d}_assistant.txt").write_text(assistant)

        # Try to parse JSON in a robust way: find first '{' to last '}'.
        try:
            start = assistant.find("{")
            end = assistant.rfind("}")
            plan = json.loads(assistant[start : end + 1])
        except Exception as e:
            print(f"Could not parse JSON plan from model output: {e}")
            messages.append(
                {
                    "role": "user",
                    "content": "Your last response was not valid JSON. Reply again with ONLY the JSON object.",
                }
            )
            continue

        action = plan.get("action")
        rationale = plan.get("rationale", "")
        print(f"\nStep {step}/{args.max_steps}: action={action} :: {rationale}")

        if action == "done":
            print("Model indicated done.")
            return 0

        if action == "read":
            path = plan.get("path", "")
            if not path:
                messages.append({"role": "user", "content": "Missing 'path' for read."})
                continue
            try:
                content = pathlib.Path(path).read_text()
            except Exception as e:
                content = f"ERROR reading {path}: {e}"
            messages.append({"role": "user", "content": f"READ {path}\n{content}"})
            continue

        if action == "write":
            path = plan.get("path", "")
            content = plan.get("content", "")
            if not path:
                messages.append({"role": "user", "content": "Missing 'path' for write."})
                continue
            print(f"Proposed write to {path} ({len(content)} bytes). Approve? [y/N] ", end="")
            if input().strip().lower() != "y":
                messages.append({"role": "user", "content": "Write not approved. Propose another step."})
                continue
            pathlib.Path(path).parent.mkdir(parents=True, exist_ok=True)
            pathlib.Path(path).write_text(content)
            messages.append({"role": "user", "content": f"WROTE {path} ({len(content)} bytes)."})
            continue

        if action == "run":
            cmd = plan.get("command", "")
            if not cmd:
                messages.append({"role": "user", "content": "Missing 'command' for run."})
                continue
            print(f"Proposed command:\n  {cmd}\nApprove? [y/N] ", end="")
            if input().strip().lower() != "y":
                messages.append({"role": "user", "content": "Command not approved. Propose another step."})
                continue
            cp = run_cmd(cmd)
            last_output = (cp.stdout or "") + (cp.stderr or "")
            (logdir / f"step_{step:02d}_command.txt").write_text(cmd)
            (logdir / f"step_{step:02d}_output.txt").write_text(last_output)
            print(last_output)
            messages.append({"role": "user", "content": f"COMMAND: {cmd}\nOUTPUT:\n{last_output}"})
            continue

        messages.append({"role": "user", "content": f"Unknown action '{action}'. Use run/write/read/done."})

    print("Max steps reached without meeting success criteria.")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
