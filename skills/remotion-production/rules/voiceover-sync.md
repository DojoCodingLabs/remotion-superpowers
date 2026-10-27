# Voiceover Sync — Per-Scene TTS & Timing

This follows the structure of the official `remotion-markup` skill (voiceover.md): one audio file per scene, measured in `calculateMetadata`, with the scene durations passed as props. The only difference is how the audio is made: **use the `generate_speech` MCP tool, not a fetch script to the ElevenLabs API.** Don't write `generate-voiceover.ts` and don't ask the user for an `ELEVENLABS_API_KEY`; `generate_speech` runs through KIE and needs neither.

## Generating Voiceover

Split the approved script into scenes, then call `remotion-media`'s `generate_speech` once per scene:

```
generate_speech:
  text: "Welcome to our app."      # this scene's narration only
  output_name: "vo-scene1"         # vo-scene2, vo-scene3, ...
  voice: "Eric"
  model: "multilingual_v2"         # optional: best quality; default turbo_v2_5 is faster
  stability: 0.5                   # optional, 0-1
  similarity_boost: 0.75           # optional, 0-1
  speed: 1.0                       # optional, 0.7-1.2
```

The file lands at `public/vo-scene1.mp3` in the directory your agent was launched from, so start your agent (Claude Code, Codex, Gemini CLI…) from the Remotion project root. The tool returns **the file path only, not a duration**; measure it as shown below. Max 5000 characters per call.

## Voice Selection Guide

- **Eric** — Warm, professional male voice (good default)
- **Rachel** — Clear, engaging female voice (good default)
- **Aria** — Energetic female voice (good for promos)
- **Roger** — Deep, authoritative male voice (good for narration)
- **Sarah** — Friendly, conversational female voice
- **Laura** — Calm, soothing female voice
- **Charlie** — Casual, youthful male voice

Also available: George, Callum, River, Liam, Charlotte, Alice, Matilda, Will, Jessica, Chris, Brian, Daniel, Lily, Bill. Use the same voice for every scene of one narrator.

For custom/cloned voices or a specific ElevenLabs voice ID, use the dedicated ElevenLabs MCP instead (see `elevenlabs-advanced.md`).

## Sizing Scenes from the Audio

Measure each scene file in `calculateMetadata` with Mediabunny. Create `get-audio-duration.ts` exactly as the official `remotion-multimedia` skill shows (get-audio-duration.md), then:

```tsx
import { CalculateMetadataFunction, staticFile } from "remotion";
import { getAudioDuration } from "./get-audio-duration";

// Match the fps on this composition's <Composition> registration.
const compositionFps = 30;
const PADDING_FRAMES = 15; // breathing room after each line

const SCENE_AUDIO_FILES = ["vo-scene1.mp3", "vo-scene2.mp3", "vo-scene3.mp3"];

export const calculateMetadata: CalculateMetadataFunction<Props> = async ({
  props,
}) => {
  const durations = await Promise.all(
    SCENE_AUDIO_FILES.map((file) => getAudioDuration(staticFile(file))),
  );

  const sceneDurations = durations.map(
    (seconds) => Math.ceil(seconds * compositionFps) + PADDING_FRAMES,
  );

  return {
    durationInFrames: sceneDurations.reduce((sum, d) => sum + d, 0),
    props: { ...props, sceneDurations },
  };
};
```

- Keep `fps`, `width` and `height` inline on `<Composition>`; return only what depends on the audio.
- Inside the component, read `const { fps } = useVideoConfig()` and use `sceneDurations` for each scene's `durationInFrames`. Place each scene's `<Audio>` from `@remotion/media` inside that scene, following official audio.md.
- If scenes are joined with `<TransitionSeries>`, subtract the transition overlaps from the total (official transitions.md).
- When a scene's line is regenerated, Studio re-runs `calculateMetadata` and the timing updates by itself.

## Captions from the Voiceover

Word-level captions follow the official `remotion-captions` skill; `captions-workflow.md` adds the TikTok-style presets. Use `generate_subtitles` only when the user wants an `.srt` file, or for quick line-level captions imported with `parseSrt` (official import-srt-captions.md):

```
generate_subtitles:
  input_file: "vo-scene1.mp3"  # filename inside public/
```

## Best Practices

1. **Generate voiceover FIRST** — it determines the video's pacing
2. **One file per scene** — regenerating a line never shifts the other scenes
3. **Add padding** — a few frames after each line, plus 1-2 seconds at the start or end if the visuals need room
4. **Break scripts into short sentences** — easier for TTS and for scene matching
5. **Listen in Studio before building visuals** — Studio is already open; play the scene
6. **Use captions** — for accessibility and muted autoplay
7. **Volume levels** — voiceover at 1.0, music at 0.1-0.2 under narration, SFX at 0.5-0.8 (see `audio-integration.md`)
