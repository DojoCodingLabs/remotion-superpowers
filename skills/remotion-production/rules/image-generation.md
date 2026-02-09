# Image Generation — AI Image Prompting & Workflow

## Overview

Generate custom images for Remotion projects using remotion-media (KIE) or Replicate MCP. This guide covers provider selection, prompt engineering, and Remotion integration.

## Provider Decision Matrix

| Need | Provider | Model | Why |
|---|---|---|---|
| Quick background or thumbnail | remotion-media | Nano Banana Pro | Simplest, auto-saves |
| High-quality photorealistic | Replicate MCP | FLUX 1.1 Pro or Imagen 4 | Best fidelity |
| Text in image (logos, titles) | Replicate MCP | Ideogram v3 | Typography specialist |
| Style-matched to reference | Replicate MCP | FLUX Kontext | Multi-reference input |
| Stock photo alternative | Pexels MCP | N/A (real photos) | Free, instant, no generation |

## Prompt Engineering

### Prompt Anatomy

Build prompts with these components in order:

```
[Subject] + [Style] + [Lighting] + [Camera/Angle] + [Color Palette] + [Modifiers]
```

**Example:** "Modern glass office building, photorealistic, golden hour warm lighting, low angle looking up, blue and orange tones, architectural photography"

### Subject Descriptions

Be specific about what's in the scene:
- Bad: "a city"
- Good: "a modern downtown skyline with glass skyscrapers reflecting sunset light, busy street with taxis below"

### Style Keywords

| Style | Keywords |
|---|---|
| Photorealistic | photorealistic, photo, DSLR, 8K, ultra detailed |
| Illustration | digital illustration, vector art, flat design, hand-drawn |
| 3D Render | 3D render, octane render, unreal engine, blender |
| Cinematic | cinematic still, film grain, anamorphic, movie scene |
| Minimal | minimalist, clean, simple, whitespace, modern |

### Lighting Keywords

| Mood | Keywords |
|---|---|
| Warm/Inviting | golden hour, warm lighting, soft sunlight, candlelit |
| Cool/Tech | neon lighting, cold blue, LED, cyberpunk glow |
| Dramatic | Rembrandt lighting, high contrast, chiaroscuro, spotlight |
| Soft/Dreamy | diffused light, overcast, pastel, ethereal glow |
| Studio | studio lighting, product photography, white background |

### Negative Prompts

When supported by the model, exclude unwanted elements:
- `"no text, no watermark, no borders, no logo"`
- `"no people, no faces"` (for abstract backgrounds)
- `"no blur, sharp focus"` (for crisp images)

## Aspect Ratios for Remotion

| Format | Aspect Ratio | Dimensions | Use Case |
|---|---|---|---|
| Landscape (default) | 16:9 | 1920x1080 | YouTube, presentations |
| Portrait | 9:16 | 1080x1920 | TikTok, Reels, Shorts |
| Square | 1:1 | 1080x1080 | Instagram, thumbnails |
| Ultra-wide | 21:9 | 2560x1080 | Cinematic letterbox |

Always match the image aspect ratio to your Remotion composition's dimensions.

## When to Generate vs Use Stock

| Scenario | Recommendation |
|---|---|
| Real-world scenes (offices, nature, people) | Pexels stock photos |
| Abstract backgrounds, patterns, gradients | AI generation |
| Specific product/brand imagery | AI generation |
| Illustrations or stylized art | AI generation |
| Placeholder for rapid prototyping | AI generation (faster iteration) |
| Need exact real-world accuracy | Stock photos |

## Remotion Integration

### Basic Image Display

```tsx
import { Img, staticFile } from "remotion";

<Img
  src={staticFile("images/hero-background.png")}
  style={{ width: "100%", height: "100%", objectFit: "cover" }}
/>
```

### Ken Burns Effect (Slow Zoom + Pan)

```tsx
const frame = useCurrentFrame();
const { durationInFrames } = useVideoConfig();

const scale = interpolate(frame, [0, durationInFrames], [1, 1.15], {
  extrapolateRight: "clamp",
});
const translateX = interpolate(frame, [0, durationInFrames], [0, -3], {
  extrapolateRight: "clamp",
});

<Img
  src={staticFile("images/landscape.png")}
  style={{
    width: "100%",
    height: "100%",
    objectFit: "cover",
    transform: `scale(${scale}) translateX(${translateX}%)`,
  }}
/>
```

### Image Reveal with Spring

```tsx
const frame = useCurrentFrame();
const { fps } = useVideoConfig();

const scale = spring({ frame, fps, config: { damping: 200 } });
const opacity = interpolate(frame, [0, 10], [0, 1], {
  extrapolateRight: "clamp",
});

<Img
  src={staticFile("images/product.png")}
  style={{
    transform: `scale(${scale})`,
    opacity,
  }}
/>
```

### Layered Composition (Image + Text Overlay)

```tsx
<AbsoluteFill>
  <Img
    src={staticFile("images/background.png")}
    style={{ width: "100%", height: "100%", objectFit: "cover" }}
  />
  <div style={{
    position: "absolute",
    bottom: 100,
    left: 60,
    color: "white",
    fontSize: 72,
    fontWeight: "bold",
    textShadow: "2px 2px 8px rgba(0,0,0,0.8)",
  }}>
    Your Title Here
  </div>
</AbsoluteFill>
```

## Best Practices

1. **Match aspect ratio to composition** — generating 1:1 images for a 16:9 video wastes quality
2. **Generate at or above target resolution** — upscaling degrades quality
3. **Use descriptive filenames** — `hero-office-golden-hour.png` not `image1.png`
4. **Save to `public/images/`** — keep generated images organized
5. **Try stock first for real-world scenes** — AI still struggles with hands, text, and specific objects
6. **Iterate on prompts** — generate 2-3 variations, pick the best one
7. **Add Ken Burns to still images** — subtle motion makes stills feel cinematic in video
