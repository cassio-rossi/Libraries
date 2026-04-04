"""
iOS Agent Memory Tool
=====================
File-system backed implementation of BetaAbstractMemoryTool from the Anthropic SDK.
All memory is stored under ios-agent/memory/ and persisted across sessions.

The memory directory layout:
  memory/
  ├── project-context.md   — Current project state, goals, architectural decisions
  ├── learned-prefs.md     — User style preferences and conventions discovered over time
  └── session-log.md       — Append-only log of completed tasks (one line per session)
"""

from __future__ import annotations

import os
from pathlib import Path
from typing import Any

from anthropic.lib.tools import BetaAbstractMemoryTool


class IOSMemoryTool(BetaAbstractMemoryTool):
    """
    File-system backed memory tool for the iOS Development Agent.

    Backs each "file" in Claude's memory model onto a real file under base_dir.
    Claude can view, create, edit, insert into, delete from, and rename memory files.
    All operations are UTF-8 text; binary content is not supported.
    """

    def __init__(self, base_dir: str | Path = "memory") -> None:
        super().__init__()
        self.base_dir = Path(base_dir).resolve()
        self.base_dir.mkdir(parents=True, exist_ok=True)

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def _resolve(self, path: str) -> Path:
        """Resolve a relative memory path to an absolute path, enforcing base_dir."""
        resolved = (self.base_dir / path).resolve()
        # Prevent path traversal outside base_dir
        resolved.relative_to(self.base_dir)
        return resolved

    def _read(self, path: str) -> str:
        p = self._resolve(path)
        if not p.exists():
            raise FileNotFoundError(f"Memory file not found: {path}")
        return p.read_text(encoding="utf-8")

    def _write(self, path: str, content: str) -> None:
        p = self._resolve(path)
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(content, encoding="utf-8")

    # ------------------------------------------------------------------
    # BetaAbstractMemoryTool interface
    # ------------------------------------------------------------------

    def view(self, command: dict[str, Any]) -> str:
        """
        List all memory files or display the content of a specific file.

        command keys:
          path (optional): relative path to a specific file; omit to list all files.
        """
        path: str | None = command.get("path")

        if path is None:
            # List all memory files with their sizes
            lines = ["# Memory Files\n"]
            for f in sorted(self.base_dir.rglob("*.md")):
                rel = f.relative_to(self.base_dir)
                size = f.stat().st_size
                lines.append(f"- {rel}  ({size} bytes)")
            return "\n".join(lines) if len(lines) > 1 else "No memory files found."

        return self._read(path)

    def create(self, command: dict[str, Any]) -> str:
        """
        Create a new memory file.

        command keys:
          path: relative path for the new file.
          content: initial content (markdown).
        """
        path: str = command["path"]
        content: str = command.get("content", "")

        p = self._resolve(path)
        if p.exists():
            raise FileExistsError(
                f"Memory file already exists: {path}. Use str_replace or insert to modify it."
            )
        self._write(path, content)
        return f"Created memory file: {path}"

    def str_replace(self, command: dict[str, Any]) -> str:
        """
        Replace a specific string in a memory file (exact match, first occurrence).

        command keys:
          path: relative path to the file.
          old_str: exact text to find.
          new_str: replacement text.
        """
        path: str = command["path"]
        old_str: str = command["old_str"]
        new_str: str = command["new_str"]

        content = self._read(path)
        if old_str not in content:
            raise ValueError(
                f"old_str not found in {path}.\n"
                f"Searched for:\n{old_str}\n"
                "Tip: use view() to inspect current content."
            )
        updated = content.replace(old_str, new_str, 1)
        self._write(path, updated)
        return f"Replaced text in {path}"

    def insert(self, command: dict[str, Any]) -> str:
        """
        Insert content after a specific line number (1-based).

        command keys:
          path: relative path to the file.
          insert_line: 1-based line number after which to insert (0 = prepend).
          new_str: content to insert.
        """
        path: str = command["path"]
        insert_line: int = int(command["insert_line"])
        new_str: str = command["new_str"]

        content = self._read(path)
        lines = content.splitlines(keepends=True)

        if insert_line < 0 or insert_line > len(lines):
            raise IndexError(
                f"insert_line {insert_line} is out of range (file has {len(lines)} lines)."
            )

        lines.insert(insert_line, new_str if new_str.endswith("\n") else new_str + "\n")
        self._write(path, "".join(lines))
        return f"Inserted content at line {insert_line} in {path}"

    def delete(self, command: dict[str, Any]) -> str:
        """
        Delete lines from start_line to end_line (inclusive, 1-based), or delete the entire file.

        command keys:
          path: relative path to the file.
          start_line (optional): first line to delete.
          end_line (optional): last line to delete.
          If neither start_line nor end_line is provided, the file itself is deleted.
        """
        path: str = command["path"]
        start_line: int | None = command.get("start_line")
        end_line: int | None = command.get("end_line")

        p = self._resolve(path)

        if start_line is None and end_line is None:
            if not p.exists():
                raise FileNotFoundError(f"Memory file not found: {path}")
            p.unlink()
            return f"Deleted memory file: {path}"

        content = self._read(path)
        lines = content.splitlines(keepends=True)

        start = int(start_line) - 1  # convert to 0-based
        end = int(end_line) if end_line is not None else start + 1

        if start < 0 or end > len(lines) or start >= end:
            raise IndexError(
                f"Line range {start_line}–{end_line} is invalid (file has {len(lines)} lines)."
            )

        del lines[start:end]
        self._write(path, "".join(lines))
        return f"Deleted lines {start_line}–{end_line} from {path}"

    def rename(self, command: dict[str, Any]) -> str:
        """
        Rename (move) a memory file.

        command keys:
          path: current relative path.
          new_path: new relative path.
        """
        path: str = command["path"]
        new_path: str = command["new_path"]

        src = self._resolve(path)
        dst = self._resolve(new_path)

        if not src.exists():
            raise FileNotFoundError(f"Memory file not found: {path}")
        if dst.exists():
            raise FileExistsError(f"Destination already exists: {new_path}")

        dst.parent.mkdir(parents=True, exist_ok=True)
        src.rename(dst)
        return f"Renamed {path} → {new_path}"
