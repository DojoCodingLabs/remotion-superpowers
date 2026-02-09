---
name: remotion-production
description: Full video production workflow for Remotion projects. Teaches how to orchestrate MCP tools (TTS, music, SFX, stock footage, video analysis) into complete Remotion compositions. Use this skill whenever producing a video that needs audio, voiceovers, music, stock footage, or analyzing existing video files.
---

# Remotion Production Workflow

This skill teaches how to produce complete videos with Remotion by orchestrating multiple MCP tools together. It covers the full pipeline from concept to rendered MP4.

## Available MCP Tools

You have access to these MCP servers for media production:

### remotion-media (via KIE)
- `generate_tts` — Text-to-speech voiceovers (ElevenLabs TTS)
- `generate_music` — Background music (Suno V3.5–V5)
- `generate_sfx` — Sound effects (ElevenLabs SFX V2)
- `generate_image` — AI images (Nano Banana Pro)
- `generate_video` — AI video clips (Veo 3.1)
- `generate_subtitles` — Transcribe audio/video to SRT (Whisper)
- `list_assets` — List all generated media in the project

### TwelveLabs (video understanding)
- Index and analyze video files
- Semantic search within videos ("find the part where...")
- Scene detection, object detection, speaker identification
- Video summarization

### Pexels (stock footage)
- `searchPhotos` — Search free stock photos
- `searchVideos` — Search free stock videos
- `getVideo` / `getPhoto` — Get details by ID
- `downloadVideo` — Download video to project

### ElevenLabs (optional — advanced voice)
- Voice cloning from audio samples
- Advanced TTS with custom voices
- Audio isolation and processing
- Transcription

### Replicate (optional — 100+ AI models)
- `replicate_run` — Run a model synchronously (images)
- `replicate_create_prediction` — Start async prediction (video)
- `replicate_get_prediction` — Poll prediction status
- Image models: FLUX 1.1 Pro, Imagen 4, Ideogram v3, FLUX Kontext
- Video models: Wan 2.5 (T2V, I2V), Kling 2.6 Pro

## Production Pipeline

Read individual rule files for detailed workflows:

- `rules/production-pipeline.md` — End-to-end workflow from concept to final render
- `rules/audio-integration.md` — How to integrate generated audio into Remotion compositions
- `rules/voiceover-sync.md` — Syncing TTS voiceovers with animations and captions
- `rules/music-scoring.md` — Generating and timing background music
- `rules/stock-footage-workflow.md` — Searching, downloading, and using stock footage in Remotion
- `rules/video-analysis.md` — Using TwelveLabs to analyze and select clips from existing footage
- `rules/captions-workflow.md` — TikTok-style animated captions using @remotion/captions and Whisper
- `rules/animation-presets.md` — Reusable animation patterns (fade, slide, scale, typewriter, stagger)
- `rules/3d-content.md` — Three.js and React Three Fiber via @remotion/three
- `rules/data-visualization.md` — Animated charts, dashboards, and number counters
- `rules/visual-effects.md` — Light leaks, Lottie, film grain, vignettes, Ken Burns
- `rules/ci-rendering.md` — GitHub Actions workflows for automated video rendering
- `rules/replicate-models.md` — Replicate MCP model catalog, usage, and decision guide
- `rules/image-generation.md` — AI image prompt engineering, provider selection, Remotion integration
- `rules/video-generation.md` — AI video clip generation, I2V pipeline, sequencing in Remotion
- `rules/sound-effects.md` — SFX generation, prompt engineering, timing to visual events
- `rules/elevenlabs-advanced.md` — Voice cloning, custom TTS parameters, multi-voice scripts
- `rules/asset-management.md` — File organization, naming conventions, staticFile() reference

## Key Principles

1. **Audio drives timing** — Generate voiceover first, get its duration, then set composition length to match.
2. **Assets go in `public/`** — All generated media files (audio, video, images) must be saved to the project's `public/` directory so Remotion can access them via `staticFile()`.
3. **Use Remotion's audio components** — Always use `<Audio>` component with `staticFile()` for audio. Never use HTML `<audio>` tags.
4. **Frame-based timing** — Remotion uses frames, not seconds. Convert with `fps * seconds`. At 30fps, 1 second = 30 frames.
5. **Progressive composition** — Build the video in layers: visuals first, then voiceover, then music, then SFX.
6. **Preview frequently** — Use `npm run dev` to preview after each major change. The Remotion player updates live.
