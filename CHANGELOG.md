# Changelog

## 2.3.0

### Changed
- **Built on Remotion's official skills.** `remotion-dev/skills` is now the base for all Remotion markup, preview, rendering and captions. This plugin owns the media: generating, sourcing, analyzing and reviewing it. `remotion-production` says which side handles what, so the two skill sets no longer give conflicting instructions (e.g. the official voiceover guide asking for an ElevenLabs key that KIE already covers).
- **Preview first.** `/create-video` and `/create-short` open Remotion Studio as soon as the project runs and build live. They render when you ask; `/review-video` renders on invocation and checks a few frames before the full TwelveLabs review.
- **Captions use the official flow.** Word-level transcription and `<BasicCaptions>` per clip, with our TikTok-style presets and short-form placement on top. `generate_subtitles` stays for SRT export.
- `/setup` installs all 12 official Remotion skills and scaffolds with the official `create-video` flags.

### Changed (providers)
- **Audio comes from ElevenLabs' official skills.** Voiceover (`eleven_v4`), sound effects and music (Eleven Music `music_v2_5`, cleared for commercial use on paid plans) go through `elevenlabs/skills`. `ELEVENLABS_API_KEY` is now required. KIE audio (`generate_speech`, `generate_music`, `generate_sound_effect`) is labelled drafts-only, because KIE resells Suno and the other models without their owners' licence.
- **ElevenLabs MCP is deprecated upstream** (archived 2026-08-22). It's pinned at 0.12.2 for one more release, with `ELEVENLABS_MCP_BASE_PATH=./public` so it can read and write project files. Before, it rejected every input outside `public/audio`.
- **Pexels: switched to `@hanoak/pexels-mcp-server` 1.0.2.** The previous server crashed on startup with `mcp` 2.x and is unmaintained. The new one runs on npm (no Python/uv) and has the `pexels_*` tools. Thanks @fabiantresarroyos for diagnosing the crash in #10.
- **TwelveLabs: works again.** Pegasus 1.2 was removed from the API, which broke the index-first flow. Analysis now uses `create-asset` → `sync-analyse-video`/`async-analyse-video` (`pegasus1.5`) → `delete-asset`, and `/review-video` gets a structured JSON rubric. Pinned at `twelvelabs-mcp` 1.0.0.
- **Replicate: the official local `replicate-mcp` 0.9.0 with `REPLICATE_API_TOKEN`**, layered on `replicate/skills`. The hosted server was OAuth-only and timed out headless. Our old tool names didn't exist, and two model IDs were invalid. There's a dated model shortlist and a "search and check the schema first" rule.
- **remotion-media pinned at 1.2.2** and used for images and clips only. Its subtitles tool is no longer used: it built a shell command from unquoted input. Captions fall back to ElevenLabs Scribe via `@remotion/elevenlabs` when there's no GPU for local Whisper.
- Every MCP server is pinned to a tested version.
- The README and setup guide list official add-ons (fal, Runway, Gemini skills) without bundling them.

### Fixed
- Outdated Remotion APIs across the rules and skills: `<OffthreadVideo>`, `<Audio>` from `remotion`, `startFrom`/`endAt`, `<Loop>`, `@remotion/light-leaks`, `npm run dev` / `localhost:3000` → `@remotion/media`, `trimBefore`/`trimAfter`, `loop`, `@remotion/effects`, `npx remotion studio`.
- Word-by-word caption highlight couldn't work from line-level SRT; caption spans used CSS transitions, which don't render.
- Glitch effect used `Math.random()` (flickers across render threads); non-integer `durationInFrames`.
- ElevenLabs MCP tool names (`voice_clone`, `search_voices`, `isolate_audio`) and its `~/Desktop` default output.
- `generate_speech` doesn't return a duration; durations are now measured in `calculateMetadata`.
- One asset naming convention for MCP outputs and downloads.

### Removed
- `rules/3d-content.md` (superseded by the official `remotion-markup` 3D guide).

### Added
- CI guard against outdated Remotion APIs in the docs.

## 2.2.0

### Added
- **Codex support.** `codex plugin marketplace add DojoCodingLabs/remotion-superpowers`, then `codex plugin add remotion-superpowers@remotion-superpowers` (`.codex-plugin/plugin.json`).
- **Gemini CLI support.** `gemini extensions install https://github.com/DojoCodingLabs/remotion-superpowers` (`gemini-extension.json`). Gemini prompts for the API keys on install.
- **Any Agent Skills agent** (Cursor, Copilot, …): `npx skills add DojoCodingLabs/remotion-superpowers`.
- CI check that all manifests share one version and Gemini mirrors `.mcp.json`.

### Changed
- The 13 commands are now Agent Skills (`skills/<name>/SKILL.md`). In Claude Code they're still the same slash commands.
- `.mcp.json` forwards API keys with `env_vars` instead of `"${VAR}"` strings. Codex passed those strings through literally, so every server got `${KIE_API_KEY}` as its key; Claude Code still inherits them from your shell.
- Skill text no longer assumes Claude Code (launch directory, restart and skill-location notes).

## 2.1.1

### Fixed
- **Plugin loads again.** `hooks/hooks.json` now uses the nested `hooks` array, timeouts in seconds, and `${CLAUDE_PLUGIN_ROOT}` script paths (#1, thanks @TroyMiner and everyone who reported it in #2, #5, #7, #8).
- **Hooks actually fire.** Matchers now target the real MCP tool names (`mcp__plugin_remotion-superpowers_remotion-media__generate_speech`, etc.); the old bare names could never match.
- **Missing-key guard is visible.** `check-mcp-server.sh` writes its block reason to stderr, which Claude Code shows on exit 2. It now only gates the KIE-backed generators (`generate_subtitles` runs local Whisper and no longer needs `KIE_API_KEY`).
- **Tips reach Claude.** `post-tool-note.sh` emits `hookSpecificOutput.additionalContext`. The captions tip now fires after `remotion render` Bash commands instead of on a non-existent `render` tool.
- **TwelveLabs connects.** `.mcp.json` runs the `twelvelabs-mcp-stdio` entrypoint instead of the HTTP server (#4, thanks @king-sheol).
- **Docs match the real tools.** Commands, skills and rules now use the `remotion-media-mcp` 1.2.x tool names and parameters (`generate_speech`, `generate_sound_effect`, `generate_video_from_text`/`_from_image`, required `output_name`, no `project_path`) and the `pexels-mcp-server` names (`photos_search`, `videos_search`, `video_get`).

### Removed
- The Replicate `PreToolUse` key check. `mcp-remote` doesn't forward `REPLICATE_API_TOKEN` to the hosted server, so the check didn't reflect whether Replicate works and could block working setups.

## 2.1.0
- Marketplace metadata update.

## 2.0.0
- Captions, shorts, AI generation, transitions, review loop and more.

## 1.0.0
- Initial release.
