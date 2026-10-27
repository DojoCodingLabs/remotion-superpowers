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

## Provider skills this plugin builds on

- **ElevenLabs** (voice, SFX, music, transcription): `npx skills add elevenlabs/skills`. Generation runs through its SDK with `ELEVENLABS_API_KEY`. The ElevenLabs MCP server in this plugin is deprecated upstream and kept for one more release.
- **Replicate** (optional models): `npx skills add replicate/skills`, with the local `replicate-mcp` server and `REPLICATE_API_TOKEN`.
- **TwelveLabs** has no Agent Skills; point to https://docs.twelvelabs.io.

## Optional add-ons (not bundled)

Official servers from other providers that pair well with Remotion videos. Mention them only if the user asks for more models:
- **fal**: official MCP server with hundreds of image and video models (https://fal.ai/docs/documentation/setting-up/mcp)
- **Runway**: official MCP server for Runway video models (https://github.com/runwayml/runway-api-mcp-server)
- **Google Gemini**: official `google-gemini/gemini-skills` for Veo and Imagen via the Gemini API
- **Codex users:** OpenAI's official Remotion plugin covers Remotion markup; this plugin adds the media on top.

## Rule Files

- `rules/api-keys-setup.md` — Detailed instructions for obtaining each API key, signup URLs, free tiers, and pricing info
