# CI/CD Rendering — GitHub Actions for Remotion

## Overview

Automate video rendering with GitHub Actions. Render on push, on PR, or manually via workflow dispatch. The rendered video is uploaded as a downloadable artifact.

Set this up only when the user asks for automated renders: day-to-day work previews in Studio, and an MP4 is rendered only on request. The `npx remotion render` / `npx remotion still` commands and flags follow the official `remotion-render` skill (full option list: https://www.remotion.dev/docs/cli/render.md). Remotion's own GitHub Actions notes: https://www.remotion.dev/docs/ssr.md#render-using-github-actions.

**Rendering from an app instead of CI** (AWS Lambda, Vercel Sandbox, a Node render server): follow the official `remotion-saas` skill (rendering.md). It covers the Lambda setup checklist and the SSR trade-offs.

## Basic GitHub Actions Workflow

Create `.github/workflows/render.yml`:

```yaml
name: Render Video

on:
  workflow_dispatch:
    inputs:
      composition:
        description: "Composition ID to render"
        required: true
        default: "MyVideo"
      codec:
        description: "Video codec"
        required: false
        default: "h264"

jobs:
  render:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: "20"

      - name: Install dependencies
        run: npm ci

      - name: Render video
        # Pass inputs through env, not inline ${{ }}, so they can't inject shell
        env:
          COMPOSITION: ${{ github.event.inputs.composition }}
          CODEC: ${{ github.event.inputs.codec }}
        run: |
          npx remotion render "$COMPOSITION" \
            out/video.mp4 \
            --codec "$CODEC" \
            --crf 18

      - name: Upload rendered video
        uses: actions/upload-artifact@v4
        with:
          name: rendered-video
          path: out/video.mp4
          retention-days: 30
```

## Auto-Render on PR

Add this trigger to render automatically when a PR changes video code:

```yaml
on:
  pull_request:
    paths:
      - "src/**"
      - "public/**"

jobs:
  render:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
      - run: npm ci
      - run: npx remotion render MyVideo out/video.mp4 --crf 22
      - uses: actions/upload-artifact@v4
        with:
          name: pr-video-preview
          path: out/video.mp4
```

## Spot-Check Frames (cheap PR check)

Rendering a few frames as PNGs is much faster than a full MP4 and is often enough to review a layout change:

```yaml
- run: npx remotion render MyVideo out/frames --frames=0,30,90 --image-format=png
- uses: actions/upload-artifact@v4
  with:
    name: pr-frames
    path: out/frames
```

## Render with API Keys (secrets)

If your video uses MCP-generated assets that are checked into `public/` in git, no secrets are needed for CI rendering. Rendering never calls the MCP tools, so commit the generated files. If you need to generate assets in CI:

```yaml
env:
  KIE_API_KEY: ${{ secrets.KIE_API_KEY }}
  PEXELS_API_KEY: ${{ secrets.PEXELS_API_KEY }}
```

Add these as GitHub repository secrets in Settings → Secrets → Actions. Never echo them in a step or commit them to `.env`.

## Render Multiple Compositions

```yaml
strategy:
  matrix:
    composition: [MyVideo, Intro, Outro, Short]

steps:
  - run: npx remotion render ${{ matrix.composition }} out/${{ matrix.composition }}.mp4
  - uses: actions/upload-artifact@v4
    with:
      name: video-${{ matrix.composition }}
      path: out/${{ matrix.composition }}.mp4
```

## Render a Still Frame (thumbnail)

```yaml
- name: Render thumbnail
  run: npx remotion still MyVideo out/thumbnail.png --frame 0
- uses: actions/upload-artifact@v4
  with:
    name: thumbnail
    path: out/thumbnail.png
```

## Performance Tips

- **Use `ubuntu-latest`** — Best cost/performance for video rendering
- **CRF 22** for previews — Faster, smaller files for PR checks
- **CRF 18** for final renders — Higher quality for production
- **Cache node_modules** — Add `actions/cache` for faster installs
- **Matrix builds** — Render compositions in parallel for faster CI
- **WebGL effects** — If the video uses `@remotion/effects` (light leaks, vignette, color correction), keep `Config.setChromiumOpenGlRenderer("angle")` in `remotion.config.ts`; the CLI render in CI reads it too

## Cost Warning

GitHub Actions free tier includes 2,000 minutes/month. A 30-second video typically renders in 1-3 minutes depending on complexity. Be mindful of render triggers — avoid rendering on every push.

**Recommended:** Use `workflow_dispatch` (manual trigger) for production renders, and PR-triggered renders only for critical review paths.
