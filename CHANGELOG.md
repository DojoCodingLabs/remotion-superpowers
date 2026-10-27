# Changelog

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
