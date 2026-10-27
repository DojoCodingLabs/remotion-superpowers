---
name: setup-guide
description: Knowledge for helping users set up the Remotion Superpowers plugin. Covers API key acquisition, dependency installation, Remotion's official Agent Skills (a required companion), and MCP server troubleshooting. Use when running /setup or when a user has issues with MCP connections.
---

# Setup Guide for Remotion Superpowers

This skill contains knowledge for helping users set up the plugin and troubleshoot issues. The step-by-step wizard is the `setup` skill; keep advice here consistent with it.

## Required companion: Remotion's official Agent Skills

Remotion Superpowers layers on top of Remotion's 12 official skills (`remotion-best-practices`, `remotion-captions`, `remotion-create`, `remotion-docs`, `remotion-interactivity`, `remotion-maps`, `remotion-markup`, `remotion-multimedia`, `remotion-render`, `remotion-saas`, `remotion-studio`, `remotion-upgrade`). This plugin owns media generation; the official skills own markup, scaffolding, preview, captions and rendering.

- **Install:** `npx skills add remotion-dev/skills` (detects the installed agents and installs to each; select all 12 if asked)
- **Update:** `npx remotion upgrade` from the project (also updates project-local skills), or `npx skills update <the 12 names> --yes` when `@remotion/cli` isn't installed
- **New project:** scaffold as official `remotion-create` says: inspect the folder first, then `npx create-video@latest --yes --blank --no-tailwind` (`.` for an empty folder, or a subfolder name), then `npm i`. Don't recommend Tailwind unless the user asks.
- **Launch directory:** start the agent from the Remotion project root; remotion-media tools write to `public/` of the directory the agent was launched from.

## Rule Files

- `rules/api-keys-setup.md` — Detailed instructions for obtaining each API key, signup URLs, free tiers, and pricing info
