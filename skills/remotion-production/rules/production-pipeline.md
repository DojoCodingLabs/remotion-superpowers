# Production Pipeline — Order of MCP Steps

## Overview

The order in which to generate and source media, layered on top of the official Remotion flow. Remotion-specific steps (scaffolding, Studio, markup, rendering) follow the official skills; this file only says **when** each one happens relative to the MCP calls.

## Step 1: Scaffold or Detect the Project

If a Remotion project already exists (a `remotion` dependency in `package.json`), use it. Otherwise scaffold one exactly as the official `remotion-create` skill says.

Start the agent from the Remotion project root: remotion-media tools write to `public/` of the directory the agent was launched from, and `scripts/generate-audio.ts` writes to the project's `public/`.

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

## Step 4: Audio with the Official ElevenLabs Skills

Voiceover, music and SFX come from the official ElevenLabs skills (`text-to-speech`, `music`, `sound-effects`; install with `npx skills add elevenlabs/skills`). Load them for the exact SDK calls. They need `ELEVENLABS_API_KEY`; if it isn't set, follow the official `setup-api-key` skill.

Put every audio call in **one script**, `scripts/generate-audio.ts`, using `@elevenlabs/elevenlabs-js` (`npm i @elevenlabs/elevenlabs-js`), the same pattern as official `remotion-markup/voiceover.md`. Run it with:

```bash
node scripts/generate-audio.ts
```

What the script writes (our names, at the `public/` root):

| Asset | Official skill | Model | File |
|---|---|---|---|
| Voiceover, one file per scene | `text-to-speech` | `eleven_v4` | `public/vo-scene1.mp3`, `public/vo-scene2.mp3`, … |
| Background music | `music` | `music_v2_5` | `public/music-bg.mp3` |
| Custom sound effects | `sound-effects` | (default) | `public/sfx-whoosh.mp3`, `public/sfx-boom.mp3`, … |

Keep the per-scene narration, voice ID, music prompt and SFX prompts at the top of the script, so regenerating one asset is a one-line edit and a re-run (skip files that already exist unless asked). Eleven Music is cleared for commercial use on paid plans.

### Voiceover first
Voiceover drives the timing of everything else: one file per scene, generated before anything is sized. Nothing returns a duration; durations are measured later in `calculateMetadata` (Step 7). Details: `voiceover-sync.md`.

### Music, then SFX
Music can be longer than the video (it is cut at the composition end) or shorter (use `loop`); ask for an instrumental and set its length to the video's. Details: `music-scoring.md`.

For generic sounds (whoosh, click, ding, shutter…), use the free hosted SFX from the official `remotion-markup` skill (sfx.md). Generate only custom ones. Details: `sound-effects.md`.

### Other audio routes
- **Cheap drafts (KIE):** remotion-media's `generate_speech`, `generate_music` and `generate_sound_effect` write the same names (`output_name: "vo-scene1"`, `"music-bg"`, `"sfx-boom"`). Suno and the other KIE-resold models aren't licensed by their owners through KIE. Use KIE audio for drafts and internal work, and generate final commercial audio with ElevenLabs.
- **Interactive one-offs (deprecated):** the ElevenLabs MCP server (`text_to_speech`, `text_to_sound_effects`, `compose_music`) is archived upstream and ships for one more release. Point its `output_directory` at the project's `public/` and rename the output to our names.

## Step 5: Footage and Images

### Stock Footage (Pexels)
For each scene that needs stock footage:
```
Use Pexels pexels_search_videos:
- query: descriptive keywords (e.g., "drone footage city skyline sunset")
- orientation: "landscape" for standard video
- size: "medium" (Full HD; "large" means 4K)
- per_page: 5
```

Get the full rendition list with `pexels_get_video` (`id`) and download the file link closest to the composition size into `public/footage/`:
```bash
mkdir -p public/footage
curl -L -o public/footage/city-skyline.mp4 "VIDEO_FILE_LINK"
```

Pexels doesn't require attribution, but it's appreciated. Details: `stock-footage-workflow.md`.

### Existing Footage Analysis (TwelveLabs)
If the user has video files in the project:
```
1. create-asset (file: absolute path) → asset ID
2. async-analyse-video (assetId, modelName: "pegasus1.5", analysisMode: "time_based_metadata", segmentDefinitions) → poll get-analyse-task
   or sync-analyse-video (assetId, modelName: "pegasus1.5", prompt, jsonSchema) for a direct question, up to 1 h of video
3. delete-asset once the timestamps are saved
```

Use `search` only to find a moment across an already-indexed library. Details: `video-analysis.md`.

### Generated Images and Clips (KIE, Replicate as fallback)
```
Use remotion-media's generate_image tool:
- prompt: describe the image
- output_name: "img-scene1"
- aspect_ratio: matching the video
```

For AI clips use `generate_video_from_text` / `generate_video_from_image` with `output_name: "clip-<name>"`. `image_urls` for `generate_video_from_image` must be public URLs (for example the hosted URL `generate_image` returns), not `public/` paths.

KIE's Veo depends on a preview Google is retiring. If a KIE image or clip call fails, or the user wants a specific model, fall back to Replicate: `search_models`, read the input schema with `get_models` / `list_models_examples`, then `create_models_predictions`, and download the output into `public/images/` or `public/footage/`. Details: `image-generation.md`, `video-generation.md`, `replicate-models.md`.

## Step 6: Captions (if wanted)

Captions follow the official `remotion-captions` skill: word-level transcription with `@remotion/whisper-webgpu` when a GPU is available. Without one, fall back to ElevenLabs Scribe (official `speech-to-text` skill, `scribe_v2` with word timestamps) and convert the result to Remotion `Caption[]` with `elevenLabsTranscriptToCaptions()` from `@remotion/elevenlabs` (https://www.remotion.dev/docs/elevenlabs). A user-supplied `.srt` file is imported with `parseSrt`. Our styling presets: `captions-workflow.md`.

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
│   ├── vo-scene1.mp3          # scripts/generate-audio.ts and remotion-media write to the public/ root
│   ├── vo-scene2.mp3
│   ├── music-bg.mp3
│   ├── sfx-boom.mp3
│   ├── img-scene1.png
│   ├── clip-city.mp4
│   ├── footage/               # files you download yourself (Pexels, Replicate)
│   │   └── city-skyline.mp4
│   └── images/
│       └── logo.png
├── scripts/
│   └── generate-audio.ts      # ElevenLabs SDK: vo-*, music-bg, sfx-*
├── src/
│   ├── Root.tsx
│   ├── MyVideo.tsx
│   └── scenes/
└── out/                       # only after an explicit render
```

See `asset-management.md` for naming and `staticFile()` paths.
