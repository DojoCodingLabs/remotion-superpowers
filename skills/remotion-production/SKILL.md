---
name: remotion-production
description: Media orchestration for Remotion videos. Generates and sources the assets a video needs (voiceover, music, sound effects, stock footage, AI images and clips, video analysis and review) through MCP tools, and hands them to Remotion's official skills for the markup. Use whenever a Remotion video needs audio, voiceovers, music, stock footage, AI-generated media, or analysis of existing footage.
---

# Remotion Production Workflow

This skill covers what Remotion's own skills don't: **getting the media**. It orchestrates 5 MCP servers to produce voiceovers, music, SFX, footage, images and clips, then wires them into a Remotion composition.

## Works on top of the official skills

This plugin builds on each provider's own Agent Skills and keeps only what's specific to making Remotion videos:

| Provider | Official skills | Install |
|---|---|---|
| Remotion | `remotion-best-practices` + sub-skills | `npx skills add remotion-dev/skills` |
| ElevenLabs | `text-to-speech`, `sound-effects`, `music`, `speech-to-text`, `voice-isolator`, `voice-changer` | `npx skills add elevenlabs/skills` |
| Replicate | `find-models`, `run-models`, `compare-models`, `prompt-images`, `prompt-videos` | `npx skills add replicate/skills` |

TwelveLabs has no Agent Skills; its agent docs are at https://docs.twelvelabs.io (and `llms.txt`).

Remotion maintains the official Agent Skills (`remotion-best-practices` and its sub-skills: `remotion-create`, `remotion-markup`, `remotion-studio`, `remotion-render`, `remotion-captions`, `remotion-multimedia`, …). They're the source of truth for Remotion APIs and change with every Remotion release. If they're missing, install them first: `npx skills add remotion-dev/skills` (or run the `setup` skill).

**When both are loaded, split the work like this:**

| Concern | Follow |
|---|---|
| Voiceover, sound effects, music | **Official ElevenLabs skills**: a small SDK script in the project that writes to `public/` with this skill's names. Defaults: `eleven_v4` (speech), `music_v2_5` (music). |
| Images and AI clips | **This skill**: KIE via `remotion-media`; Replicate (with the official Replicate skills) for specific models or when KIE fails |
| Stock footage, footage analysis, AI review | **This skill**: Pexels and TwelveLabs MCP tools |
| Remotion markup: components, imports, timing props, animation, effects, transitions, fonts | **Official** `remotion-markup` |
| Project scaffolding | **Official** `remotion-create` |
| Preview | **Official** `remotion-best-practices` / `remotion-studio`: start Studio as soon as the project runs, before building scenes, and keep it open |
| Rendering | **Official** `remotion-render`: only when the user asks for an MP4, or when running `review-video` |
| Captions: word-level transcription and display | **Official** `remotion-captions` (this skill only adds TikTok-style presets and short-form placement) |
| Measuring media durations | **Official** `remotion-multimedia` (Mediabunny), inside `calculateMetadata` |
| Anything not covered here | Check the live docs via the official `remotion-docs` skill rather than guessing |

If a code snippet here ever disagrees with the official skills, the official skills win.

## Providers and MCP tools

### ElevenLabs (voice, SFX, music: the default)
- Generate with the official ElevenLabs skills (SDK script, `ELEVENLABS_API_KEY`). Eleven Music is cleared for commercial use on paid plans.
- **Deprecated alternative:** the `ElevenLabs` MCP server (`elevenlabs-mcp` 0.12.2, archived upstream) still ships for one more release for quick interactive work: `text_to_speech`, `text_to_sound_effects`, `compose_music`, `voice_clone`, `search_voices`, `search_voice_library`, `isolate_audio`, `speech_to_text`. It only reads and writes inside `public/`; pass `output_directory` as the project's `public/`.

### remotion-media (via KIE: images and clips)
- `generate_image`: AI images (Nano Banana Pro)
- `generate_video_from_text`: AI clips from a prompt (Veo 3.1)
- `generate_video_from_image`: animate 1 image, or transition between 2. `image_urls` must be public URLs.
- `generate_speech`, `generate_music`, `generate_sound_effect`: **drafts only.** Suno and the other KIE-resold models aren't licensed by their owners through KIE. Use KIE audio for drafts and internal work, and generate final commercial audio with ElevenLabs.
- `list_assets`: browse the Airtable asset library (requires `AIRTABLE_API_KEY`)
- Don't use its subtitles tool; captions go through the official Remotion flow.
- KIE's Veo depends on a preview Google is retiring. If a clip call fails, fall back to Replicate.

These tools return the file path, not the duration. Measure durations as the official `remotion-multimedia` skill shows.

### TwelveLabs (video understanding and AI review)
- `create-asset` (upload a local file) → `sync-analyse-video` or `async-analyse-video` with `modelName: "pegasus1.5"` and a JSON response schema → `delete-asset` when done
- `search` only finds moments inside an indexed library ("the part where…"); it doesn't analyse.

### Pexels (stock footage)
- `pexels_search_videos`, `pexels_search_photos`, `pexels_popular_videos`, `pexels_curated_photos`, `pexels_get_video`, `pexels_get_photo`, collections
- No download tool: take the file URL from `pexels_get_video` (or the search result) and `curl` it into `public/footage/`.
- Pexels doesn't require attribution, but it's appreciated.

### Replicate (optional, specific models)
- Local `replicate-mcp` with `REPLICATE_API_TOKEN`: `search_models`, `get_models`, `list_models_examples`, `create_models_predictions` / `create_predictions`, `get_predictions`, `download_files`
- Follow the official Replicate skills: search for the model and read its input schema before calling. See `rules/replicate-models.md` for a dated shortlist.

## Asset conventions

- **remotion-media tools write to `public/<output_name>.<ext>`** in the directory the agent was launched from, so the agent must be started from the Remotion project root. They can't write into subfolders, so encode the type in the name: `vo-scene1`, `music-bg`, `sfx-whoosh`, `img-hero`, `clip-city-aerial`.
- **Files you download yourself** (Pexels, Replicate outputs) go into subfolders: `mkdir -p public/footage public/images`, then `curl -L -o public/footage/<name>.mp4 <url>`.
- Reference every file with `staticFile()` and its exact path relative to `public/`, e.g. `staticFile("vo-scene1.mp3")` or `staticFile("footage/city.mp4")`.

## Rules

Read the rule that matches the task:

- `rules/production-pipeline.md`: end-to-end order of MCP steps, from concept to preview
- `rules/audio-integration.md`: layering voiceover, music and SFX; ducking
- `rules/voiceover-sync.md`: per-scene voiceover with `generate_speech`, timed with `calculateMetadata`
- `rules/music-scoring.md`: music prompts, volume levels, per-scene music
- `rules/sound-effects.md`: SFX prompt library and timing to visual events
- `rules/elevenlabs-advanced.md`: voice cloning, voice library, audio isolation, multi-voice scripts
- `rules/stock-footage-workflow.md`: Pexels search, download, attribution
- `rules/video-analysis.md`: TwelveLabs indexing, search and clip selection
- `rules/image-generation.md`: image prompts and provider choice (KIE, Replicate, Pexels)
- `rules/video-generation.md`: clip prompts, provider choice, image-to-video pipeline
- `rules/replicate-models.md`: Replicate model catalog and when to use it over KIE
- `rules/captions-workflow.md`: TikTok-style caption presets on top of the official captions flow
- `rules/animation-presets.md`: text-animation recipes in the official markup style
- `rules/data-visualization.md`: animated charts, dashboards and counters
- `rules/visual-effects.md`: what to use from the official effects, plus letterbox and glitch
- `rules/ci-rendering.md`: GitHub Actions workflows for automated renders
- `rules/asset-management.md`: naming, `public/` layout, `staticFile()` mistakes

For 3D, transitions, light leaks, Lottie, fonts and the other Remotion APIs, use the official `remotion-markup` skill directly.

## Key principles

1. **Audio drives timing.** Generate the voiceover per scene first, measure each file in `calculateMetadata`, and size the scenes and composition from that. Durations in frames are integers: use `Math.ceil`.
2. **Preview first.** Start Studio as soon as the project runs, so the user watches assets land and can steer. Render only when asked, or for `review-video`.
3. **Generate with tools, write markup with the official skills.** MCP tools make the files; the official skills say how to place them (`<Audio>` and `<Video>` from `@remotion/media`, timing props, effects).
4. **Preserve user changes.** If the user edited the code between turns, keep their edits.
