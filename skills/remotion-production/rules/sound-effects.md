# Sound Effects — SFX Generation & Timing

## Overview

Well-placed SFX elevate video quality — they make transitions feel polished, impacts feel powerful, and scenes feel immersive. There are two sources; pick in this order:

1. **Hosted SFX first, for generic sounds.** The official `remotion-markup` skill (sfx.md) lists free files at `https://remotion.media/*.wav`: whoosh, whip, page-turn, switch, mouse-click, shutter-modern, shutter-old, ding, record-scratch, vine-boom and a set of meme sounds. Use the URL directly as the `<Audio>` `src`. No generation cost, no file to manage.
2. **ElevenLabs for everything else.** The official ElevenLabs `sound-effects` skill (`eleven_text_to_sound_v2`, 0.5–30 s) makes custom sounds: a specific impact, an ambience, a branded chime, anything with a particular length or character. Generate them with the script in `audio-integration.md`.

| Need | Source |
|---|---|
| Plain whoosh, click, switch, ding, camera shutter, page turn | Hosted (`https://remotion.media/whoosh.wav`, `mouse-click.wav`, `switch.wav`, `ding.wav`, `shutter-modern.wav`, `page-turn.wav`) |
| Meme sounds for short-form (vine boom, record scratch, bruh…) | Hosted (full list in official sfx.md) |
| Cinematic booms, risers, stingers, tension | ElevenLabs |
| Ambience (city, office, rain, nature) | ElevenLabs with `loop: true` |
| Branded or very specific sounds | ElevenLabs |
| A hosted sound that doesn't fit the tone | ElevenLabs |

## Generating Sound Effects

Add one entry per sound to the `sfx` list in `scripts/generate-audio.ts` (`audio-integration.md`):

```ts
const sfx = [
  { name: "sfx-impact", text: "deep bass impact hit, cinematic, powerful", seconds: 1.5 },
  { name: "sfx-city-ambiance", text: "city ambiance traffic distant sounds, urban, busy", seconds: 10, loop: true },
];
```

`seconds` is 0.5–30; leave it out to let the model choose. `loop: true` makes a seamless ambience bed. If the result drifts from the prompt, add `promptInfluence` (0–1, default 0.3) to the `convert()` call, as the official skill shows. Each file lands at `public/<name>.mp3`.

**Alternatives:** the deprecated ElevenLabs MCP `text_to_sound_effects` (interactive one-offs; rename its output to the `sfx-` convention), or KIE `generate_sound_effect` for drafts (`prompt`, `output_name: "sfx-impact"`, `duration_seconds` 0.5–22, `loop`). Suno and the other KIE-resold models aren't licensed by their owners through KIE. Use KIE audio for drafts and internal work, and generate final commercial audio with ElevenLabs.

## Prompt Engineering by Category

Prompts for ElevenLabs SFX (the `text` field). For the transition and UI rows, try the hosted file first and generate only when you need a different character.

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

Place each effect with `<Audio>` from `@remotion/media`, following the official `remotion-markup` skill (audio.md and sfx.md). Set `from` on the `<Audio>` itself to the frame of the visual event; don't wrap it in a `<Sequence>`.

```tsx
import { Audio } from "@remotion/media";
import { staticFile } from "remotion";

// Hosted whoosh on the slide transition, generated impact just before the cut
<Audio src="https://remotion.media/whoosh.wav" from={3 * fps} volume={0.6} />
<Audio src={staticFile("sfx-impact.mp3")} from={sceneChangeFrame - 5} volume={0.7} />
```

- **Synced to text appearance:** one `<Audio from={i * staggerDelay}>` per line, using the same stagger as the text animation, at 0.3-0.5.
- **On a scene cut:** start an impact 3-5 frames before the cut so the transient lands on it.
- **Ambient background:** `loop` plus a fade-in/fade-out `interpolate()` on `volume` (0 → 0.15 → 0), inside the scene it belongs to.

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
8. **Save with descriptive names** — `name: "sfx-whoosh-transition"` not `"sfx1"`
9. **Don't generate what's hosted** — check the official sfx.md list before paying for a plain whoosh or click
