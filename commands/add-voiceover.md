---
name: add-voiceover
description: Generate a voiceover narration and add it to your Remotion project. Provide a script or describe what the narration should say, and this will generate TTS audio and wire it into your composition.
---

# Add Voiceover — Generate & Integrate Narration

You are helping the user add a voiceover narration to their Remotion project.

**Load the `remotion-production` skill** for the `voiceover-sync` and `audio-integration` rules.

## Workflow

### 1. Get the Script

If the user hasn't provided a script:
- Ask what the video is about
- Ask about tone (professional, casual, energetic, calm)
- Write the narration script
- Present for approval

### 2. Choose Voice

Available voices (via remotion-media TTS):
- **Eric** — Warm, professional male (default)
- **Rachel** — Clear, engaging female
- **Aria** — Energetic female
- **Roger** — Deep, authoritative male
- **Sarah** — Friendly, conversational female
- **Laura** — Calm, soothing female
- **Charlie** — Casual, youthful male

For voice cloning or custom voices, use the dedicated ElevenLabs MCP (requires `ELEVENLABS_API_KEY`).

### 3. Generate TTS

```
Use remotion-media generate_tts:
- text: [the approved script]
- voice: [chosen voice]
- project_path: [project root path]
```

Record the returned **file path** and **duration**.

### 4. Wire into Composition

Add the voiceover `<Audio>` component:

```tsx
import { Audio, staticFile } from "remotion";

// In your composition:
<Audio src={staticFile("[returned-file-path]")} volume={1} />
```

### 5. Adjust Composition Duration

If the voiceover is longer than the current composition:

```tsx
// Update durationInFrames in the Composition registration
durationInFrames: Math.ceil([voiceover_duration_seconds] * fps) + 60 // +2s padding
```

### 6. Generate Captions (optional)

Offer to generate subtitles:

```
Use remotion-media generate_subtitles:
- input: [voiceover file path]
- project_path: [project root path]
```

### 7. Duck Background Music (if present)

If the project already has background music, lower its volume during voiceover. See `audio-integration` rule for the ducking pattern.
