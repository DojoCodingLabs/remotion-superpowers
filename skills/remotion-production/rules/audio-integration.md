# Audio Integration in Remotion

## Placing Audio

Place every file with `<Audio>` from `@remotion/media` (install with `npx remotion add @remotion/media`), following the official `remotion-markup` skill (audio.md). It covers trimming (`trimBefore` / `durationInFrames`), delaying (`from`), `volume`, `loop`, `playbackRate` and muting. Never use HTML `<audio>` tags.

Put `from`, `loop` and `volume` directly on `<Audio>` rather than wrapping it in a `<Sequence>`, so each layer stays editable in Studio.

## Layer Conventions

| Layer | File (from the MCP tools) | Volume | Placement |
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

The MCP tools return a path, not a duration. Measure files in `calculateMetadata` with Mediabunny, as the official `remotion-multimedia` skill shows (get-audio-duration.md), and convert with `Math.ceil(seconds * fps)`. The per-scene pattern is in `voiceover-sync.md`.

## File Naming

remotion-media tools write to the `public/` root, so the type goes in `output_name`: `vo-scene1`, `music-bg`, `sfx-whoosh`. Reference them as `staticFile("vo-scene1.mp3")`. See `asset-management.md`.
