# Replicate Models — AI Image & Video Generation via MCP

## Overview

The Replicate MCP server gives you access to 100+ AI models for image and video generation. Always use the MCP tools — never make direct API calls.

## MCP Tools

Use these Replicate MCP tools (available when `REPLICATE_API_TOKEN` is set):

```
replicate_run:
  model: "owner/model-name"
  input: { prompt: "...", aspect_ratio: "16:9" }
```

For long-running models (video generation), use async predictions:

```
replicate_create_prediction:
  model: "owner/model-name"
  input: { prompt: "...", num_frames: 81 }
```

Then poll with `replicate_get_prediction` until status is `succeeded`.

## Image Models

| Model | Best For | Speed | Quality |
|---|---|---|---|
| `black-forest-labs/flux-1.1-pro` | General-purpose, great prompt following | Fast | High |
| `google/imagen-4` | Photorealistic images | Medium | Very high |
| `ideogram-ai/ideogram-v3` | Text-in-image, logos, typography | Medium | High |
| `black-forest-labs/flux-kontext-pro` | Style transfer, multi-reference | Medium | High |

### Image Generation Example

```
replicate_run:
  model: "black-forest-labs/flux-1.1-pro"
  input:
    prompt: "modern tech office interior, natural lighting, minimal design, photorealistic"
    aspect_ratio: "16:9"
    output_format: "png"
```

## Video Models

| Model | Best For | Speed | Duration |
|---|---|---|---|
| `wan-video/wan-2.5-t2v-fast` | Fast text-to-video drafts | ~40s | 3-5s |
| `wan-video/wan-2.5-t2v` | Higher quality text-to-video | ~3min | 3-8s |
| `kwaivgi/kling-v2.6-pro` | Cinematic image-to-video | ~2min | 5-10s |
| `wan-video/wan-2.5-i2v` | Open-source image-to-video | ~2min | 3-5s |

### Text-to-Video Example

```
replicate_create_prediction:
  model: "wan-video/wan-2.5-t2v-fast"
  input:
    prompt: "slow overhead drone shot of a modern city at golden hour, cinematic"
    num_frames: 81
    resolution: "480p"
```

### Image-to-Video Example

```
replicate_create_prediction:
  model: "kwaivgi/kling-v2.6-pro"
  input:
    image: "https://example.com/still.png"
    prompt: "gentle zoom in, subtle parallax motion"
    duration: 5
```

## When to Use Replicate vs remotion-media (KIE)

| Scenario | Use | Why |
|---|---|---|
| Quick image generation | remotion-media `generate_image` | Simpler, auto-saves to project |
| Specific model needed (FLUX, Imagen) | Replicate MCP | Model selection control |
| Quick video clip | remotion-media `generate_video` | Simpler, uses Veo 3.1 |
| Image-to-video animation | Replicate MCP (Kling, Wan I2V) | KIE doesn't support I2V |
| Fast draft video | Replicate MCP (Wan 2.5 Fast) | Faster than Veo for drafts |
| Text-in-image or logos | Replicate MCP (Ideogram v3) | Specialized for typography |
| Style transfer | Replicate MCP (FLUX Kontext) | Multi-reference support |

## Output Handling

Replicate returns URLs to generated files. Download them to the project:

```bash
# Download to project public/ directory
curl -o public/images/generated-hero.png "[replicate_output_url]"
curl -o public/footage/ai-clip.mp4 "[replicate_output_url]"
```

Then reference in Remotion with `staticFile()`:

```tsx
import { Img, OffthreadVideo, staticFile } from "remotion";

<Img src={staticFile("images/generated-hero.png")} />
<OffthreadVideo src={staticFile("footage/ai-clip.mp4")} />
```

## Best Practices

1. **Use MCP tools, not curl** — the Replicate MCP handles auth, polling, and errors
2. **Start with fast models** for iteration, switch to high-quality for final renders
3. **Download outputs immediately** — Replicate URLs expire after ~1 hour
4. **Use descriptive filenames** when saving — `hero-background.png` not `output.png`
5. **Check model availability** — some models may have cold start times of 30-60s
6. **Prefer remotion-media for simple tasks** — less setup, auto-saves to project
7. **Use async predictions for video** — video generation takes minutes, not seconds
