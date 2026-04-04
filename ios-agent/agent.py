"""
iOS Development Agent — Entry Point
=====================================
Usage:
  python agent.py <project_cwd> "<prompt>"

Examples:
  python agent.py /path/to/MyApp "Build a profile screen with avatar, name, and bio"
  python agent.py . "Add unit tests for ProfileViewModel"
  python agent.py /path/to/MyApp "Review the networking layer for SOLID violations"

The agent:
  - Loads CLAUDE.md from this directory via setting_sources=["project"]
  - Reads ios-agent/snippets/README.md at session start for pattern awareness
  - Uses persistent memory via IOSMemoryTool (ios-agent/memory/)
  - Enforces code quality via PostToolUse hooks (SwiftLint, SOLID audit)
  - Delegates to 6 specialized subagents for focused tasks
  - Integrates Xcode, Simulator, and swift-format via MCP servers
"""

from __future__ import annotations

import sys
import os
import anyio
from pathlib import Path

from claude_agent_sdk import (
    ClaudeAgentOptions,
    ResultMessage,
    SystemMessage,
    AssistantMessage,
    TextBlock,
    query,
)

from memory_tool import IOSMemoryTool
from subagents import SUBAGENT_DEFINITIONS
from hooks import HOOK_CONFIG

# ---------------------------------------------------------------------------
# Paths relative to this file
# ---------------------------------------------------------------------------
AGENT_DIR = Path(__file__).parent.resolve()
MEMORY_DIR = AGENT_DIR / "memory"
SNIPPETS_INDEX = AGENT_DIR / "snippets" / "README.md"


# ---------------------------------------------------------------------------
# MCP server configuration
# ---------------------------------------------------------------------------
def _mcp_servers() -> dict:
    """
    Returns MCP server configs. Falls back gracefully if a server is absent.

    Servers:
      xcode      — xcodebuild build/test/archive + scheme listing
      simulator  — xcrun simctl: boot, install, launch, screenshot
      swift-fmt  — swift-format + swiftlint on demand
    """
    servers: dict = {}

    # Custom Xcode MCP (our own implementation in mcp-servers/xcode/)
    xcode_server = AGENT_DIR / "mcp-servers" / "xcode" / "index.js"
    if xcode_server.exists():
        servers["xcode"] = {
            "command": "node",
            "args": [str(xcode_server)],
        }

    # iOS Simulator MCP
    servers["simulator"] = {
        "command": "npx",
        "args": ["-y", "ios-simulator-mcp"],
    }

    # swift-format MCP (wraps swift-format + swiftlint)
    servers["swift-format"] = {
        "command": "npx",
        "args": ["-y", "swift-format-mcp"],
    }

    return servers


# ---------------------------------------------------------------------------
# System prompt prefix (injected before CLAUDE.md content)
# ---------------------------------------------------------------------------
def _build_system_prefix(project_cwd: str) -> str:
    """
    Injects dynamic context that shouldn't live in the static CLAUDE.md:
    - Current working project path
    - Snippet index content (so Claude knows available patterns up front)
    - Memory status (tells Claude what memory files exist)
    """
    lines = [
        f"## Current Project Directory\n`{project_cwd}`\n",
    ]

    # Inject snippet index so Claude knows all available patterns before writing code
    if SNIPPETS_INDEX.exists():
        index_content = SNIPPETS_INDEX.read_text(encoding="utf-8")
        lines.append("## Available Code Snippets\n")
        lines.append("Read `ios-agent/snippets/README.md` for the full index. Summary:\n")
        lines.append(f"```\n{index_content[:2000]}\n```\n")

    # Tell Claude which memory files exist
    memory_files = sorted(MEMORY_DIR.rglob("*.md")) if MEMORY_DIR.exists() else []
    if memory_files:
        lines.append("## Memory Files (read these at session start)\n")
        for f in memory_files:
            rel = f.relative_to(AGENT_DIR)
            lines.append(f"- `{rel}`")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main agent loop
# ---------------------------------------------------------------------------
async def run(prompt: str, project_cwd: str) -> None:
    memory = IOSMemoryTool(base_dir=MEMORY_DIR)

    options = ClaudeAgentOptions(
        model="claude-opus-4-6",
        cwd=project_cwd,

        # Load CLAUDE.md from ios-agent/ — this is the master iOS instruction file.
        # setting_sources=["project"] loads the nearest CLAUDE.md relative to cwd.
        # We set cwd to the project, so we pass our CLAUDE.md via system_prompt instead.
        system_prompt=_build_system_prefix(project_cwd),
        setting_sources=[],  # CLAUDE.md injected via system_prompt above

        allowed_tools=[
            "Read",
            "Write",
            "Edit",
            "Bash",
            "Glob",
            "Grep",
            "WebFetch",
            "WebSearch",
            "AskUserQuestion",
            "Agent",
        ],

        mcp_servers=_mcp_servers(),

        # In-process memory tool — Claude reads/writes ios-agent/memory/*.md
        tools=[memory],

        # Six specialized subagents
        agents=SUBAGENT_DEFINITIONS,

        # Quality gates: SwiftLint, SOLID audit, snippet recorder, session logger
        hooks=HOOK_CONFIG,

        # Adaptive thinking — Claude decides when and how deeply to reason
        thinking={"type": "adaptive"},

        # Safety defaults
        max_turns=60,
        permission_mode="acceptEdits",
    )

    session_id: str | None = None

    print(f"\n🍎 iOS Agent starting — project: {project_cwd}")
    print(f"   Prompt: {prompt}\n")

    async for message in query(prompt=prompt, options=options):
        if isinstance(message, SystemMessage) and message.subtype == "init":
            session_id = message.data.get("session_id")
            print(f"   Session: {session_id}\n")

        elif isinstance(message, AssistantMessage):
            for block in message.content:
                if isinstance(block, TextBlock):
                    print(block.text, end="", flush=True)

        elif isinstance(message, ResultMessage):
            print(f"\n\n✅ Done  (stop_reason: {message.stop_reason})")
            if session_id:
                print(f"   Resume with: --resume {session_id}")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
def main() -> None:
    if len(sys.argv) < 3:
        print("Usage: python agent.py <project_cwd> \"<prompt>\"")
        print("       python agent.py . \"Build a login screen with email + password\"")
        sys.exit(1)

    project_cwd = sys.argv[1]
    prompt = " ".join(sys.argv[2:])

    if not Path(project_cwd).exists():
        print(f"Error: project directory not found: {project_cwd}")
        sys.exit(1)

    anyio.run(run, prompt, project_cwd)


if __name__ == "__main__":
    main()
