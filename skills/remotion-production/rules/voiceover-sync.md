# Voiceover Sync — Per-Scene TTS & Timing

This follows the official `remotion-markup` skill (voiceover.md): one audio file per scene, measured in `calculateMetadata`, with the scene durations passed as props. The audio comes from the official ElevenLabs `text-to-speech` skill, through the one generation script in `audio-integration.md`. What this rule adds is the per-scene split, the names and the voice choice.

## Generating Voiceover

Split the approved script into scenes and put one entry per scene in the script's `voiceover` list:

```ts
const voiceover = [
  { name: "vo-scene1", text: "Welcome to our app." },       // this scene's narration only
  { name: "vo-scene2", text: "Everything in one place." },  // vo-scene3, vo-scene4, ...
];
```

Run `node scripts/generate-audio.ts` from the project root. Each line lands at `public/vo-sceneN.mp3`; existing files are skipped, so delete one to regenerate just that line. The script reports **no duration**; measure the files as shown below.

- **Model:** `eleven_v4` (the official default). It takes only `stability` and `similarity_boost`, with no `style` or `speed`: steer delivery with audio tags (`[excited]`, `[whispers]`) and punctuation instead. For a long single read that has to stay very even, `eleven_multilingual_v2` is the official alternative.
- **Language:** pass `languageCode` (e.g. `"es"`) for non-English narration, per the official skill.

**Alternatives:** the deprecated ElevenLabs MCP `text_to_speech` (interactive one-offs; rename its output to `vo-sceneN.mp3`), or KIE `generate_speech` for drafts (`text`, `output_name: "vo-scene1"`, `voice: "Eric"`, max 5000 characters). Suno and the other KIE-resold models aren't licensed by their owners through KIE. Use KIE audio for drafts and internal work, and generate final commercial audio with ElevenLabs.

## Voice Selection Guide

Set `VOICE_ID` in the script once and use the same voice for every scene of one narrator. Pre-made voices from the official skill:

- **George** (`JBFqnCBsd6RMkjVDRZzb`) — Male, narrative (good default)
- **Sarah** (`EXAVITQu4vr4xnSDxMaL`) — Female, soft
- **Daniel** (`onwK4e9ZLuTAKqWW03F9`) — Male, authoritative (good for narration)
- **Charlotte** (`XB0fDUnXU5powFXDhCwa`) — Female, conversational

For any other voice (a mood, an accent, a language), search the account or the shared library and paste its ID: see "Voice Library" in `elevenlabs-advanced.md`. Cloned voices and several speakers in one script are covered there too.

KIE drafts use voice names instead of IDs: Eric (default), Rachel, Aria, Roger, Sarah, Laura, Charlie, George, Callum, River, Liam, Charlotte, Alice, Matilda, Will, Jessica, Chris, Brian, Daniel, Lily, Bill.

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

Caption each `vo-sceneN.mp3` on its own with the official `remotion-captions` flow (word-level, `@remotion/whisper-webgpu`), or with the ElevenLabs Scribe fallback when there's no GPU. `captions-workflow.md` has both routes and the TikTok-style presets.

## Best Practices

1. **Generate voiceover FIRST** — it determines the video's pacing
2. **One file per scene** — regenerating a line never shifts the other scenes
3. **Add padding** — a few frames after each line, plus 1-2 seconds at the start or end if the visuals need room
4. **Break scripts into short sentences** — easier for TTS and for scene matching
5. **Listen in Studio before building visuals** — Studio is already open; play the scene
6. **Use captions** — for accessibility and muted autoplay
7. **Volume levels** — voiceover at 1.0, music at 0.1-0.2 under narration, SFX at 0.5-0.8 (see `audio-integration.md`)
