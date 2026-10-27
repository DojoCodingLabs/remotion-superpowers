# Production Pipeline — Order of MCP Steps

## Overview

The order in which to generate and source media, layered on top of the official Remotion flow. Remotion-specific steps (scaffolding, Studio, markup, rendering) follow the official skills; this file only says **when** each one happens relative to the MCP calls.

## Step 1: Scaffold or Detect the Project

If a Remotion project already exists (a `remotion` dependency in `package.json`), use it. Otherwise scaffold one exactly as the official `remotion-create` skill says.

Start the agent from the Remotion project root: remotion-media tools write to `public/` of the directory the agent was launched from.

If the code uses `<Audio>` or `<Video>`, install `@remotion/media` now: `npx remotion add @remotion/media`.

## Step 2: Start Studio (preview first)

As soon as the project can run, start Studio, before building any scenes, and keep it open for the rest of the session:

```bash
npx remotion studio            # opens the browser itself
npx remotion studio --no-open  # with an in-app browser: open the URL it prints
```

Open the exact URL Studio prints (it picks a free port), then `/<composition-id>` once a composition exists. Options and edge cases: official `remotion-best-practices` ("Open the preview") and `remotion-studio`.

## Step 3: Concept Breakdown and Approval Gate

When the user describes a video, break it down into:

- **Duration** — How long is the video? (default: 30 seconds if not specified)
- **Scenes** — List of visual scenes, each with its own narration line
- **Script** — Narration text per scene (if voiceover is needed)
- **Audio needs** — Music genre/mood, sound effects, voiceover style
- **Visual style** — Color scheme, typography, animation style
- **Assets needed** — Stock footage queries, images to generate, existing footage to analyze

Present this breakdown to the user and **wait for approval** before calling any paid generation tool.

## Step 4: Per-Scene Voiceover (if needed)

Voiceover drives the timing of everything else. Generate one file per scene:

```
Use remotion-media's generate_speech tool, once per scene:
- text: that scene's narration
- output_name: "vo-scene1", "vo-scene2", ...
- voice: choose appropriate voice (default: "Eric" for male, "Rachel" for female)
```

The tool returns the file path only, not a duration. Durations are measured later in `calculateMetadata` (Step 7). Details: `voiceover-sync.md`.

## Step 5: Music, then SFX

### Music
```
Use remotion-media's generate_music tool:
- prompt: describe the mood/genre (e.g., "upbeat corporate background music, no vocals")
- output_name: "music-bg"
- instrumental: true
```

Music can be longer than the video (it is cut at the composition end) or shorter (use `loop`). Details: `music-scoring.md`.

### Sound Effects (if needed)
Use the free hosted SFX from the official `remotion-markup` skill (sfx.md) for generic sounds (whoosh, click, ding, shutter…). Generate only custom ones:

```
Use remotion-media's generate_sound_effect tool:
- prompt: describe the sound (e.g., "deep cinematic boom with long reverb tail")
- output_name: "sfx-boom"
- duration_seconds: how long the effect should be (0.5-22)
```

Details: `sound-effects.md`.

## Step 6: Footage and Images

### Stock Footage (Pexels)
For each scene that needs stock footage:
```
Use Pexels videos_search tool:
- query: descriptive keywords (e.g., "drone footage city skyline sunset")
- orientation: "landscape" for standard video
- size: "large"
```

Download the chosen file into `public/footage/`:
```bash
mkdir -p public/footage
curl -L -o public/footage/city-skyline.mp4 "VIDEO_URL"
```

Pexels doesn't require attribution, but it's appreciated. Details: `stock-footage-workflow.md`.

### Existing Footage Analysis (TwelveLabs)
If the user has video files in the project:
```
Use TwelveLabs to:
1. Create an index for the video
2. Search for specific moments
3. Get timestamps for relevant scenes
```

Details: `video-analysis.md`.

### Generated Images and Clips
```
Use remotion-media's generate_image tool:
- prompt: describe the image
- output_name: "img-scene1"
```

For AI clips use `generate_video_from_text` / `generate_video_from_image` with `output_name: "clip-<name>"`. Details: `image-generation.md`, `video-generation.md`.

## Step 7: Build the Scenes

Write the markup following the official `remotion-markup` skill (compositions, multi-scene video, audio, timing props). Studio is already open, so the user sees each scene land.

Size the composition from the voiceover: measure every `vo-sceneN.mp3` in `calculateMetadata` with Mediabunny (official `remotion-multimedia`, get-audio-duration.md), convert with `Math.ceil(seconds * fps)`, and pass the per-scene frame counts as props. Never hard-code a duration computed from seconds. The full pattern is in `voiceover-sync.md`.

Audio layers and ducking: `audio-integration.md`. Asset paths: `asset-management.md`.

## Step 8: Iterate in Studio

Ask the user to watch the preview in Studio and check:
- Audio sync with visuals
- Timing of scene transitions
- Text readability
- Overall feel

Adjust animation timing, volumes, transitions or text, or regenerate an asset with a new prompt. Keep any edits the user made to the code between turns.

## Step 9: Render Only When Asked

Don't render by default. Render only when the user explicitly asks for an MP4 ("render it", "export", "give me the MP4"), following the official `remotion-render` skill, or point them to the render button in Studio.

After a render, offer the `review-video` skill for an AI review of the result (invoking `review-video` counts as an explicit request to render).

## File Organization

```
project/
├── public/
│   ├── vo-scene1.mp3          # remotion-media writes to the public/ root
│   ├── vo-scene2.mp3
│   ├── music-bg.mp3
│   ├── sfx-boom.mp3
│   ├── img-scene1.png
│   ├── clip-city.mp4
│   ├── footage/               # files you download yourself (Pexels, Replicate)
│   │   └── city-skyline.mp4
│   └── images/
│       └── logo.png
├── src/
│   ├── Root.tsx
│   ├── MyVideo.tsx
│   └── scenes/
└── out/                       # only after an explicit render
```

See `asset-management.md` for naming and `staticFile()` paths.
