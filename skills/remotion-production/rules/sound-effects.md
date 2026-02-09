# Sound Effects — SFX Generation & Timing

## Overview

Generate sound effects using remotion-media's `generate_sfx` tool (ElevenLabs SFX V2). Well-placed SFX elevate video quality — they make transitions feel polished, impacts feel powerful, and scenes feel immersive.

## Generating Sound Effects

```
generate_sfx:
  prompt: "whoosh transition sound, fast, clean, modern"
  project_path: "/path/to/remotion/project"
```

The SFX file is saved to the project's `public/` directory.

## Prompt Engineering by Category

### Transition Sounds

| Effect | Prompt |
|---|---|
| Whoosh | "fast whoosh transition sound, clean, modern" |
| Swoosh (soft) | "soft swoosh, gentle air movement, subtle" |
| Pop/Click | "UI pop click sound, satisfying, digital" |
| Rise | "rising tension sound, building anticipation, cinematic" |
| Impact | "deep bass impact hit, cinematic, powerful" |

### UI & Motion Sounds

| Effect | Prompt |
|---|---|
| Text appear | "light pop notification sound, soft, digital, clean" |
| Button click | "satisfying click button press, UI sound, crisp" |
| Slide in | "smooth slide swoosh, short, clean, interface" |
| Counter tick | "soft tick counting sound, mechanical, rhythmic" |
| Success | "positive chime success sound, bright, happy" |

### Ambient & Nature

| Effect | Prompt |
|---|---|
| City | "city ambiance traffic distant sounds, urban, busy" |
| Office | "quiet office ambiance, keyboard typing, soft murmur" |
| Nature | "birds singing forest ambiance, peaceful, morning" |
| Rain | "gentle rain on window, calming, steady, indoor" |
| Ocean | "ocean waves crashing gently on shore, relaxing" |

### Cinematic

| Effect | Prompt |
|---|---|
| Boom | "deep cinematic boom, epic trailer sound, reverb" |
| Reveal | "dramatic reveal stinger, suspenseful, orchestral hit" |
| Tension | "low rumble tension building, ominous, suspenseful" |
| Victory | "triumphant brass fanfare, short, celebratory" |
| Heartbeat | "slow heartbeat sound, deep, tense, suspenseful" |

### Product & Tech

| Effect | Prompt |
|---|---|
| Notification | "phone notification ping, modern, clean, short" |
| Typing | "keyboard typing sounds, mechanical, rhythmic" |
| Camera | "camera shutter click, DSLR, crisp" |
| Power on | "tech device powering on, electronic hum, modern" |
| Glitch | "digital glitch error sound, distorted, brief" |

## Timing SFX in Remotion

### SFX on a Specific Frame

```tsx
// Play a whoosh at the exact moment a slide transition happens
<Sequence from={3 * fps} durationInFrames={fps}>
  <Audio src={staticFile("audio/whoosh.mp3")} volume={0.6} />
</Sequence>
```

### SFX Synced to Text Appearance

```tsx
// Each text line gets a pop sound
const textLines = ["Line One", "Line Two", "Line Three"];
const staggerDelay = 15; // frames between each line

<>
  {textLines.map((line, i) => (
    <Sequence key={i} from={i * staggerDelay}>
      <Audio src={staticFile("audio/pop.mp3")} volume={0.4} />
    </Sequence>
  ))}
</>
```

### Ambient Background SFX

```tsx
// City ambiance throughout the scene, fading in/out
const frame = useCurrentFrame();
const { durationInFrames, fps } = useVideoConfig();

const ambientVolume = interpolate(
  frame,
  [0, fps, durationInFrames - fps, durationInFrames],
  [0, 0.15, 0.15, 0],
  { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
);

<Audio src={staticFile("audio/city-ambiance.mp3")} volume={ambientVolume} />
```

### Impact on Scene Transition

```tsx
// Bass hit right at the scene cut
<Sequence from={sceneChangeFrame - 5} durationInFrames={30}>
  <Audio src={staticFile("audio/bass-impact.mp3")} volume={0.7} />
</Sequence>
```

## Volume Guidelines

| Layer | Volume Range | Notes |
|---|---|---|
| Voiceover | 0.9–1.0 | Always loudest |
| Sound effects | 0.4–0.7 | Noticeable but not distracting |
| Ambient SFX | 0.1–0.2 | Subtle background texture |
| Background music | 0.1–0.25 | Under voiceover |
| Transition SFX | 0.5–0.8 | Brief, punchy, can be louder |

**Rule:** SFX should enhance, not compete. If you notice the SFX more than the content, lower the volume.

## SFX Design by Video Type

### Product Demo
- Pop sounds for feature callouts
- Subtle click for UI interactions
- Whoosh for screen transitions
- Success chime for "it works!" moments

### Explainer / Educational
- Soft pops for bullet points appearing
- Gentle whoosh for topic transitions
- Ambient office/classroom sounds (optional)
- Light chime for key takeaways

### Social Media (TikTok/Reels)
- Punchy transition whooshes
- Bass impacts for text reveals
- Satisfying pop sounds for reactions
- Trending audio cues

### Cinematic / Promo
- Deep booms for scene changes
- Rising tension for build-ups
- Ambient nature/city sounds per scene
- Dramatic stingers for reveals

## Best Practices

1. **Less is more** — 2-3 well-placed SFX beat 10 random ones
2. **Time SFX to visual events** — sync to transitions, text appearances, scene cuts
3. **Use short SFX** — most effects should be under 2 seconds
4. **Layer thoughtfully** — don't stack multiple SFX at the same timestamp
5. **Fade ambient sounds** — never start or stop ambient SFX abruptly
6. **Match the tone** — cinematic videos need cinematic SFX, not cartoon pops
7. **Test with music** — ensure SFX and music don't clash at the same frequencies
8. **Save with descriptive names** — `whoosh-transition.mp3` not `sfx1.mp3`
