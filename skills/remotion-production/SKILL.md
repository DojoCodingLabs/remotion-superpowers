---
name: remotion-production
description: Media orchestration for Remotion videos. Generates and sources the assets a video needs (voiceover, music, sound effects, stock footage, AI images and clips, video analysis and review) through MCP tools, and hands them to Remotion's official skills for the markup. Use whenever a Remotion video needs audio, voiceovers, music, stock footage, AI-generated media, or analysis of existing footage.
---

# Remotion Production Workflow

This skill covers what Remotion's own skills don't: **getting the media**. It orchestrates 5 MCP servers to produce voiceovers, music, SFX, footage, images and clips, then wires them into a Remotion composition.

## Works on top of Remotion's official skills

Remotion maintains the official Agent Skills (`remotion-best-practices` and its sub-skills: `remotion-create`, `remotion-markup`, `remotion-studio`, `remotion-render`, `remotion-captions`, `remotion-multimedia`, …). They're the source of truth for Remotion APIs and change with every Remotion release. If they're missing, install them first: `npx skills add remotion-dev/skills` (or run the `setup` skill).

**When both are loaded, split the work like this:**

| Concern | Follow |
|---|---|
| Generating or sourcing media (speech, music, SFX, images, clips, stock footage, footage analysis, AI review) | **This skill**: use the MCP tools below. Don't write scripts that call provider APIs (ElevenLabs, Suno, etc.) directly, and don't ask the user for a provider key the MCP tools already cover. |
| Remotion markup: components, imports, timing props, animation, effects, transitions, fonts | **Official** `remotion-markup` |
| Project scaffolding | **Official** `remotion-create` |
| Preview | **Official** `remotion-best-practices` / `remotion-studio`: start Studio as soon as the project runs, before building scenes, and keep it open |
| Rendering | **Official** `remotion-render`: only when the user asks for an MP4, or when running `review-video` |
| Captions: word-level transcription and display | **Official** `remotion-captions` (this skill only adds TikTok-style presets and short-form placement) |
| Measuring media durations | **Official** `remotion-multimedia` (Mediabunny), inside `calculateMetadata` |
| Anything not covered here | Check the live docs via the official `remotion-docs` skill rather than guessing |

If a code snippet here ever disagrees with the official skills, the official skills win.

## Available MCP tools

### remotion-media (via KIE)
- `generate_speech`: text-to-speech voiceovers (ElevenLabs TTS)
- `generate_music`: background music (Suno)
- `generate_sound_effect`: custom sound effects (ElevenLabs SFX)
- `generate_image`: AI images (Nano Banana Pro)
- `generate_video_from_text`: AI clips from a prompt (Veo 3.1)
- `generate_video_from_image`: animate 1 image, or transition between 2 (Veo 3.1)
- `generate_subtitles`: line-level SRT via local Whisper (for SRT export; word-level captions come from the official `remotion-captions` flow)
- `list_assets`: browse the Airtable asset library (requires `AIRTABLE_API_KEY`)

These tools return the file path, not the duration. Measure durations as the official `remotion-multimedia` skill shows.

### TwelveLabs (video understanding)
- Index and analyze video files
- Semantic search inside videos ("find the part where…")
- Scene, object and speaker detection; summaries

### Pexels (stock footage)
- `photos_search`, `videos_search`: search free stock media
- `video_get` / `photo_get`: details by ID
- No download tool: take the file URL from `video_get` (or the search result's `video_files`) and `curl` it into `public/footage/`

### ElevenLabs (optional, advanced voice)
- `voice_clone`, `search_voices`, `search_voice_library`, `isolate_audio`, `text_to_speech`, `speech_to_text`, and more
- These tools save to `~/Desktop` unless you pass an output directory. Always point them at the project's `public/`.

### Replicate (optional, 100+ models)
- `replicate_run`: synchronous (images)
- `replicate_create_prediction` / `replicate_get_prediction`: async (video), poll until done
- Image models: FLUX 1.1 Pro, Imagen 4, Ideogram v3, FLUX Kontext. Video models: Wan 2.5, Kling 2.6 Pro.

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
