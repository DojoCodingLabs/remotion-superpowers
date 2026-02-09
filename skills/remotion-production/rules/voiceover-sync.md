# Voiceover Sync — TTS Generation & Animation Timing

## Generating Voiceover

Use `remotion-media`'s `generate_tts` tool:

```
generate_tts:
  text: "Your narration script here"
  voice: "Eric"  # or Rachel, Aria, Roger, Sarah, Laura, Charlie, George, etc.
  project_path: "/path/to/remotion/project"
```

The tool returns:
- File path (saved to `public/` directory)
- Duration in seconds

## Voice Selection Guide

- **Eric** — Warm, professional male voice (good default)
- **Rachel** — Clear, engaging female voice (good default)
- **Aria** — Energetic female voice (good for promos)
- **Roger** — Deep, authoritative male voice (good for narration)
- **Sarah** — Friendly, conversational female voice
- **Laura** — Calm, soothing female voice
- **Charlie** — Casual, youthful male voice

For custom/cloned voices, use the dedicated ElevenLabs MCP instead.

## Syncing Voiceover with Visual Scenes

### Pattern 1: Single voiceover, scenes timed to it

Break the script into segments and estimate word timing (~150 words per minute):

```tsx
// Script: "Welcome to our app. It makes your life easier. Try it today."
// ~150 WPM = 2.5 words/second
// Segment 1: "Welcome to our app." (~1.5s = 45 frames at 30fps)
// Segment 2: "It makes your life easier." (~2s = 60 frames)
// Segment 3: "Try it today." (~1s = 30 frames)

const SCENES = [
  { text: "Welcome to our app.", startFrame: 0, durationFrames: 45 },
  { text: "It makes your life easier.", startFrame: 45, durationFrames: 60 },
  { text: "Try it today.", startFrame: 105, durationFrames: 30 },
];
```

### Pattern 2: Voiceover with synchronized captions

Generate subtitles from the voiceover audio:

```
Use remotion-media's generate_subtitles tool:
  input: "public/audio/voiceover.mp3"
  project_path: "/path/to/project"
```

This creates an SRT file. Use Remotion's caption system to display them:

```tsx
import { loadFont } from "@remotion/google-fonts/Inter";
import { Audio, staticFile, useCurrentFrame, useVideoConfig } from "remotion";

// Parse the SRT file into timed caption segments
// Then display captions synchronized with the audio
```

### Pattern 3: Dynamic duration from voiceover

Use `calculateMetadata` to set composition length based on audio:

```tsx
import { CalculateMetadataFunction } from "remotion";
import { getAudioDurationInSeconds } from "@remotion/media-utils";

export const calculateMetadata: CalculateMetadataFunction<MyVideoProps> = async () => {
  const voiceoverDuration = await getAudioDurationInSeconds(
    staticFile("audio/voiceover.mp3")
  );
  
  return {
    durationInFrames: Math.ceil(voiceoverDuration * 30) + 60, // +2s padding
    fps: 30,
    width: 1920,
    height: 1080,
  };
};
```

## Best Practices

1. **Generate voiceover FIRST** — it determines the video's pacing
2. **Add 1-2 seconds of padding** — at start and end for breathing room
3. **Break scripts into short sentences** — easier for TTS and for scene matching
4. **Preview audio alone first** — listen before building visuals around it
5. **Use captions** — always generate subtitles for accessibility
6. **Volume levels** — voiceover at 1.0, music at 0.15-0.3, SFX at 0.5-0.8
