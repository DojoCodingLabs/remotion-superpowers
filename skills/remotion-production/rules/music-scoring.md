# Music Scoring — Generating & Timing Background Music

## Generating Music

Use `remotion-media`'s `generate_music` tool:

```
generate_music:
  prompt: "upbeat electronic background music, energetic, no vocals, corporate tech vibe"
  project_path: "/path/to/remotion/project"
```

### Prompt Tips for Better Music

- Always specify **"no vocals"** for background music (unless you want singing)
- Include the **mood**: upbeat, calm, dramatic, inspiring, playful, cinematic
- Include the **genre**: electronic, jazz, classical, lo-fi, ambient, rock, orchestral
- Include the **use case**: "background music", "intro jingle", "outro music"
- Specify **tempo** if important: "slow tempo", "fast-paced", "120 BPM"

### Good Prompt Examples

| Video Type | Music Prompt |
|---|---|
| Tech product demo | "upbeat electronic background music, energetic, no vocals, modern tech startup vibe" |
| Explainer video | "light acoustic background music, friendly and warm, no vocals, educational feel" |
| Cinematic promo | "epic cinematic orchestral music, building tension, dramatic, no vocals" |
| Social media ad | "catchy pop-inspired background music, fun and energetic, no vocals, short and punchy" |
| Corporate presentation | "professional ambient background music, calm and confident, no vocals, minimal" |
| Travel/lifestyle | "chill lo-fi hip hop, relaxed vibes, no vocals, smooth and dreamy" |

## Timing Music to Video

### Pattern 1: Music matches video length (simple)

```tsx
// Music plays full duration, fades in and out
const frame = useCurrentFrame();
const { durationInFrames, fps } = useVideoConfig();

const musicVolume = interpolate(
  frame,
  [0, fps, durationInFrames - 2 * fps, durationInFrames],
  [0, 0.25, 0.25, 0],
  { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
);

<Audio src={staticFile("audio/music.mp3")} volume={musicVolume} />
```

### Pattern 2: Music with voiceover ducking

When voiceover plays, drop music volume. See `audio-integration.md` for the ducking pattern.

### Pattern 3: Different music for different scenes

```tsx
<>
  {/* Intro music — first 5 seconds */}
  <Sequence from={0} durationInFrames={5 * fps}>
    <Audio src={staticFile("audio/intro-music.mp3")} volume={0.4} />
  </Sequence>

  {/* Main background music */}
  <Sequence from={5 * fps} durationInFrames={20 * fps}>
    <Audio src={staticFile("audio/main-music.mp3")} volume={0.2} />
  </Sequence>

  {/* Outro music — last 5 seconds */}
  <Sequence from={25 * fps}>
    <Audio src={staticFile("audio/outro-music.mp3")} volume={0.4} />
  </Sequence>
</>
```

### Pattern 4: Loop short music for long videos

If the generated music is shorter than the video:

```tsx
import { Loop, Audio, staticFile } from "remotion";

// Loop a 30-second track for a 2-minute video
<Loop durationInFrames={30 * fps}>
  <Audio src={staticFile("audio/music-loop.mp3")} volume={0.25} />
</Loop>
```

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
