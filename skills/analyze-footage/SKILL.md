---
name: analyze-footage
description: Analyze existing video files with TwelveLabs AI. Get a timestamped scene map of your footage, ask questions about it, find specific moments across a library, and get the best clips with timestamps for Remotion.
---

# Analyze Footage — AI Video Understanding

You are helping the user understand their existing video files using TwelveLabs MCP. This gives your agent "eyes" to see what's in video footage.

**Load the `remotion-production` skill** for the `video-analysis` rule.

## Workflow

### 1. Identify Video Files

Ask the user which video files to analyze, or look for them:

```bash
# Check common locations
ls public/footage/ public/raw/ public/video/ public/ 2>/dev/null | grep -E '\.(mp4|mov|avi|mkv|webm)$'
```

If no files found, ask the user where their footage is located.

### 2. Upload to TwelveLabs

For each video file, upload it as an asset (no index needed for analysis):

```
create-asset:
  file: [absolute path, e.g. /path/to/project/public/footage/source-video.mp4]
```

Keep the returned asset ID. If the next call says the asset isn't ready yet, wait a few seconds and retry.

### 3. Analyze Content

**Scene Breakdown** — a timestamped scene map, as the `video-analysis` rule shows:
```
async-analyse-video:
  assetId: [asset ID]
  modelName: "pegasus1.5"
  analysisMode: "time_based_metadata"
  segmentDefinitions: [one "shots" definition with fields: description, shot_type, people, on_screen_text, usable]
```

Poll `get-analyse-task` every 5-10 seconds until it's `ready`, then parse `result.data` (a JSON string keyed by the segment definition `id`). Videos up to 2 hours work.

For a direct question ("which shots show the product?", "pick clips for a 30s promo"), use `sync-analyse-video` (`assetId`, `modelName: "pegasus1.5"`, `prompt`, and a `jsonSchema` so you get start/end times back as numbers). Sync analysis is capped at 1 hour of video.

Always pass `modelName: "pegasus1.5"`: the server's default model has been removed from the API.

Present as:
```
📹 Video Analysis: [filename]

Scenes:
  0:00 - 0:15  │ Logo animation, dark background
  0:15 - 0:45  │ Speaker at podium, introducing topic, conference setting
  0:45 - 1:20  │ Product demo on laptop screen, close-up
  1:20 - 1:45  │ Audience reaction, medium shot, clapping
  1:45 - 2:00  │ Call to action slide, company branding

Key Elements (from the segment fields):
  - People: 1 speaker, audience (~30 people)
  - Shot types: wide, medium, close-up, screen capture
  - Text on screen: company logo, product name
  - Setting: conference room, professional lighting
```

When the results are saved (e.g. to `analysis/[filename].json`), clean up with `delete-asset` (`assetId`). Assets count against the account's storage.

### 4. Targeted Search (if user has specific needs)

For one file, ask `sync-analyse-video` directly (optionally clipped with `startTime`/`endTime`). To find moments across a library of videos, index it once and search:

```
start-video-indexing-task:
  folderFilePath: [absolute path to the footage folder]   (or videoFilePath for one file)
→ poll get-indexed-asset until ready
search:
  query: "the part where the product is demonstrated"
```

`search` returns ranked segments with start/end times and thumbnails; it doesn't describe them. Analyse a hit if you need to know more.

### 5. Recommend Clips

Based on the analysis, recommend the best clips for the user's video:

```
🎬 Recommended Clips for a 30-second promo:

1. Opening (0:00-0:05)
   → Use 0:45-0:50 of source — product demo close-up, high energy
   
2. Main content (0:05-0:20)  
   → Use 0:50-1:05 of source — full demo walkthrough
   
3. Social proof (0:20-0:25)
   → Use 1:20-1:25 of source — audience clapping
   
4. CTA (0:25-0:30)
   → Use 1:45-1:50 of source — branded slide
```

### 6. Show Usage in Remotion

For each recommended clip, show the Remotion code. A source range becomes `trimBefore` (the start timestamp) plus `durationInFrames` (the clip length) on `<Video>` from `@remotion/media`. Cut the clips together with `TransitionSeries` or a `Track` as the official `remotion-markup` skill shows (video-editing.md); `skills/remotion-production/rules/video-analysis.md` has a full example.

```tsx
import { Video } from "@remotion/media";
import { staticFile, useVideoConfig } from "remotion";

const { fps } = useVideoConfig();

// Opening (0:00-0:05) ← source 0:45-0:50
<Video
  name="Opening"
  src={staticFile("footage/source-video.mp4")}
  trimBefore={45 * fps}
  durationInFrames={5 * fps}
  objectFit="cover"
  style={{ width: "100%", height: "100%" }}
/>
```

Round fractional TwelveLabs timestamps to whole frames: `Math.round(45.6 * fps)`.

## Tips

- Ensure video files are in `public/` (ideally `public/footage/`) so Remotion can access them via `staticFile()` with the path relative to `public/`; pass the absolute path of the same file to `create-asset`
- Limits: sync analysis up to 1 hour, async up to 2 hours, direct uploads up to 4 GB
- Index only for `search`; an index is reusable across many searches, an asset is per analysis (delete it afterwards)
- For anything else, see the official docs: https://docs.twelvelabs.io (and `llms.txt`)
- Combine analyzed footage with stock clips from Pexels to fill gaps
