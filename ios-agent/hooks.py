"""
iOS Agent Hooks
===============
PostToolUse and Stop hooks that enforce code quality automatically:

  swiftlint_gate     — Runs SwiftLint after every Write/Edit. Violations are
                       appended to the tool result so Claude self-corrects.
  snippet_recorder   — After a Write, prompts Claude to save reusable patterns
                       to ios-agent/snippets/.
  solid_audit        — After Write/Edit, spawns the 'reviewer' subagent on the
                       changed Swift file to check SOLID/DRY compliance.
  progress_logger    — On session Stop, appends a summary line to
                       ios-agent/memory/session-log.md.
"""

from __future__ import annotations

import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _is_swift_file(tool_input: dict[str, Any]) -> bool:
    path = tool_input.get("file_path", tool_input.get("path", ""))
    return str(path).endswith(".swift")


def _extract_swift_path(tool_input: dict[str, Any]) -> str | None:
    path = tool_input.get("file_path", tool_input.get("path", ""))
    return str(path) if str(path).endswith(".swift") else None


# ---------------------------------------------------------------------------
# Hook: SwiftLint Gate
# ---------------------------------------------------------------------------

async def swiftlint_gate(input_data: dict[str, Any], tool_use_id: str, context: Any) -> dict:
    """
    Run SwiftLint on the file written/edited. If violations are found, return
    them so Claude sees them and can immediately fix the issues.
    """
    tool_input: dict = input_data.get("tool_input", {})
    swift_path = _extract_swift_path(tool_input)

    if swift_path is None:
        return {}

    if not Path(swift_path).exists():
        return {}

    try:
        result = subprocess.run(
            ["swiftlint", "lint", "--path", swift_path, "--reporter", "json"],
            capture_output=True,
            text=True,
            timeout=30,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        # SwiftLint not installed or timed out — skip silently
        return {}

    if result.returncode == 0:
        return {}

    # Parse output for a human-readable summary Claude can act on
    violations = result.stdout.strip() or result.stderr.strip()
    if not violations:
        return {}

    return {
        "content": (
            f"⚠️ SwiftLint found violations in {swift_path}.\n"
            "Please fix these before continuing:\n\n"
            f"```\n{violations}\n```"
        )
    }


# ---------------------------------------------------------------------------
# Hook: Snippet Recorder
# ---------------------------------------------------------------------------

async def snippet_recorder(input_data: dict[str, Any], tool_use_id: str, context: Any) -> dict:
    """
    After a Write, check if the new file contains a reusable pattern.
    Return a gentle reminder so Claude considers saving it to snippets/.
    """
    tool_input: dict = input_data.get("tool_input", {})
    swift_path = _extract_swift_path(tool_input)

    if swift_path is None:
        return {}

    content: str = tool_input.get("content", "")

    # Heuristic: if the file defines a protocol or generic type it's likely reusable
    reusable_indicators = [
        "protocol ",
        "extension ",
        "struct ",
        "enum ",
        "typealias ",
        "ViewModifier",
        "@Observable",
        "UseCase",
        "Repository",
    ]
    likely_reusable = any(indicator in content for indicator in reusable_indicators)

    if not likely_reusable:
        return {}

    return {
        "content": (
            "📎 Snippet reminder: this file contains a potentially reusable pattern.\n"
            "After finishing the task, consider appending it to the relevant "
            "`ios-agent/snippets/*.md` file and updating `ios-agent/snippets/README.md`."
        )
    }


# ---------------------------------------------------------------------------
# Hook: SOLID Audit (spawns reviewer subagent)
# ---------------------------------------------------------------------------

async def solid_audit(input_data: dict[str, Any], tool_use_id: str, context: Any) -> dict:
    """
    After writing/editing a Swift file, remind the agent to invoke the
    'reviewer' subagent for SOLID/DRY compliance.
    The main agent will route this through the Agent tool automatically.
    """
    tool_input: dict = input_data.get("tool_input", {})
    swift_path = _extract_swift_path(tool_input)

    if swift_path is None:
        return {}

    # Only trigger for Domain, Data, Presentation, Core — not for tests or resources
    skip_dirs = {"Tests", "Resources", "Preview Content", "Mocks", ".build"}
    if any(skip in swift_path for skip in skip_dirs):
        return {}

    return {
        "content": (
            f"🔍 SOLID audit: use the `reviewer` subagent to check "
            f"`{swift_path}` for SOLID/DRY violations before moving on."
        )
    }


# ---------------------------------------------------------------------------
# Hook: Progress Logger (Stop event)
# ---------------------------------------------------------------------------

async def progress_logger(input_data: dict[str, Any], tool_use_id: str, context: Any) -> dict:
    """
    On session stop, append a timestamped one-line summary to
    ios-agent/memory/session-log.md.
    """
    stop_reason: str = input_data.get("stop_reason", "unknown")
    result_text: str = input_data.get("result", "")

    # Truncate to a single line
    summary = result_text.splitlines()[0][:120] if result_text else "(no result)"

    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    log_line = f"- [{timestamp}] ({stop_reason}) {summary}\n"

    log_path = Path(__file__).parent / "memory" / "session-log.md"
    log_path.parent.mkdir(parents=True, exist_ok=True)

    try:
        with log_path.open("a", encoding="utf-8") as f:
            f.write(log_line)
    except OSError:
        pass  # Non-fatal — never crash the agent on logging

    return {}


# ---------------------------------------------------------------------------
# Hook configuration dict (consumed by agent.py)
# ---------------------------------------------------------------------------

from claude_agent_sdk import HookMatcher

HOOK_CONFIG: dict = {
    # Run SwiftLint and SOLID audit after any Write or Edit tool use
    "PostToolUse": [
        HookMatcher(matcher="Write", hooks=[swiftlint_gate, snippet_recorder, solid_audit]),
        HookMatcher(matcher="Edit", hooks=[swiftlint_gate, solid_audit]),
    ],
    # Log progress when the agent session ends
    "Stop": [progress_logger],
}
