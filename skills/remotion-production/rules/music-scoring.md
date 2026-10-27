# Music Scoring — Generating & Timing Background Music

## Generating Music

Music comes from Eleven Music (`music_v2_5`), following the official ElevenLabs `music` skill, through the generation script in `audio-integration.md`. Add one entry per track to its `music` list:

```ts
const music = [
  { name: "music-bg", prompt: "upbeat electronic background music, energetic, corporate tech vibe", lengthMs: 30_000 },
];
```

The script passes `forceInstrumental: true`, so background tracks have no vocals. Set `lengthMs` to the video length (3 s to 10 min) once the voiceover is measured, rounded up a few seconds so the fade-out has room. The file lands at `public/music-bg.mp3`.

- The Music API needs a paid ElevenLabs plan. Eleven Music is cleared for commercial use on paid plans.
- Prompts can't name artists, bands or copyrighted lyrics. A `bad_prompt` error comes with a suggested rewording; use it.
- For section-by-section control (quiet intro, build, drop), use a composition plan as the official skill shows, instead of several separate tracks.

**Alternatives:** the deprecated ElevenLabs MCP `compose_music` (interactive one-offs; it only offers `music_v1`/`music_v2`, so rename its output to `music-bg.mp3`), or KIE `generate_music` for drafts (`prompt`, `output_name: "music-bg"`, `instrumental: true`). Suno and the other KIE-resold models aren't licensed by their owners through KIE. Use KIE audio for drafts and internal work, and generate final commercial audio with ElevenLabs.

### Prompt Tips for Better Music

- Keep `forceInstrumental: true` for background music (set it to `false` only if you want singing)
- Include the **mood**: upbeat, calm, dramatic, inspiring, playful, cinematic
- Include the **genre**: electronic, jazz, classical, lo-fi, ambient, rock, orchestral
- Include the **use case**: "background music", "intro jingle", "outro music"
- Specify **tempo** if important: "slow tempo", "fast-paced", "120 BPM"

### Good Prompt Examples

| Video Type | Music Prompt |
|---|---|
| Tech product demo | "upbeat electronic background music, energetic, modern tech startup vibe" |
| Explainer video | "light acoustic background music, friendly and warm, educational feel" |
| Cinematic promo | "epic cinematic orchestral music, building tension, dramatic" |
| Social media ad | "catchy pop-inspired background music, fun and energetic, short and punchy" |
| Corporate presentation | "professional ambient background music, calm and confident, minimal" |
| Travel/lifestyle | "chill lo-fi hip hop, relaxed vibes, smooth and dreamy" |

## Timing Music to Video

Place music with `<Audio>` from `@remotion/media`, following the official `remotion-markup` skill (audio.md). Put `from`, `durationInFrames`, `loop` and `volume` directly on `<Audio>`, not on a wrapping `<Sequence>` or `<Loop>`.

### Pattern 1: Music matches video length (simple)

```tsx
import { Audio } from "@remotion/media";
import { interpolate, staticFile, useCurrentFrame, useVideoConfig } from "remotion";

const frame = useCurrentFrame();
const { durationInFrames, fps } = useVideoConfig();

// Music plays full duration, fades in and out
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

If the track is longer than the video, it is cut at the composition end; the fade-out above hides the cut.

### Pattern 2: Music with voiceover ducking

When voiceover plays, drop music volume. See `audio-integration.md` for the ducking pattern.

### Pattern 3: Different music for different scenes

Add one entry per section to the script's `music` list (`music-intro`, `music-main`, `music-outro`) and give each `<Audio>` its own `from` and `durationInFrames` (e.g. intro 0–5s at 0.4, main 5–25s at 0.2, outro from 25s at 0.4). Fade each one in and out so the hand-offs don't click.

### Pattern 4: Loop short music for long videos

If the track is shorter than the video, add `loop` to `<Audio>` (official audio.md, "Looping"). The jump back to the start can be audible, so for long videos regenerate with a longer `lengthMs` instead (up to 10 minutes).

## Volume Guidelines

| Layer | Volume | Notes |
|---|---|---|
| Voiceover | 1.0 | Always the loudest |
| Sound effects | 0.5–0.8 | Prominent but not overwhelming |
| Background music (with voiceover) | 0.1–0.2 | Ducked when narration plays |
| Background music (no voiceover) | 0.25–0.4 | Can be louder when no one's talking |
| Intro/outro music (no voiceover) | 0.3–0.5 | Slightly louder for emphasis |

## Best Practices

1. **Generate music AFTER voiceover** — you need to know the video duration
2. **Always fade in/out** — abrupt music starts/stops sound jarring
3. **Keep music subtle** — it supports the visuals, not compete with them
4. **Match the mood** — energetic music for fast cuts, calm music for slow pans
5. **Test with voiceover** — ensure the music doesn't clash with the narration
