---
name: add-music
description: Generate background music and add it to your Remotion project. Describe the mood/genre you want, and this will generate a track via Suno and wire it into your composition with proper fade in/out.
---

# Add Music — Generate & Integrate Background Music

You are helping the user add background music to their Remotion project.

**Load the `remotion-production` skill** for the `music-scoring` and `audio-integration` rules.

## Workflow

### 1. Understand the Mood

If not already described, ask the user:
- **Genre** — Electronic, jazz, classical, lo-fi, ambient, rock, orchestral, pop?
- **Mood** — Upbeat, calm, dramatic, inspiring, playful, cinematic?
- **Tempo** — Fast, medium, slow?
- **Vocals** — Instrumental only (recommended for background), or with vocals?

### 2. Generate Music

Craft a descriptive prompt and generate:

```
Use remotion-media generate_music:
- prompt: "[genre] background music, [mood], [tempo], no vocals, [additional descriptors]"
- output_name: music-bg
- instrumental: true
```
Files land in `public/` of the directory your agent was launched from, so start your agent (Claude Code, Codex, Gemini CLI…) from the Remotion project root.

**Good prompt examples:**
- "upbeat electronic background music, energetic, no vocals, modern tech startup vibe"
- "calm acoustic guitar, warm and friendly, no vocals, coffee shop atmosphere"
- "epic cinematic orchestral, building tension and release, no vocals, trailer style"
- "chill lo-fi hip hop beats, relaxed and dreamy, no vocals, study music vibe"

### 3. Wire into Composition

Place it with `<Audio>` from `@remotion/media` (install with `npx remotion add @remotion/media`), following the official `remotion-markup` skill (audio.md), with fade in/out:

```tsx
import { Audio } from "@remotion/media";
import { interpolate, staticFile, useCurrentFrame, useVideoConfig } from "remotion";

const frame = useCurrentFrame();
const { durationInFrames, fps } = useVideoConfig();

<Audio
  src={staticFile("music-bg.mp3")}
  volume={interpolate(
    frame,
    [0, fps, durationInFrames - 2 * fps, durationInFrames],
    [0, 0.25, 0.25, 0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
  )}
/>
```

### 4. Adjust for Voiceover (if present)

If the project has a voiceover, implement volume ducking — lower music to 0.1 during narration, 0.3 during silent parts. See `audio-integration` rule for the pattern.

### 5. Preview in Studio

If Studio isn't running, start it with `npx remotion studio` (or `--no-open` with an in-app browser, then open the URL it prints). Ask the user to listen there. Don't render unless they ask for an MP4.

Offer adjustments:
- Volume too loud/quiet?
- Wrong mood? Regenerate with a different prompt.
- Music too short? Add `loop` to the `<Audio>`, or generate a longer track.
- Need different music for different sections? Generate multiple tracks (`music-intro`, `music-main`, …) and give each its own `from` and `durationInFrames`.
