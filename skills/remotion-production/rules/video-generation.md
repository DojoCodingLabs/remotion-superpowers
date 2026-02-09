# Video Generation — AI Video Clips & Workflow

## Overview

Generate custom AI video clips for Remotion projects using remotion-media (KIE) or Replicate MCP. This guide covers provider selection, prompt engineering for motion, and integration into Remotion compositions.

## Provider Decision Matrix

| Need | Provider | Model | Why |
|---|---|---|---|
| Quick clip, simple scene | remotion-media | Veo 3.1 | Simplest, auto-saves |
| Fast draft / iteration | Replicate MCP | Wan 2.5 Fast | ~40s generation |
| High-quality text-to-video | Replicate MCP | Wan 2.5 | Better quality, slower |
| Animate a still image | Replicate MCP | Kling 2.6 Pro | Best image-to-video |
| Open-source I2V | Replicate MCP | Wan 2.5 I2V | Good, cheaper alternative |
| Real footage | Pexels MCP | N/A | Free stock video |

## Text-to-Video Prompt Engineering

### Prompt Structure

```
[Camera Motion] + [Subject/Action] + [Setting] + [Lighting/Mood] + [Speed]
```

**Example:** "Slow dolly zoom into a modern coffee shop interior, barista pouring latte art, warm morning light through large windows, cinematic"

### Camera Motion Keywords

| Motion | Keywords | Best For |
|---|---|---|
| Static | "static shot", "locked camera", "tripod" | Product shots, interviews |
| Pan | "slow pan left to right", "panoramic pan" | Landscapes, reveals |
| Zoom | "dolly zoom in", "slow zoom out", "push in" | Drama, focus |
| Crane/Aerial | "overhead crane shot", "bird's eye view", "aerial" | Establishing shots |
| Tracking | "tracking shot following", "side tracking" | Movement, action |
| Handheld | "handheld camera", "slight shake" | Documentary, realism |

### Speed Keywords

- **Slow motion**: "slow motion", "120fps slow-mo", "graceful slow movement"
- **Normal**: (default, no keyword needed)
- **Time-lapse**: "time-lapse", "hyperlapse", "sped up"
- **Smooth**: "smooth motion", "fluid camera movement"

### Lighting Keywords

- **Golden hour**: "golden hour", "warm sunset light", "magic hour"
- **Neon/Night**: "neon city lights", "nighttime", "moody dark"
- **Studio**: "studio lighting", "clean bright", "product photography"
- **Natural**: "natural daylight", "overcast soft light"

## Image-to-Video Pipeline

The most controlled workflow for AI video:

1. **Generate a still** with `/generate-image` (or Replicate FLUX)
2. **Animate with I2V** using Kling 2.6 or Wan I2V
3. **Add motion prompt** describing only the movement, not the scene

```
# Step 1: Generate still
replicate_run:
  model: "black-forest-labs/flux-1.1-pro"
  input:
    prompt: "modern city skyline at sunset, photorealistic, 16:9"
    aspect_ratio: "16:9"

# Step 2: Animate the still
replicate_create_prediction:
  model: "kwaivgi/kling-v2.6-pro"
  input:
    image: "[url_from_step_1]"
    prompt: "gentle zoom in, clouds slowly moving, subtle parallax"
    duration: 5
```

### I2V Motion Prompts

Keep motion prompts simple — describe only what should move:
- "gentle zoom in with subtle parallax"
- "clouds moving slowly across the sky"
- "camera slowly panning right"
- "water rippling, leaves swaying in wind"
- "person turning to face camera, smiling"

## Duration & Frame Count Guidance

| Duration | Frames (24fps) | Frames (30fps) | Use Case |
|---|---|---|---|
| 3 seconds | 72 | 90 | Transition shots, B-roll |
| 5 seconds | 120 | 150 | Standard scene clip |
| 8 seconds | 192 | 240 | Extended establishing shot |
| 10 seconds | 240 | 300 | Maximum for most AI models |

**Sweet spot: 3-5 seconds.** AI video quality degrades with longer durations. Sequence multiple short clips rather than generating one long one.

### Wan Frame Count Reference

Wan models use `num_frames` (at 16fps):
- 49 frames = ~3 seconds
- 81 frames = ~5 seconds
- 129 frames = ~8 seconds

## Remotion Integration

### Full-Scene Background Clip

```tsx
import { OffthreadVideo, staticFile } from "remotion";

<OffthreadVideo
  src={staticFile("footage/ai-city-aerial.mp4")}
  style={{ width: "100%", height: "100%", objectFit: "cover" }}
/>
```

### Trimmed Clip in a Sequence

```tsx
<Sequence from={5 * fps} durationInFrames={3 * fps}>
  <OffthreadVideo
    src={staticFile("footage/ai-clip.mp4")}
    startFrom={0}
    endAt={3 * fps}
    style={{ width: "100%", height: "100%", objectFit: "cover" }}
  />
</Sequence>
```

### Sequencing Multiple AI Clips

```tsx
const clips = [
  { src: "footage/scene1-aerial.mp4", duration: 4 },
  { src: "footage/scene2-closeup.mp4", duration: 3 },
  { src: "footage/scene3-wide.mp4", duration: 5 },
];

let offset = 0;
<>
  {clips.map((clip, i) => {
    const from = offset;
    offset += clip.duration * fps;
    return (
      <Sequence key={i} from={from} durationInFrames={clip.duration * fps}>
        <OffthreadVideo
          src={staticFile(clip.src)}
          style={{ width: "100%", height: "100%", objectFit: "cover" }}
        />
      </Sequence>
    );
  })}
</>
```

### AI Clip with Text Overlay

```tsx
<AbsoluteFill>
  <OffthreadVideo
    src={staticFile("footage/ai-background.mp4")}
    style={{ width: "100%", height: "100%", objectFit: "cover" }}
  />
  <AbsoluteFill style={{
    background: "linear-gradient(transparent 50%, rgba(0,0,0,0.7))",
  }}>
    <div style={{
      position: "absolute",
      bottom: 80,
      left: 60,
      color: "white",
      fontSize: 64,
      fontWeight: "bold",
    }}>
      Scene Title
    </div>
  </AbsoluteFill>
</AbsoluteFill>
```

## Best Practices

1. **Start with 3-5 second clips** — the sweet spot for AI video quality
2. **Use image-to-video for more control** — generate a perfect still first, then animate
3. **Be specific about camera motion** — "slow dolly zoom" beats "moving camera"
4. **Sequence short clips** — 3 x 4-second clips > 1 x 12-second clip
5. **Use `OffthreadVideo`** — always prefer over `<Video>` for better rendering performance
6. **Download outputs to `public/footage/`** — keep AI clips organized with stock footage
7. **Combine with stock footage** — intercut AI clips with Pexels footage for variety
8. **Add subtle post-processing** — a slight zoom or color grade in Remotion adds polish
