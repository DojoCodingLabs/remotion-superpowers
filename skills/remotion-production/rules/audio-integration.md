# Audio Integration in Remotion

## Generating Audio: One Script

Voiceover, music and SFX all come from ElevenLabs, following the official ElevenLabs skills (`text-to-speech`, `music`, `sound-effects`; install with `npx skills add elevenlabs/skills`). They generate through the `@elevenlabs/elevenlabs-js` SDK; this rule adds only where the files go and what they're called.

1. **Key.** If `ELEVENLABS_API_KEY` isn't set for the project, run `npx -y @elevenlabs/cli@latest onboard init` from the project root, as the official skills say. Never ask for the key in chat. Music needs a paid plan; Eleven Music is cleared for commercial use on paid plans.
2. **SDK.** `npm i @elevenlabs/elevenlabs-js` (use `@elevenlabs/*` packages only).
3. **One script, `scripts/generate-audio.ts`.** It writes straight to the `public/` root with our names. Fill the three lists from `voiceover-sync.md`, `music-scoring.md` and `sound-effects.md`:

```ts
// scripts/generate-audio.ts
// Run from the project root: node scripts/generate-audio.ts  (Node 22.18+ runs TypeScript directly)
import { ElevenLabsClient } from "@elevenlabs/elevenlabs-js";
import { createWriteStream, existsSync } from "node:fs";
import { Readable } from "node:stream";
import { pipeline } from "node:stream/promises";
import type { ReadableStream as NodeReadableStream } from "node:stream/web";

const client = new ElevenLabsClient(); // reads ELEVENLABS_API_KEY
const VOICE_ID = "JBFqnCBsd6RMkjVDRZzb"; // George; one narrator per video

const voiceover = [
  { name: "vo-scene1", text: "Welcome to our app." },
  { name: "vo-scene2", text: "Everything you need, in one place." },
];
const music = [
  { name: "music-bg", prompt: "upbeat electronic background music, energetic, modern tech vibe", lengthMs: 30_000 },
];
const sfx: { name: string; text: string; seconds?: number; loop?: boolean }[] = [
  { name: "sfx-impact", text: "deep bass impact hit, cinematic, powerful", seconds: 1.5 },
];

// Existing files are skipped, so a re-run only pays for what's new.
// Delete a file (or pass --force) to regenerate it.
const todo = (name: string) => process.argv.includes("--force") || !existsSync(`public/${name}.mp3`);
const save = async (name: string, audio: ReadableStream<Uint8Array>) => {
  await pipeline(Readable.fromWeb(audio as NodeReadableStream<Uint8Array>), createWriteStream(`public/${name}.mp3`));
  console.log(`public/${name}.mp3`);
};

for (const { name, text } of voiceover.filter((v) => todo(v.name))) {
  await save(name, await client.textToSpeech.convert(VOICE_ID, { text, modelId: "eleven_v4" }));
}
for (const { name, prompt, lengthMs } of music.filter((m) => todo(m.name))) {
  await save(name, await client.music.compose({ prompt, musicLengthMs: lengthMs, modelId: "music_v2_5", forceInstrumental: true }));
}
for (const { name, text, seconds, loop } of sfx.filter((s) => todo(s.name))) {
  await save(name, await client.textToSoundEffects.convert({ text, durationSeconds: seconds, loop }));
}
```

The run structure matches official `remotion-markup` (voiceover.md); the API calls follow the official ElevenLabs skills, which win on any parameter detail (models, voice settings, `loop`, `promptInfluence`, composition plans). Leave out the lists you don't need.

**Alternatives:**
- **ElevenLabs MCP (deprecated).** `elevenlabs-mcp` 0.12.2 is archived upstream and ships for one more release, for quick interactive one-offs: `text_to_speech`, `text_to_sound_effects`, `compose_music`. Its base path is `./public`: leave `output_directory` out (files land in `public/`) or pass the absolute path of the project's `public/`. A relative `"public"` would nest into `public/public/`. It picks its own filenames, so rename to our convention right after.
- **KIE drafts via remotion-media** (`generate_speech`, `generate_music`, `generate_sound_effect`): cheap, and they write to `public/<output_name>.mp3`. Suno and the other KIE-resold models aren't licensed by their owners through KIE. Use KIE audio for drafts and internal work, and generate final commercial audio with ElevenLabs.

## Placing Audio

Place every file with `<Audio>` from `@remotion/media` (install with `npx remotion add @remotion/media`), following the official `remotion-markup` skill (audio.md). It covers trimming (`trimBefore` / `durationInFrames`), delaying (`from`), `volume`, `loop`, `playbackRate` and muting. Never use HTML `<audio>` tags.

Put `from`, `loop` and `volume` directly on `<Audio>` rather than wrapping it in a `<Sequence>`, so each layer stays editable in Studio.

## Layer Conventions

| Layer | File (in `public/`) | Volume | Placement |
|---|---|---|---|
| Voiceover | `vo-scene1.mp3`, `vo-scene2.mp3`, … | 1.0 | One `<Audio>` per scene, inside that scene |
| Background music | `music-bg.mp3` | 0.1–0.2 under voiceover, 0.25–0.4 without | Composition level, with fade in/out and ducking |
| SFX (transition, impact) | `sfx-whoosh.mp3` or a hosted `https://remotion.media/*.wav` | 0.5–0.8 | `from` on the visual event's frame |
| SFX (UI pops, ticks) | `sfx-pop.mp3` | 0.3–0.5 | `from` on the element's entrance frame |
| Ambient SFX | `sfx-city-ambiance.mp3` | 0.1–0.2 | Scene level, `loop`, faded in/out |

**Rule:** the voiceover is always the loudest layer. If you notice the music or SFX more than the narration, lower them.

## Dynamic Volume (Ducking)

Lower the music while narration plays. With per-scene voiceover, the narration frames come from the scene durations computed in `calculateMetadata` (see `voiceover-sync.md`):

```tsx
import { Audio } from "@remotion/media";
import { interpolate, staticFile, useCurrentFrame, useVideoConfig } from "remotion";

export const MusicWithDucking: React.FC<{
  voiceoverStartFrame: number;
  voiceoverEndFrame: number;
}> = ({ voiceoverStartFrame, voiceoverEndFrame }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const fade = Math.round(0.5 * fps);

  return (
    <Audio
      src={staticFile("music-bg.mp3")}
      loop
      // Duck music to 10% during voiceover, 40% otherwise
      volume={interpolate(
        frame,
        [
          voiceoverStartFrame - fade, // Fade down over 0.5s
          voiceoverStartFrame,
          voiceoverEndFrame,
          voiceoverEndFrame + fade, // Fade up over 0.5s
        ],
        [0.4, 0.1, 0.1, 0.4],
        { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
      )}
    />
  );
};
```

For several narration blocks with gaps between them, extend the input and output ranges with one fade-down / fade-up pair per block. Pass a constant `0.1` instead if the narration runs nearly end to end.

## Common Patterns

- **Fade music in and out:** an `interpolate()` on `volume` over `[0, fps, durationInFrames - 2 * fps, durationInFrames]` → `[0, 0.3, 0.3, 0]` (official audio.md, "Volume").
- **SFX on a frame:** `<Audio src={staticFile("sfx-whoosh.mp3")} from={3 * fps} volume={0.6} />`.
- **Play only part of a file:** `trimBefore` and `durationInFrames` on `<Audio>` (official audio.md, "Trimming").
- **Music shorter than the video:** `loop` on `<Audio>` (official audio.md, "Looping").

## Measuring Audio Duration

Neither the script nor the MCP tools report a duration. Measure files in `calculateMetadata` with Mediabunny, as the official `remotion-multimedia` skill shows (get-audio-duration.md), and convert with `Math.ceil(seconds * fps)`. The per-scene pattern is in `voiceover-sync.md`.

## File Naming

All audio goes in the `public/` root with the type as a prefix: `vo-scene1`, `music-bg`, `sfx-whoosh`. The script uses these names directly, remotion-media takes them as `output_name`, and ElevenLabs MCP files get renamed to them. Reference them as `staticFile("vo-scene1.mp3")`. See `asset-management.md`.
