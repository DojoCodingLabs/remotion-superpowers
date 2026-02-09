---
name: generate-clip
description: Generate AI video clips for your Remotion project. Create unique footage from text descriptions or animate still images into video — no stock footage needed.
---

# Generate Clip — AI Video Generation

You are helping the user generate custom AI video clips for their Remotion project. This creates unique footage that doesn't exist anywhere — going beyond stock footage.

## Workflow

### 1. Understand the Need

Ask the user:
- **What should the clip show?** — A scene, product, animation, nature, abstract?
- **Duration** — How long? (typically 3-10 seconds for AI clips)
- **Style** — Cinematic, drone shot, close-up, slow motion, time-lapse?
- **Source** — Text-to-video (from description) or image-to-video (animate a still)?

### 2. Craft the Video Prompt

Good video generation prompts include:
- Scene description with action/motion
- Camera movement (pan, zoom, dolly, crane, static)
- Lighting and mood
- Speed (slow motion, normal, time-lapse)

**Good prompt examples:**
- "Slow overhead crane shot of a modern city at golden hour, cars moving on streets, warm cinematic lighting"
- "Close-up of coffee being poured into a white mug, steam rising, soft morning light, shallow depth of field"
- "Abstract fluid art animation, flowing metallic gold and deep blue paint, mesmerizing slow motion"
- "Drone flying through a forest canopy, sunlight filtering through leaves, cinematic nature footage"

### 3. Generate via remotion-media

```
Use remotion-media generate_video:
- prompt: [crafted prompt]
- project_path: [project root path]
```

The clip is saved to the project's `public/` directory.

### 4. Generate via Replicate MCP (if available)

If the user has `REPLICATE_API_TOKEN` and wants specific models, use the Replicate MCP tools:

**Text-to-Video:**
```
# Wan 2.5 (open source, fast)
replicate_create_prediction:
  model: "wan-video/wan-2.5-t2v-fast"
  input:
    prompt: "[crafted prompt]"
    num_frames: 81
    resolution: "480p"
```

**Image-to-Video (animate a still):**
```
# Kling 2.6 (cinematic, top-tier I2V)
replicate_create_prediction:
  model: "kwaivgi/kling-v2.6-pro"
  input:
    image: "[image_url]"
    prompt: "[motion description]"
    duration: 5
```

Poll with `replicate_get_prediction` until status is `succeeded`, then download the output:
```bash
curl -o public/footage/[descriptive-name].mp4 "[replicate_output_url]"
```

**Model recommendations:**
- **Fast & cheap**: Wan 2.5 Fast (`wan-video/wan-2.5-t2v-fast`) — ~40s for 5s clip
- **High quality**: Veo 3.1 (via remotion-media) or Kling 2.6
- **Image-to-video**: Kling 2.6 Pro (`kwaivgi/kling-v2.6-pro`) or Wan 2.5 I2V
- **Open source**: Wan 2.5 (`wan-video/wan-2.5-t2v`) — higher quality, slower

See `skills/remotion-production/rules/replicate-models.md` and `rules/video-generation.md` for detailed prompt engineering and model selection guidance.

### 5. Show Usage in Remotion

```tsx
import { OffthreadVideo, staticFile } from "remotion";

// Full-scene background clip
<OffthreadVideo
  src={staticFile("footage/ai-clip.mp4")}
  style={{ width: "100%", height: "100%", objectFit: "cover" }}
/>

// Trimmed clip in a sequence
<Sequence from={5 * fps} durationInFrames={3 * fps}>
  <OffthreadVideo
    src={staticFile("footage/ai-clip.mp4")}
    startFrom={0}
    style={{ width: "100%", height: "100%", objectFit: "cover" }}
  />
</Sequence>
```

### 6. Combine with Other Assets

AI-generated clips work great when layered:
- Use as backgrounds behind text overlays
- Intercut with stock footage from Pexels
- Add voiceover and music on top
- Apply subtle zoom/pan with `interpolate()` for extra dynamism

### Tips

- **Start short** — 3-5 second clips are the sweet spot for AI video
- **Be specific about camera motion** — "slow dolly zoom", "overhead crane shot"
- **Combine clips** — Generate several short clips and sequence them in Remotion
- **Image-to-video** — Generate a still with `/generate-image` first, then animate it for more control
- **Iterate** — If the first generation isn't perfect, refine the prompt
