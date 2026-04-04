# iOS Development Agent — Implementation Plan

## Vision

A senior iOS engineer AI agent powered by Claude Opus 4.6 (Agent SDK) that develops
production-quality iOS apps using SOLID/DRY principles, Apple's HIG, and the existing
KSLibrary ecosystem. The agent has persistent memory, a live code snippet repo, and
specialized subagents — so it never reinvents the wheel and always ships Apple-style code.

---

## Repository Layout

```
ios-agent/
├── agent.py                  ← Entry point & main agent loop
├── subagents.py              ← Subagent definitions (architect, ui, data, network, reviewer, test)
├── hooks.py                  ← Pre/post tool-use hooks (SwiftLint gate, snippet recorder)
├── memory_tool.py            ← BetaAbstractMemoryTool implementation (file-system backed)
├── requirements.txt
├── CLAUDE.md                 ← Master iOS instructions loaded into every session
├── memory/                   ← Persistent cross-session memory (Claude reads/writes)
│   ├── project-context.md    ← Current project goals, decisions, open items
│   ├── learned-prefs.md      ← User style preferences discovered over time
│   └── session-log.md        ← Append-only log of completed tasks
└── snippets/                 ← Canonical Swift/SwiftUI snippet library
    ├── README.md             ← Index of all snippets (Claude reads this first)
    ├── architecture/
    │   ├── mvvm-swiftui.md
    │   ├── clean-arch-layers.md
    │   ├── coordinator-nav.md
    │   └── dependency-injection.md
    ├── networking/
    │   ├── ks-network-usage.md   ← KSLibrary NetworkLibrary patterns
    │   └── async-await-patterns.md
    ├── persistence/
    │   ├── swiftdata-patterns.md
    │   ├── ks-storage-keychain.md ← KSLibrary StorageLibrary patterns
    │   └── coredata-patterns.md
    ├── ui/
    │   ├── ks-ui-components.md   ← KSLibrary UIComponentsLibrary usage
    │   ├── swiftui-navigation.md
    │   ├── design-system.md
    │   └── accessibility.md
    ├── testing/
    │   ├── xctest-viewmodel.md
    │   └── xcuitest-flows.md
    └── solid-dry/
        ├── protocol-oriented.md
        └── generic-reuse.md
```

---

## Files to Create

### 1. `ios-agent/requirements.txt`

```
claude-agent-sdk>=0.1.0
anthropic>=0.40.0
```

---

### 2. `ios-agent/CLAUDE.md`  (loaded via `setting_sources=["project"]`)

Master instruction file. Sections:
- **Role**: Senior iOS engineer (16y exp), Apple-platform specialist
- **KSLibrary awareness**: Always check `snippets/` before writing new code; prefer KSLibrary modules (Logger, Network, Storage, UIComponents, InApp, Analytics, YouTube)
- **Architecture mandate**: Feature-slice MVVM + Clean Architecture layers (Domain / Data / Presentation)
- **SOLID rules** (one-liner per principle, enforced by reviewer subagent)
- **DRY rules**: Extract to KSLibrary if used 2+ times; record in snippets/
- **Swift style**: Swift API Design Guidelines, SwiftUI-first, async/await, Sendable, @MainActor
- **File naming**: `FeatureName+Role.swift` convention
- **No magic numbers / strings**: use enums, constants files
- **Memory protocol**: On task completion → update `memory/project-context.md`; on new pattern → append to relevant `snippets/` file
- **Apple HIG**: minimum 44pt tap targets, Dynamic Type, Dark Mode, accessibility labels

---

### 3. `ios-agent/memory_tool.py`

Implements `BetaAbstractMemoryTool` from the Anthropic SDK. Backed by `ios-agent/memory/`.
Commands: `view`, `create`, `str_replace`, `insert`, `delete`, `rename`.

---

### 4. `ios-agent/hooks.py`

| Hook | Event | Action |
|---|---|---|
| `swiftlint_gate` | `PostToolUse` on Write/Edit | Run `swiftlint lint --path <file>` via Bash; if violations → append to tool result so Claude auto-fixes |
| `snippet_recorder` | `PostToolUse` on Write | If Claude added a reusable pattern, prompt it to save to `snippets/` |
| `solid_audit` | `PostToolUse` on Write/Edit | Run `reviewer` subagent on the changed file |
| `progress_logger` | `Stop` | Append task summary to `memory/session-log.md` |

---

### 5. `ios-agent/subagents.py`

Six specialized subagents:

| Name | Responsibility | Allowed Tools |
|---|---|---|
| `architect` | Module structure, dependency graph, layer boundaries | Read, Glob, Grep, Write, AskUserQuestion |
| `ui-engineer` | SwiftUI views, design system, HIG compliance | Read, Write, Edit, Glob, WebFetch |
| `data-layer` | SwiftData/CoreData, KSLibrary Storage, migrations | Read, Write, Edit, Glob, Bash |
| `networking` | URLSession, KSLibrary Network, Codable models | Read, Write, Edit, Glob, WebFetch |
| `reviewer` | SOLID/DRY audit, naming, Apple conventions | Read, Glob, Grep |
| `test-engineer` | XCTest ViewModels, XCUITest flows, mocks | Read, Write, Edit, Bash |

---

### 6. `ios-agent/agent.py`

Main agent orchestrator:

```python
import anyio
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage, SystemMessage
from subagents import SUBAGENT_DEFINITIONS
from hooks import HOOK_CONFIG
from memory_tool import IOSMemoryTool

async def run(prompt: str, project_cwd: str):
    memory = IOSMemoryTool(base_dir="memory")

    options = ClaudeAgentOptions(
        model="claude-opus-4-6",
        cwd=project_cwd,
        system_prompt=None,            # loaded from CLAUDE.md via setting_sources
        setting_sources=["project"],   # loads ios-agent/CLAUDE.md
        allowed_tools=[
            "Read", "Write", "Edit", "Bash",
            "Glob", "Grep", "WebFetch", "WebSearch",
            "AskUserQuestion", "Agent",
        ],
        mcp_servers={
            # Xcode build + test runner
            "xcode": {
                "command": "npx",
                "args": ["-y", "xcode-mcp-server"]
            },
            # iOS Simulator control (xcrun simctl wrapper)
            "simulator": {
                "command": "npx",
                "args": ["-y", "ios-simulator-mcp"]
            },
            # swift-format / SwiftLint formatting
            "swift-format": {
                "command": "npx",
                "args": ["-y", "swift-format-mcp"]
            },
        },
        tools=[memory],                # in-process memory tool
        agents=SUBAGENT_DEFINITIONS,
        hooks=HOOK_CONFIG,
        thinking={"type": "adaptive"},
        max_turns=50,
        permission_mode="acceptEdits",
    )

    async for message in query(prompt=prompt, options=options):
        if isinstance(message, ResultMessage):
            print(message.result)
        elif isinstance(message, SystemMessage) and message.subtype == "init":
            print(f"Session: {message.data.get('session_id')}")

if __name__ == "__main__":
    import sys
    prompt = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else "What should I build today?"
    cwd = sys.argv[1] if len(sys.argv) > 1 else "."
    anyio.run(run, prompt, cwd)
```

---

## MCP Servers

| MCP Server | Purpose | Notes |
|---|---|---|
| `xcode-mcp-server` | `xcodebuild build/test/archive`, scheme/target listing | Wraps `xcodebuild` CLI |
| `ios-simulator-mcp` | `xcrun simctl` — boot, install, launch, screenshot | Automates simulator |
| `swift-format-mcp` | `swift-format` and `swiftlint` on demand | Code style enforcement |
| `@modelcontextprotocol/server-filesystem` | Scoped file access outside cwd | For reading system frameworks |

> If a ready-made npm MCP doesn't exist for Xcode, we implement a custom one as a simple
> stdio server in `ios-agent/mcp-servers/xcode/index.js` exposing 4 tools:
> `xcode_build`, `xcode_test`, `xcode_list_schemes`, `simulator_run`.

---

## Snippet Library Seed Content

Each `snippets/*.md` file will be populated during implementation:

- **`snippets/README.md`** — Index table: snippet name | file | use-case
- **`snippets/networking/ks-network-usage.md`** — Full usage guide for `KSLibrary/NetworkLibrary` with examples copied from `Sources/NetworkLibrary`
- **`snippets/ui/ks-ui-components.md`** — All UIComponentsLibrary components with SwiftUI usage
- **`snippets/architecture/mvvm-swiftui.md`** — Observable + @State MVVM template
- **`snippets/solid-dry/protocol-oriented.md`** — Protocol + generic extension DRY pattern

The agent reads `snippets/README.md` at the start of any coding task to discover available patterns before writing new code — preventing duplication.

---

## Memory Strategy

```
Session N:   Claude reads  memory/project-context.md   → knows project state
             Claude reads  memory/learned-prefs.md      → knows user style
             [… does work …]
             Hooks trigger: memory/project-context.md updated
             New pattern found: snippets/ui/custom-card.md created

Session N+1: Same files loaded → full continuity, zero repeated questions
```

---

## SOLID/DRY Enforcement Flow

```
1. Agent writes/edits a Swift file
2. PostToolUse hook → runs `reviewer` subagent on that file
3. reviewer subagent checks:
   - S: each type has one reason to change
   - O: extensions over modification (protocol + default impl)
   - L: substitutability via protocols
   - I: no fat protocol (split if >5 unrelated methods)
   - D: dependencies injected, never instantiated inside
   - DRY: grep snippets/ for similar code; extract if duplicate
4. reviewer returns violations list
5. Main agent auto-fixes before proceeding
```

---

## Project-Generated App Structure (target output)

When the agent creates a new iOS app it follows this structure:

```
MyApp/
├── MyApp.swift              @main, WindowGroup
├── App/
│   ├── AppCoordinator.swift
│   └── DI/Container.swift   Dependency injection root
├── Features/
│   └── <FeatureName>/
│       ├── Domain/
│       │   ├── Models/      Pure Swift structs, no UIKit/SwiftUI
│       │   └── UseCases/    Protocol + implementation
│       ├── Data/
│       │   ├── Repositories/
│       │   └── DTOs/
│       └── Presentation/
│           ├── ViewModel/   @Observable class
│           └── Views/       SwiftUI views
├── Core/
│   ├── Extensions/
│   ├── Constants/
│   └── Protocols/
└── DesignSystem/
    ├── Tokens/              Color, Typography, Spacing enums
    ├── Components/          Reusable SwiftUI views
    └── Modifiers/           ViewModifier extensions
```

---

## Implementation Steps (ordered)

1. Create `ios-agent/requirements.txt`
2. Create `ios-agent/CLAUDE.md` with full iOS instructions
3. Create `ios-agent/memory_tool.py` — file-system memory backend
4. Create `ios-agent/hooks.py` — SwiftLint gate + snippet recorder + SOLID audit
5. Create `ios-agent/subagents.py` — 6 subagent definitions
6. Create `ios-agent/agent.py` — main entry point
7. Seed `ios-agent/memory/project-context.md` — KSLibrary project overview
8. Seed `ios-agent/memory/learned-prefs.md` — default Apple style preferences
9. Seed `ios-agent/snippets/README.md` — snippet index
10. Seed `ios-agent/snippets/networking/ks-network-usage.md` (auto-read from Sources/)
11. Seed `ios-agent/snippets/ui/ks-ui-components.md`
12. Seed `ios-agent/snippets/architecture/mvvm-swiftui.md`
13. Seed `ios-agent/snippets/solid-dry/protocol-oriented.md`
14. Seed remaining snippet files
15. Create `ios-agent/mcp-servers/xcode/index.js` if no npm package available
16. Commit everything to branch `claude/ios-agent-sdk-eoDlm`
