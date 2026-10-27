---
name: generate-image
description: Generate AI images for your Remotion project. Describe what you need — backgrounds, thumbnails, characters, abstract art — and get production-ready images via AI generation or Replicate models.
---

# Generate Image — AI Image Creation

You are helping the user generate custom images for their Remotion video project.

## Workflow

### 1. Understand the Need

Ask the user (if not already clear):
- **What is the image for?** — Scene background, thumbnail, character, product shot, abstract art, diagram?
- **Style** — Photorealistic, illustration, 3D render, flat design, watercolor, pixel art?
- **Dimensions** — Landscape (1920x1080), portrait (1080x1920), square (1080x1080)?
- **Mood/Colors** — Bright, dark, warm, cool, neon, pastel?

### 2. Craft the Prompt

Write a detailed image generation prompt. Good prompts include:
- Subject description
- Art style
- Lighting and mood
- Camera angle/perspective
- Color palette
- Background details

**Good prompt examples:**
- "Modern tech startup office, aerial view, clean minimalist design, bright natural lighting, white and blue color scheme, photorealistic"
- "Abstract geometric pattern, dark background, glowing neon purple and blue lines, futuristic, 3D render"
- "Friendly robot mascot waving, cartoon illustration style, pastel colors, clean white background, suitable for logo"
- "Golden hour cityscape, drone aerial shot, warm orange and pink sky, downtown skyline silhouette, cinematic"

### 3. Generate via remotion-media

```
Use remotion-media generate_image:
- prompt: [crafted prompt]
- output_name: img-hero
- aspect_ratio: 16:9  # match the composition (9:16 for shorts)
```

The image is saved to `public/` of the directory your agent was launched from, so start your agent (Claude Code, Codex, Gemini CLI…) from the Remotion project root.

### 4. Generate via Replicate MCP (if available)

If the user has `REPLICATE_API_TOKEN` set and wants more model options, use the Replicate MCP tools:

```
# FLUX for high-quality images
replicate_run:
  model: "black-forest-labs/flux-1.1-pro"
  input:
    prompt: "[crafted prompt]"
    aspect_ratio: "16:9"
    output_format: "png"
```

Download the output to the project:
```bash
mkdir -p public/images
curl -L -o public/images/img-[descriptive-name].png "[replicate_output_url]"
```

Available Replicate models:
- **FLUX 1.1 Pro** (`black-forest-labs/flux-1.1-pro`) — High quality, great prompt following
- **Imagen 4** (`google/imagen-4`) — Google's latest, photorealistic
- **Ideogram v3** (`ideogram-ai/ideogram-v3`) — Best for text-in-image
- **FLUX Kontext** (`black-forest-labs/flux-kontext-pro`) — Style control, multi-reference

See `skills/remotion-production/rules/replicate-models.md` and `rules/image-generation.md` for detailed prompt engineering and model selection guidance.

### 5. Show Usage in Remotion

Add the image with `<CanvasImage>` from `remotion`, as the official `remotion-markup` skill does (`<Img>` still works; both accept `effects`). Sizing and animation follow its images.md and timing.md. The path depends on the provider: `generate_image` saves to `public/<output_name>.png`, Replicate downloads to `public/images/`.

```tsx
import { CanvasImage, Easing, interpolate, staticFile, useCurrentFrame, useVideoConfig } from "remotion";

const frame = useCurrentFrame();
const { fps } = useVideoConfig();

// As a background (remotion-media output)
<CanvasImage
  src={staticFile("img-hero.png")}
  style={{ width: "100%", height: "100%", objectFit: "cover" }}
/>

// As an element that pops in (Replicate download)
<CanvasImage
  src={staticFile("images/img-product.png")}
  style={{
    scale: interpolate(frame, [0, 0.6 * fps], [0, 1], {
      extrapolateLeft: "clamp", extrapolateRight: "clamp",
      easing: Easing.spring({ damping: 200 }),
      output: "perceptual-scale",
    }),
  }}
/>
```

For a slow Ken Burns move on a still, see `skills/remotion-production/rules/image-generation.md`.

### 6. Iterate

If the image isn't right:
- Adjust the prompt — be more specific about what's wrong
- Try a different style descriptor
- Generate multiple variations and let the user pick
- Use negative prompts if the model supports them ("no text, no watermark")
