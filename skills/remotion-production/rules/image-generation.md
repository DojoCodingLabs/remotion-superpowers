# Image Generation — AI Image Prompting & Workflow

## Overview

Generate custom images for Remotion projects. **KIE via remotion-media is the default**; Replicate covers specific models and KIE failures. Prompt-writing technique comes from Replicate's official `prompt-images` skill (model-agnostic, so it applies to KIE prompts too). This file keeps what's specific to video: provider choice, frame sizes, and consistency across scenes.

## Provider Decision Matrix

| Need | Provider | Model (as of Oct 2026) | Why |
|---|---|---|---|
| Background, thumbnail, most stills | remotion-media `generate_image` | Nano Banana Pro | Simplest, auto-saves to `public/` |
| Photoreal or several reference images | Replicate | FLUX.2 Pro / Max | `input_images[]` multi-reference |
| Text in image (logos, titles) | Replicate | Ideogram v3 Quality / Turbo | Typography specialist |
| Edit from one reference | Replicate | FLUX Kontext Pro | Takes a single `input_image` |
| Real-world scene | Pexels MCP | N/A (real photos) | Free, instant, no generation |

For Replicate, search with `search_models` and read the model's input schema (`get_models` / `list_models_examples`) before calling; see `replicate-models.md`.

### remotion-media call

```
generate_image:
  prompt: "<prompt>"
  output_name: "img-hero"      # saved as public/img-hero.png
  aspect_ratio: "16:9"         # the default is 1:1, so always pass it
  resolution: "2K"             # default 1K; use 2K+ for 1080p compositions
  image_urls: ["https://..."]  # optional style/subject references, up to 8, public URLs only
```

`image_urls` must be public URLs KIE can fetch, not files in `public/`. The `imageUrl` that `generate_image` returns is hosted by KIE and deleted after 14 days, so reuse it soon or re-host it.

## Prompt Engineering

Follow the official `prompt-images` skill for technique: full sentences rather than keyword lists, named subjects, photographic and lighting vocabulary, text rendering, editing. What we add:

### Prompt Anatomy

Cover these components, in this order, written as natural sentences:

```
[Subject] + [Style] + [Lighting] + [Camera/Angle] + [Color Palette] + [Modifiers]
```

**Example:** "A modern glass office building seen from a low angle, photographed at golden hour with warm light on the facade. Blue sky and orange reflections, architectural photography, sharp detail."

### Video-specific additions

- **Leave room for overlays.** If Remotion will put a title or captions on the image, ask for it: "clear negative space in the lower third" or "subject on the right, empty left half".
- **Let Remotion render the text.** Ask for "no text, no watermark, no logo" (where the model supports exclusions) and add titles in Remotion, where they stay sharp and editable. Only generate in-image text when it's part of the scene (a sign, a label), and use a typography model for it.
- **Ken Burns needs margin.** Stills that will zoom or drift should have the subject away from the edges; the move crops 5–20%.

### Consistency across scenes

A video is a set of images that must look like one piece:

- Write one **style block** (style, lighting, palette, lens) and paste it verbatim at the end of every scene's prompt. Change only the subject and action.
- For a recurring character or product, repeat the same description word for word, and pass the first good image as a reference (`image_urls` on KIE, the schema's reference input on Replicate).
- Keep one provider and one model for the whole video; mixing models changes the look.
- Generate all scenes before building, then line them up in Studio and regenerate the outlier.

## Aspect Ratios for Remotion

| Format | Aspect Ratio | Dimensions | Use Case |
|---|---|---|---|
| Landscape (default) | 16:9 | 1920x1080 | YouTube, presentations |
| Portrait | 9:16 | 1080x1920 | TikTok, Reels, Shorts |
| Square | 1:1 | 1080x1080 | Instagram, thumbnails |
| Ultra-wide | 21:9 | 2560x1080 | Cinematic letterbox |

Always match the image aspect ratio to your Remotion composition's dimensions. On Replicate, the aspect-ratio or size input name differs per model, so take it from the schema.

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
- **Replicate** (the prediction's `output` URL, after `get_predictions` reports `succeeded`) and **Pexels** return URLs. Download them yourself: `mkdir -p public/images && curl -L -o public/images/img-hero.png "<url>"`, then `staticFile("images/img-hero.png")`. Replicate URLs expire after 1 hour.

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
7. **Keep one style block across scenes** — consistency beats individually perfect images
8. **Add Ken Burns to still images** — subtle motion makes stills feel cinematic in video
