---
name: studio-launcher
description: Install a Linux desktop launcher for Remotion Studio, so it starts from the application grid (Super + type "remotion") instead of a terminal command. Also supports stopping the server and viewing its log from the icon's right-click menu.
---

# Remotion Superpowers — Studio Launcher

The user wants to start Remotion Studio without typing a terminal command.
Install a desktop entry that launches it from the application grid.

## Step 1: Confirm the platform

This command is Linux-only — it installs a freedesktop `.desktop` entry.

- **macOS:** tell the user this does not apply; suggest an Automator "Run Shell Script"
  app or a Shortcuts action wrapping `npx remotion studio` instead.
- **Windows:** suggest a Start Menu shortcut to a `.bat` file running the same command.

## Step 2: Locate the Remotion project

Check the current directory for `remotion.config.ts` / `remotion.config.js`.

**If not found:** ask the user for the project path, or offer to scaffold one with
`npx create-video@latest` (Blank template, TailwindCSS, install Skills).

## Step 3: Run the installer

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-studio-launcher.sh" --project .
```

Useful flags:

| Flag | Purpose |
|------|---------|
| `--project DIR` | Project to launch (default: current directory) |
| `--port N` | Studio port (default: 3000) |
| `--name NAME` | Label shown in the app grid |
| `--uninstall` | Remove the launcher for that project |

The installer detects the package manager from the lockfile (pnpm / yarn / bun / npm),
picks an available terminal emulator for the log viewer, and validates the entry with
`desktop-file-validate`.

Run it once per project — each gets its own entry, named after its directory.

## Step 4: Report the result

Tell the user to press **Super** and type `remotion`. Mention that right-clicking the
icon offers **Stop Server** and **View Log**.

Point out where things live:

- Launcher: `~/.local/bin/remotion-studio-<project>`
- Desktop entry: `~/.local/share/applications/remotion-studio-<project>.desktop`
- Log: `~/.local/state/remotion-studio-<project>.log`

## Notes

- The server is started with `setsid` in its own session, so closing a terminal or
  browser window does not kill it. Use **Stop Server** to shut it down.
- Launching while the server is already up just reopens the browser tab.
- If `~/.remotion-env` exists, the launcher sources it first, so API keys used by the
  MCP servers are present in the studio's environment.
- If a start fails, the failure notification shows the last log lines, and the full
  output stays in the log file.
