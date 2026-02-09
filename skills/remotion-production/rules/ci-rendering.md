# CI/CD Rendering — GitHub Actions for Remotion

## Overview

Automate video rendering with GitHub Actions. Render on push, on PR, or manually via workflow dispatch. The rendered video is uploaded as a downloadable artifact.

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
        run: |
          npx remotion render ${{ github.event.inputs.composition }} \
            out/video.mp4 \
            --codec ${{ github.event.inputs.codec }} \
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

## Render with API Keys (secrets)

If your video uses MCP-generated assets that are checked into git, no secrets are needed for CI rendering. If you need to generate assets in CI:

```yaml
env:
  KIE_API_KEY: ${{ secrets.KIE_API_KEY }}
  PEXELS_API_KEY: ${{ secrets.PEXELS_API_KEY }}
```

Add these as GitHub repository secrets in Settings → Secrets → Actions.

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

## Cost Warning

GitHub Actions free tier includes 2,000 minutes/month. A 30-second video typically renders in 1-3 minutes depending on complexity. Be mindful of render triggers — avoid rendering on every push.

**Recommended:** Use `workflow_dispatch` (manual trigger) for production renders, and PR-triggered renders only for critical review paths.
