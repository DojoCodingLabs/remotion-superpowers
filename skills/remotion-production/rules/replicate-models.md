# Replicate Models — AI Image & Video Generation via MCP

## Overview

Replicate hosts thousands of image and video models. This plugin reaches them through the local `replicate-mcp@0.9.0` server, which needs `REPLICATE_API_TOKEN` in the environment. Call the MCP tools rather than hand-writing `curl` requests to the API, so the token never appears in a shell command. (The hosted server at `mcp.replicate.com` is a documented alternative; it uses an OAuth browser login and ignores the token.)

**Layer on Replicate's official skills.** Model discovery, comparison, running and prompting are theirs: `find-models`, `compare-models`, `run-models`, `prompt-images` and `prompt-videos` (`npx skills add replicate/skills`). This file adds only the Remotion layer: which MCP calls to make, where the files land, and how outputs fit a composition.

## The Rule: Search + Read the Schema First

Models and their schemas change every few weeks. Never call a model from memory, including the shortlist below.

1. **Search**: `search_models` with `body: "<task>"` (e.g. `"text to video"`, `"image editing multi reference"`). Prefer official models and recent releases, as `find-models` explains.
2. **Read the schema**: `get_models` with `model_owner` and `model_name`. The inputs are at `latest_version.openapi_schema.components.schemas.Input.properties` (types, enums, min/max, defaults). `list_models_examples` shows inputs that are known to work; `get_models_readme` has the author's notes.
3. **Use only inputs that exist in that schema.** Leave optional inputs at their defaults unless you have a reason, as `run-models` says.

Clients prefix MCP tool names differently (for example `mcp__replicate__get_predictions`); the operation names below are what matter.

## Running a Model

```
# Official models (owner/name, always warm)
create_models_predictions:
  model_owner: "<owner>"
  model_name: "<name>"
  input: { prompt: "...", aspect_ratio: "16:9" }   # keys from the schema you just read

# Community models (need a pinned version from get_models → latest_version.id)
create_predictions:
  version: "<owner>/<name>:<version_id>"
  input: { ... }
```

Then poll:

1. Keep the `id` from the create response.
2. Call `get_predictions` with `prediction_id: "<id>"` until `status` is terminal: `succeeded`, `failed` or `canceled` (it passes through `starting` and `processing`). Images take seconds; video takes minutes, so poll every 10–20 s. Use `cancel_predictions` to stop a job you no longer need.
3. On `failed`, read the prediction's `error` and `logs`, fix the input against the schema and retry once before switching models.
4. On `succeeded`, the `output` field holds a URL or an array of URLs. Download it right away (URLs expire after 1 hour):

```bash
mkdir -p public/images public/footage
curl -L -o public/images/img-hero.png "<output URL>"
curl -L -o public/footage/clip-city.mp4 "<output URL>"
```

- `Prefer: "wait"` on the create call blocks for up to 60 s. Use it only for fast image models, never for video.
- Start independent predictions in parallel (one per scene), then poll them together.
- `download_files` is for files in Replicate's Files API (ones uploaded with `create_files`), not for prediction outputs. Outputs are plain delivery URLs: `curl -L` them.
- Image inputs (a still to animate, a reference) must be URLs or small data URLs. A previous prediction's output URL works directly while it's valid, which is the easiest way to chain image-to-video.

## Shortlist (as of Oct 2026, verify before use)

Starting points for `search_models`, not a catalog. Confirm each one exists and read its schema before calling.

| Need | Model (as of Oct 2026) | Inputs worth knowing (check the schema) |
|---|---|---|
| Photoreal or general image, multi-reference | FLUX.2 Pro / Max (`black-forest-labs/flux-2-pro`, `black-forest-labs/flux-2-max`) | `input_images[]` for several references |
| Image with text, image editing | Nano Banana Pro (`google/nano-banana-pro`) | Same family as KIE's default |
| OpenAI image | GPT Image 2 (`openai/gpt-image-2`) | |
| Typography, logos | Ideogram v3 Quality / Turbo (owner `ideogram-ai`; `search_models` with `body: "ideogram"` for the exact tier ID) | There is no bare v3 ID: pick the Quality, Balanced or Turbo tier |
| Edit from a single reference | FLUX Kontext Pro (`black-forest-labs/flux-kontext-pro`) | One `input_image` only; use FLUX.2 for multi-reference |
| Image-to-video, cinematic | Kling v3 (`kwaivgi/kling-v3-video`) | `start_image`, `end_image`, `mode`, `generate_audio` |
| Text/image-to-video with references | Seedance 2 (`bytedance/seedance-2.0`) | `image`, `last_frame_image`, `reference_images` |
| Open-weights video | Wan 2.7 (`wan-video/wan-2.7-t2v`, `wan-video/wan-2.7-i2v`) | First/last-frame inputs; length is set by the schema's duration input, not a frame count |

Avoid Sora 2 (OpenAI shut the API down on 2026-09-24) and Imagen 4 (legacy; Google names Nano Banana as its replacement).

## When to Use Replicate vs remotion-media (KIE)

KIE via remotion-media stays the default for images and clips: one call, and the file lands in `public/`.

| Scenario | Use | Why |
|---|---|---|
| Quick image | remotion-media `generate_image` | Simplest, auto-saves |
| Quick clip | remotion-media `generate_video_from_text` | Veo 3.1, auto-saves |
| Animate a still | remotion-media `generate_video_from_image`, or Replicate (Kling v3, Seedance 2, Wan 2.7) for model choice | `image_urls` must be public URLs |
| **A KIE video call fails** | Replicate (Kling v3, Seedance 2, Wan 2.7) | KIE's Veo depends on a Google preview that is being shut down |
| Typography or logos | Replicate (Ideogram v3) | Specialized |
| Several reference images | Replicate (FLUX.2) | Multi-reference input |
| Exact duration, 1080p or a last frame | Replicate (read the schema) | KIE's Veo is fixed at ~8 s, 720p |

## Output Handling in Remotion

Reference downloads with `staticFile()` and the path relative to `public/`:

```tsx
import { Video } from "@remotion/media";
import { Img, staticFile } from "remotion";

<Img src={staticFile("images/img-hero.png")} />
<Video src={staticFile("footage/clip-city.mp4")} />
```

`<Video>` comes from `@remotion/media` (`npx remotion add @remotion/media`); sizing, trimming and effects follow the official `remotion-markup` skill (embedding-videos.md, images.md).

## Best Practices

1. **Search and read the schema first**, every time; the shortlist is only a starting point
2. **Match the composition**: pass the schema's aspect-ratio or size input that matches the composition (16:9 for 1920x1080, 9:16 for 1080x1920)
3. **Start with fast tiers** for iteration, switch to pro/quality tiers for finals (see `compare-models`)
4. **Download outputs immediately**: URLs expire after 1 hour
5. **Use typed filenames**: `img-hero.png`, `clip-city.mp4`, not `output.png`
6. **Prefer remotion-media for simple tasks**: less setup, auto-saves to `public/`
7. **Never `Prefer: "wait"` for video**: create, then poll `get_predictions`
