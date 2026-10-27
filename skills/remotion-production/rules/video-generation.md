# Video Generation — AI Video Clips & Workflow

## Overview

Generate custom AI video clips for Remotion projects. **KIE via remotion-media is the default**; Replicate is for specific models and the fallback when KIE fails. Prompt-writing technique comes from Replicate's official `prompt-videos` skill (model-agnostic, so it applies to Veo prompts too). This file keeps what's specific to Remotion: provider choice, durations that fit scenes, consistency across scenes, and integration.

## Provider Decision Matrix

| Need | Provider | Model (as of Oct 2026) | Why |
|---|---|---|---|
| Quick clip, simple scene | remotion-media `generate_video_from_text` | Veo 3.1 (`veo3_fast` default, `veo3` for quality) | Simplest, auto-saves |
| Animate a still | remotion-media `generate_video_from_image` | Veo 3.1 | 1 image to animate, 2 for a first-to-last-frame transition |
| **KIE call fails or hangs** | Replicate | Kling v3, Seedance 2 or Wan 2.7 | KIE's Veo depends on a preview Google is shutting down |
| Cinematic image-to-video, end frame | Replicate | Kling v3 | `start_image` / `end_image` |
| Reference images or videos | Replicate | Seedance 2 | `image`, `last_frame_image`, `reference_images` |
| Open-weights, cheaper | Replicate | Wan 2.7 | |
| Exact duration or 1080p | Replicate | Read the schema | KIE's Veo is fixed at ~8 s, 720p |
| Real footage | Pexels MCP | N/A | Free stock video |

For Replicate, search with `search_models` and read the model's input schema (`get_models` / `list_models_examples`) before calling: durations, resolutions and frame inputs differ per model. See `replicate-models.md` for the create → `get_predictions` → download flow.

### remotion-media calls

```
generate_video_from_text:
  prompt: "<prompt>"
  output_name: "clip-city-aerial"   # saved as public/clip-city-aerial.mp4
  model: "veo3_fast"                # or "veo3" for finals
  aspect_ratio: "16:9"              # "9:16" for shorts; no square option

generate_video_from_image:
  prompt: "<how the image should move>"
  image_urls: ["https://..."]       # 1 to animate, 2 to transition; public URLs only
  output_name: "clip-hero-move"
```

- `image_urls` must be **public URLs KIE can fetch**, not files in `public/`. Reuse the KIE-hosted URL `generate_image` returns (deleted after 14 days), or a Replicate output URL while it's valid (1 hour).
- **Veo shutdown risk.** Google is retiring the Veo 3.1 preview that KIE's Veo depends on. If a KIE video call errors, times out or returns nothing, don't retry it in a loop: switch to Replicate (Kling v3, Seedance 2 or Wan 2.7) with the same prompt.

## Prompt Engineering

Follow the official `prompt-videos` skill for technique: scene descriptions rather than captions, shot types, camera motion, lens language, audio layers, multi-shot prompts. What we add:

### Prompt Structure

```
[Camera Motion] + [Subject/Action] + [Setting] + [Lighting/Mood] + [Speed]
```

**Example:** "Slow dolly push into a modern coffee shop interior as a barista pours latte art, warm morning light through large windows, cinematic, real-time speed."

### Video-specific additions

- **One shot per clip.** Remotion does the cutting; ask for a single continuous shot, and cut between clips with `TransitionSeries`.
- **Leave room for overlays.** Ask for negative space where titles or captions go ("subject on the right third, clean sky above").
- **No burned-in text.** Ask for "no text, no subtitles"; Remotion renders titles and captions.
- **Plan the audio.** Veo and some Replicate models generate sound. Mute it unless the scene needs it; the voiceover and music come from ElevenLabs.

### I2V Motion Prompts

When animating a still, describe only what should move, not the scene:
- "gentle push in with subtle parallax"
- "clouds moving slowly across the sky"
- "camera slowly panning right"
- "water rippling, leaves swaying in wind"
- "person turning to face camera, smiling"

### Consistency across scenes

- Write one **style block** (look, lighting, palette, lens, grain) and paste it verbatim into every clip's prompt. Change only the subject, action and camera.
- Repeat a recurring character's description word for word, and prefer image-to-video from stills that already match (see `image-generation.md`).
- Keep one model for the whole video; mixing Veo, Kling and Wan clips changes the look. If you switch to the Replicate fallback mid-project, regenerate the earlier clips with the same model when the difference shows.
- Match the aspect ratio to the composition on every clip.

## Image-to-Video Pipeline

The most controlled workflow for AI video:

1. **Generate a still** with `/generate-image`, matching the composition's aspect ratio.
2. **Animate it**: `generate_video_from_image` with the still's public URL, or on Replicate a model like Kling v3 with the URL in its `start_image` input (check the schema).
3. **Write a motion-only prompt** (above).

```
# Replicate fallback: animate a FLUX.2 still with Kling v3 (inputs from get_models)
create_models_predictions:
  model_owner: "kwaivgi"
  model_name: "kling-v3-video"
  input:
    start_image: "<output URL of the still's prediction>"
    prompt: "gentle push in, clouds slowly moving, subtle parallax"
    # duration, aspect ratio, mode: take names and allowed values from the schema
# then get_predictions until succeeded, and curl -L the output into public/footage/
```

## Durations That Fit Scenes

| Duration | Frames (24fps) | Frames (30fps) | Use Case |
|---|---|---|---|
| 3 seconds | 72 | 90 | Transition shots, B-roll |
| 5 seconds | 120 | 150 | Standard scene clip |
| 8 seconds | 192 | 240 | Extended establishing shot |
| 10 seconds | 240 | 300 | Maximum for most AI models |

**Sweet spot: 3-5 seconds on screen.** Sequence several short clips rather than generating one long one.

- **Generate a little longer than the scene**, then trim. KIE's Veo always gives ~8 s, so pick the best 3-5 s with `trimBefore` and `durationInFrames`. On Replicate, `duration` is usually an enum (often 5 or 10 s); pick the smallest value that covers the scene plus about 1 s of handle.
- **The scene drives the clip, not the reverse.** Size each `Sequence` from the voiceover or the script (`Math.ceil(seconds * fps)`), and trim the clip to fit.
- If a scene must last as long as the clip itself, measure it in `calculateMetadata` with Mediabunny, as the official `remotion-multimedia` skill shows (get-video-duration.md), instead of trusting the requested duration.
- AI clips can come out at a different frame rate or size than the composition; `<Video>` handles it, and `objectFit="cover"` fills the frame.

## Remotion Integration

### Where the files land

- **remotion-media** (`generate_video_from_text`, `generate_video_from_image`) writes `public/<output_name>.mp4`. Put the type in the name: `output_name: "clip-city-aerial"` becomes `staticFile("clip-city-aerial.mp4")`.
- **Replicate** returns the URL in the prediction's `output` once `get_predictions` reports `succeeded`. Download it within the hour: `mkdir -p public/footage && curl -L -o public/footage/clip-city-aerial.mp4 "<output_url>"`, then `staticFile("footage/clip-city-aerial.mp4")`.

### Placing clips

Place clips with `<Video>` from `@remotion/media` (install with `npx remotion add @remotion/media`), following the official `remotion-markup` skill: embedding-videos.md for trimming, volume and looping, video-editing.md for cutting several clips together with `TransitionSeries` or a `Track`, and transitions.md for cross-fades. Trim with `trimBefore` plus `durationInFrames`.

```tsx
import { Video } from "@remotion/media";
import { TransitionSeries } from "@remotion/transitions";
import { staticFile, useVideoConfig } from "remotion";

// Veo clips run ~8 s: keep the best 3-5 s of each and mute the generated audio
export const AiBroll: React.FC = () => {
  const { fps } = useVideoConfig();

  return (
    <TransitionSeries name="AI b-roll">
      <TransitionSeries.Sequence name="Aerial" durationInFrames={4 * fps}>
        <Video name="Aerial clip" src={staticFile("clip-city-aerial.mp4")} muted objectFit="cover" />
      </TransitionSeries.Sequence>
      <TransitionSeries.Sequence name="Close-up" trimBefore={1 * fps} durationInFrames={3 * fps}>
        <Video name="Close-up clip" src={staticFile("footage/clip-closeup.mp4")} muted objectFit="cover" />
      </TransitionSeries.Sequence>
    </TransitionSeries>
  );
};
```

For a title over a clip, layer an `<AbsoluteFill>` with a bottom gradient (`linear-gradient(transparent 50%, rgba(0,0,0,0.7))`) and the text above the `<Video>`. For a grade, use the official effects on the `<Video>` (see `visual-effects.md`).

## Best Practices

1. **Start with 3-5 second clips** — the sweet spot for AI video quality
2. **Use image-to-video for more control** — generate a perfect still first, then animate
3. **Be specific about camera motion** — "slow dolly zoom" beats "moving camera"
4. **Sequence short clips** — 3 x 4-second clips > 1 x 12-second clip
5. **Use `<Video>` from `@remotion/media`** — the official video component for every clip
6. **Keep the asset convention** — remotion-media clips land at `public/clip-<name>.mp4`; Replicate downloads go to `public/footage/`
7. **Fall back to Replicate when KIE's Veo fails** — Kling v3, Seedance 2 or Wan 2.7, after reading the schema
8. **Combine with stock footage** — intercut AI clips with Pexels footage for variety
9. **Add subtle post-processing** — a slight zoom or a `colorCorrection()` grade in Remotion adds polish
10. **Mute generated audio** — Veo clips can include sound; add `muted` unless you want it
