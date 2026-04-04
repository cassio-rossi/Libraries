#!/usr/bin/env node
/**
 * Xcode MCP Server
 * ================
 * Exposes xcodebuild and xcrun simctl as MCP tools for the iOS Development Agent.
 *
 * Tools provided:
 *   xcode_list_schemes   — list all schemes in a .xcworkspace or .xcodeproj
 *   xcode_build          — build a scheme (Debug or Release)
 *   xcode_test           — run unit and/or UI tests for a scheme
 *   xcode_clean          — clean build artifacts
 *   simulator_list       — list available iOS simulators
 *   simulator_boot       — boot a simulator by UDID or name
 *   simulator_install    — install a .app bundle on a simulator
 *   simulator_launch     — launch an app on a simulator
 *   simulator_screenshot — take a screenshot of the simulator screen
 *   simulator_shutdown   — shut down a simulator
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Run a shell command, return { stdout, stderr, exitCode }.
 * Never throws — callers check exitCode.
 */
async function run(command, args, options = {}) {
  try {
    const { stdout, stderr } = await execFileAsync(command, args, {
      timeout: 300_000, // 5 minutes max for builds/tests
      maxBuffer: 10 * 1024 * 1024, // 10 MB
      ...options,
    });
    return { stdout: stdout.trim(), stderr: stderr.trim(), exitCode: 0 };
  } catch (err) {
    return {
      stdout: (err.stdout ?? "").trim(),
      stderr: (err.stderr ?? err.message ?? "").trim(),
      exitCode: err.code ?? 1,
    };
  }
}

function formatResult({ stdout, stderr, exitCode }) {
  const parts = [];
  if (exitCode !== 0) parts.push(`Exit code: ${exitCode}`);
  if (stdout) parts.push(stdout);
  if (stderr) parts.push(`[stderr]\n${stderr}`);
  return parts.join("\n\n") || "(no output)";
}

/** Find the first .xcworkspace, then .xcodeproj in dir (or use provided path). */
function resolveProject(dir, projectPath) {
  if (projectPath) return projectPath;
  return dir; // caller should pass explicit path; fallback to cwd
}

// ---------------------------------------------------------------------------
// Tool definitions
// ---------------------------------------------------------------------------

const TOOLS = [
  {
    name: "xcode_list_schemes",
    description:
      "List all schemes in an Xcode workspace or project. " +
      "Returns scheme names suitable for use with xcode_build and xcode_test.",
    inputSchema: {
      type: "object",
      properties: {
        project_path: {
          type: "string",
          description:
            "Absolute path to .xcworkspace or .xcodeproj. " +
            "If omitted, searches the current directory.",
        },
      },
      required: [],
    },
  },
  {
    name: "xcode_build",
    description:
      "Build an Xcode scheme using xcodebuild. " +
      "Returns build output including any errors and warnings.",
    inputSchema: {
      type: "object",
      properties: {
        project_path: {
          type: "string",
          description: "Absolute path to .xcworkspace or .xcodeproj.",
        },
        scheme: {
          type: "string",
          description: "The Xcode scheme to build.",
        },
        configuration: {
          type: "string",
          enum: ["Debug", "Release"],
          description: "Build configuration. Defaults to Debug.",
        },
        destination: {
          type: "string",
          description:
            "Build destination, e.g. 'platform=iOS Simulator,name=iPhone 16'. " +
            "Defaults to generic iOS Simulator.",
        },
      },
      required: ["scheme"],
    },
  },
  {
    name: "xcode_test",
    description:
      "Run tests for an Xcode scheme using xcodebuild test. " +
      "Returns test results including pass/fail counts.",
    inputSchema: {
      type: "object",
      properties: {
        project_path: {
          type: "string",
          description: "Absolute path to .xcworkspace or .xcodeproj.",
        },
        scheme: {
          type: "string",
          description: "The Xcode scheme to test.",
        },
        destination: {
          type: "string",
          description:
            "Test destination, e.g. 'platform=iOS Simulator,name=iPhone 16,OS=18.0'. " +
            "Defaults to latest available iPhone simulator.",
        },
        test_plan: {
          type: "string",
          description: "Optional test plan name to run.",
        },
      },
      required: ["scheme"],
    },
  },
  {
    name: "xcode_clean",
    description: "Clean build artifacts for an Xcode scheme.",
    inputSchema: {
      type: "object",
      properties: {
        project_path: { type: "string" },
        scheme: { type: "string", description: "The Xcode scheme to clean." },
      },
      required: ["scheme"],
    },
  },
  {
    name: "simulator_list",
    description:
      "List available iOS simulators with their UDIDs, names, OS versions, and states.",
    inputSchema: {
      type: "object",
      properties: {
        runtime: {
          type: "string",
          description: "Filter by runtime, e.g. 'iOS-18-0'. Omit to list all.",
        },
      },
      required: [],
    },
  },
  {
    name: "simulator_boot",
    description: "Boot an iOS simulator by UDID or device name.",
    inputSchema: {
      type: "object",
      properties: {
        udid: {
          type: "string",
          description: "Simulator UDID (preferred) or device name.",
        },
      },
      required: ["udid"],
    },
  },
  {
    name: "simulator_install",
    description: "Install a compiled .app bundle on a booted simulator.",
    inputSchema: {
      type: "object",
      properties: {
        udid: { type: "string", description: "Simulator UDID." },
        app_path: {
          type: "string",
          description: "Absolute path to the .app bundle.",
        },
      },
      required: ["udid", "app_path"],
    },
  },
  {
    name: "simulator_launch",
    description: "Launch an installed app on a booted simulator.",
    inputSchema: {
      type: "object",
      properties: {
        udid: { type: "string", description: "Simulator UDID." },
        bundle_id: {
          type: "string",
          description: "App bundle identifier, e.g. com.example.MyApp.",
        },
      },
      required: ["udid", "bundle_id"],
    },
  },
  {
    name: "simulator_screenshot",
    description: "Take a screenshot of a booted simulator and save it to a file.",
    inputSchema: {
      type: "object",
      properties: {
        udid: { type: "string", description: "Simulator UDID." },
        output_path: {
          type: "string",
          description:
            "Absolute path for the PNG output file. " +
            "Defaults to /tmp/simulator_screenshot.png.",
        },
      },
      required: ["udid"],
    },
  },
  {
    name: "simulator_shutdown",
    description: "Shut down a booted simulator.",
    inputSchema: {
      type: "object",
      properties: {
        udid: { type: "string", description: "Simulator UDID or 'all'." },
      },
      required: ["udid"],
    },
  },
];

// ---------------------------------------------------------------------------
// Tool handlers
// ---------------------------------------------------------------------------

async function handleTool(name, args) {
  switch (name) {
    // --- xcode_list_schemes ---
    case "xcode_list_schemes": {
      const { project_path } = args;
      const pArgs = ["-list"];
      if (project_path) {
        const flag = project_path.endsWith(".xcworkspace") ? "-workspace" : "-project";
        pArgs.unshift(flag, project_path);
      }
      const result = await run("xcodebuild", pArgs);
      return formatResult(result);
    }

    // --- xcode_build ---
    case "xcode_build": {
      const {
        project_path,
        scheme,
        configuration = "Debug",
        destination = "generic/platform=iOS Simulator",
      } = args;
      const bArgs = [
        "-scheme", scheme,
        "-configuration", configuration,
        "-destination", destination,
        "build",
      ];
      if (project_path) {
        const flag = project_path.endsWith(".xcworkspace") ? "-workspace" : "-project";
        bArgs.unshift(flag, project_path);
      }
      const result = await run("xcodebuild", bArgs);
      return formatResult(result);
    }

    // --- xcode_test ---
    case "xcode_test": {
      const {
        project_path,
        scheme,
        destination = "platform=iOS Simulator,name=iPhone 16",
        test_plan,
      } = args;
      const tArgs = [
        "-scheme", scheme,
        "-destination", destination,
        "test",
      ];
      if (project_path) {
        const flag = project_path.endsWith(".xcworkspace") ? "-workspace" : "-project";
        tArgs.unshift(flag, project_path);
      }
      if (test_plan) tArgs.push("-testPlan", test_plan);
      const result = await run("xcodebuild", tArgs);
      return formatResult(result);
    }

    // --- xcode_clean ---
    case "xcode_clean": {
      const { project_path, scheme } = args;
      const cArgs = ["-scheme", scheme, "clean"];
      if (project_path) {
        const flag = project_path.endsWith(".xcworkspace") ? "-workspace" : "-project";
        cArgs.unshift(flag, project_path);
      }
      const result = await run("xcodebuild", cArgs);
      return formatResult(result);
    }

    // --- simulator_list ---
    case "simulator_list": {
      const { runtime } = args;
      const lArgs = ["simctl", "list", "devices", "--json"];
      if (runtime) lArgs.push(runtime);
      const result = await run("xcrun", lArgs);
      if (result.exitCode !== 0) return formatResult(result);

      try {
        const parsed = JSON.parse(result.stdout);
        const lines = ["Available simulators:\n"];
        for (const [rt, devices] of Object.entries(parsed.devices)) {
          const available = devices.filter((d) => d.isAvailable !== false);
          if (available.length === 0) continue;
          lines.push(`## ${rt}`);
          for (const d of available) {
            lines.push(`  - ${d.name} (${d.udid}) [${d.state}]`);
          }
        }
        return lines.join("\n");
      } catch {
        return formatResult(result);
      }
    }

    // --- simulator_boot ---
    case "simulator_boot": {
      const result = await run("xcrun", ["simctl", "boot", args.udid]);
      return result.exitCode === 0
        ? `Simulator ${args.udid} booted successfully.`
        : formatResult(result);
    }

    // --- simulator_install ---
    case "simulator_install": {
      const result = await run("xcrun", ["simctl", "install", args.udid, args.app_path]);
      return result.exitCode === 0
        ? `App installed on simulator ${args.udid}.`
        : formatResult(result);
    }

    // --- simulator_launch ---
    case "simulator_launch": {
      const result = await run("xcrun", ["simctl", "launch", args.udid, args.bundle_id]);
      return result.exitCode === 0
        ? `App ${args.bundle_id} launched on ${args.udid}.`
        : formatResult(result);
    }

    // --- simulator_screenshot ---
    case "simulator_screenshot": {
      const output = args.output_path ?? "/tmp/simulator_screenshot.png";
      const result = await run("xcrun", ["simctl", "io", args.udid, "screenshot", output]);
      return result.exitCode === 0
        ? `Screenshot saved to ${output}`
        : formatResult(result);
    }

    // --- simulator_shutdown ---
    case "simulator_shutdown": {
      const result = await run("xcrun", ["simctl", "shutdown", args.udid]);
      return result.exitCode === 0
        ? `Simulator ${args.udid} shut down.`
        : formatResult(result);
    }

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
}

// ---------------------------------------------------------------------------
// MCP Server wiring
// ---------------------------------------------------------------------------

const server = new Server(
  { name: "xcode-mcp-server", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({ tools: TOOLS }));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  try {
    const result = await handleTool(name, args ?? {});
    return { content: [{ type: "text", text: result }] };
  } catch (err) {
    return {
      content: [{ type: "text", text: `Error: ${err.message}` }],
      isError: true,
    };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
