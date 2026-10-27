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

### Where the files land

- **remotion-media** `generate_image` writes `public/<output_name>.png`. Put the type in the name: `output_name: "img-hero"` becomes `staticFile("img-hero.png")`.
- **Replicate** and **Pexels** return URLs. Download them yourself: `mkdir -p public/images && curl -L -o public/images/img-hero.png "<url>"`, then `staticFile("images/img-hero.png")`.

### Placing images

Add images with `<CanvasImage>` from `remotion`, as the official `remotion-markup` skill does (`<Img>` still works; both accept `effects` for grading). Sizing, dynamic paths and dimensions are in its images.md. The one recipe worth keeping here is the Ken Burns move, because it's what makes generated stills feel like footage:

```tsx
import { CanvasImage, interpolate, staticFile, useCurrentFrame, useVideoConfig } from "remotion";

export const KenBurns: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames } = useVideoConfig();

  return (
    <CanvasImage
      name="Hero still"
      src={staticFile("img-hero.png")}
      style={{
        width: "100%",
        height: "100%",
        objectFit: "cover",
        // Slow zoom + drift, inline so Studio can edit the keyframes
        scale: interpolate(frame, [0, durationInFrames], [1, 1.15], {
          extrapolateLeft: "clamp", extrapolateRight: "clamp",
          output: "perceptual-scale",
        }),
        translate: interpolate(frame, [0, durationInFrames], ["0% 0%", "-3% 0%"], {
          extrapolateLeft: "clamp", extrapolateRight: "clamp",
        }),
      }}
    />
  );
};
```

- Keep the zoom between 1.05 and 1.2 over the shot; more looks like a mistake.
- Alternate direction between consecutive stills (zoom in, then out; drift left, then right).
- For pop-in reveals and text over the image, use the recipes in `animation-presets.md` and the official timing.md.

## Best Practices

1. **Match aspect ratio to composition** — generating 1:1 images for a 16:9 video wastes quality
2. **Generate at or above target resolution** — upscaling degrades quality
3. **Use descriptive, typed filenames** — `img-hero-office-golden-hour` not `image1`
4. **Follow the asset convention** — `generate_image` saves to `public/img-<name>.png`; images you download (Replicate, Pexels) go to `public/images/`
5. **Try stock first for real-world scenes** — AI still struggles with hands, text, and specific objects
6. **Iterate on prompts** — generate 2-3 variations, pick the best one
7. **Add Ken Burns to still images** — subtle motion makes stills feel cinematic in video
