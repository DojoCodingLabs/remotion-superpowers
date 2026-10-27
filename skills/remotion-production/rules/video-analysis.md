# Video Analysis — Using TwelveLabs to Understand Existing Footage

## Overview

TwelveLabs gives Claude "eyes" to understand video content. Use it when:
- The user has existing footage and wants to use specific clips
- You need to find the right timestamps within a long video
- You want to understand what's in a video before incorporating it
- You're reviewing a render (the `review-video` skill, which holds the review rubric)

The server is the official `twelvelabs-mcp` 1.0.0. It has two separate jobs, with separate tools:

| Job | Tools | Index needed? |
|---|---|---|
| **Analyse** a file: scene map, clip picks, Q&A, review | `create-asset` → `sync-analyse-video` or `async-analyse-video` → `delete-asset` | No |
| **Find the moment** ("the part where…") across a library | `start-video-indexing-task` → `search` | Yes |

`search` only returns ranked segments (start, end, thumbnail); it can't describe, answer or judge. Always analyse with the analyse tools.

**Always pass `modelName: "pegasus1.5"`.** On 1.0.0, `sync-analyse-video` falls back to an older model the API no longer accepts, and `videoId` inputs only work with that old model, so use `assetId` (or a direct `videoUrl`) instead. For anything not covered here, see the official docs: https://docs.twelvelabs.io (agent-friendly index: https://docs.twelvelabs.io/llms.txt).

## Workflow

### Step 1: Upload the File as an Asset

```
create-asset:
  file: "/absolute/path/to/project/public/footage/source-video.mp4"
```

Use an absolute path (or `url` for a public direct link). Keep the returned asset ID. The asset must be ready before you analyse it; if the analyse call rejects it as still processing, wait a few seconds and retry. Direct uploads go up to 4 GB.

### Step 2: Analyse

Pick the call by length and output:

| Call | Use for | Limits |
|---|---|---|
| `sync-analyse-video` | Videos up to 1 h; answer returned inline | `prompt` up to 2000 tokens; optional `jsonSchema`, `startTime`/`endTime` (window ≥ 4 s) |
| `async-analyse-video` | Up to 2 h, or a timestamped scene map (`analysisMode: "time_based_metadata"`) | Returns a task ID; poll `get-analyse-task` every 5-10 s until `ready` or `failed` |

**Scene map** (what's in the footage, shot by shot):
```
async-analyse-video:
  assetId: "<asset id>"
  modelName: "pegasus1.5"
  analysisMode: "time_based_metadata"
  minSegmentDuration: 2
  segmentDefinitions:
    - id: "shots"
      description: "Each distinct shot or scene in the video"
      fields:
        - { name: "description", type: "string", description: "What is on screen and what happens" }
        - { name: "shot_type", type: "string", description: "Framing", enum: ["wide", "medium", "close-up", "aerial", "screen-capture", "graphic"] }
        - { name: "people", type: "integer", description: "Number of visible people" }
        - { name: "on_screen_text", type: "string", description: "Readable on-screen text, empty if none" }
        - { name: "usable", type: "boolean", description: "Steady, well exposed and in focus" }
```

In this mode you can't also pass `prompt` or `jsonSchema`. When the task is `ready`, `result.data` is a JSON string keyed by segment definition `id` (`"shots"` here); parse it yourself. Each segment carries its time range plus your fields.

**Direct question with structured output** (clip picks, "is there a logo in the first 5 s?"):
```
sync-analyse-video:
  assetId: "<asset id>"
  modelName: "pegasus1.5"
  prompt: "Pick the 3-5 strongest clips for a 30-second product promo: the demo, one speaker moment, the closing slide. Prefer steady, well-lit shots."
  jsonSchema:
    type: object
    properties:
      clips:
        type: array
        items:
          type: object
          properties:
            start: { type: number, description: "seconds" }
            end: { type: number, description: "seconds" }
            role: { type: string, enum: ["opening", "main", "social-proof", "cta"] }
            reason: { type: string }
          required: [start, end, role, reason]
    required: [clips]
```

A `jsonSchema` makes the answer machine-readable, so the timestamps go straight into `trimBefore`/`durationInFrames` without re-parsing prose.

### Step 3: Clean Up

```
delete-asset:
  assetId: "<asset id>"
```

Delete each asset once its results are saved (write them to a file such as `analysis/source-video.json` if you'll need them again). Assets count against account storage (3 GB on the Free plan), and every review uploads a new one. `delete-analyse-task` removes finished async tasks if you want a tidy account.

### Step 4: Extract Useful Clips

Based on the analysis, identify the best clips:

```
Analysis Result:
  0:00 - 0:15  → Logo animation intro
  0:15 - 0:45  → Speaker at podium, introducing topic
  0:45 - 1:20  → Product demo on screen
  1:20 - 1:45  → Audience reaction shots
  1:45 - 2:00  → Call to action slide

Recommended clips for a 30-second promo:
  - 0:45-1:20 (product demo) → Main content
  - 0:15-0:25 (speaker intro) → Opening
  - 1:45-2:00 (CTA) → Closing
```

### Step 5: Use Clips in Remotion

Turn each recommended range into a clip: `trimBefore` is the start timestamp and `durationInFrames` is the clip length, both in frames. Place them with `<Video>` from `@remotion/media` on a `TransitionSeries` (adjacent cuts) or a named `Track` (independent start times), following the official `remotion-markup` skill (video-editing.md, timing-props.md).

```tsx
import { Video } from "@remotion/media";
import { TransitionSeries } from "@remotion/transitions";
import { staticFile, useVideoConfig } from "remotion";

export const EditedVideo: React.FC = () => {
  const { fps } = useVideoConfig();

  return (
    <TransitionSeries name="Promo cuts">
      {/* Speaker intro: 0:15-0:25 of source */}
      <TransitionSeries.Sequence name="Speaker intro" trimBefore={15 * fps} durationInFrames={10 * fps}>
        <Video name="Speaker footage" src={staticFile("footage/source-video.mp4")} objectFit="cover" />
      </TransitionSeries.Sequence>

      {/* Product demo: 0:45-1:20 of source */}
      <TransitionSeries.Sequence name="Product demo" trimBefore={45 * fps} durationInFrames={35 * fps}>
        <Video name="Demo footage" src={staticFile("footage/source-video.mp4")} objectFit="cover" />
      </TransitionSeries.Sequence>
    </TransitionSeries>
  );
};
```

TwelveLabs timestamps are often fractional seconds. Convert them with `Math.round(12.4 * fps)` so every timing prop is an integer frame count.

## Finding Moments in a Library (search)

Only when the user has several videos and wants "every shot where…" across them:

1. `start-video-indexing-task` with `videoFilePath` (one file) or `folderFilePath` (every video in a folder), both absolute. Leave `indexId` out to use the default index, which uses the search model.
2. Poll `get-indexed-asset` (`indexId` from `list-indexes`, `indexedAssetId` = the task ID returned in step 1) until the status is `ready`.
3. `search` with a `query` ("person presenting with slides", "close-up of the product"); add `indexId` to search a specific index. You can also search by image with `queryMediaFile` (absolute path) and `queryMediaType: "image"`.
4. Results give the filename, `videoId`, start/end and a thumbnail link per segment (links expire after an hour). To describe or judge a hit, analyse that file as above, clipped to the hit with `startTime`/`endTime`.

Indexing is reusable: index a library once, search it many times. Don't index a file just to analyse it.

## Use Cases

### 1. "Use the best parts of this conference recording"
1. `create-asset` the recording, then `async-analyse-video` with a scene map (it handles up to 2 h)
2. Pick the key moments (product reveals, demos, applause) from the segment fields, or ask `sync-analyse-video` with a clip-picker `jsonSchema` (recordings up to 1 h)
3. `delete-asset`
4. Assemble 5-10 clips into a highlight reel with transitions

### 2. "I have footage in `public/raw/` — pick the best shots"
1. List files in `public/raw/`
2. `create-asset` each video and run a scene map on each
3. Recommend which clips to use and at what timestamps
4. `delete-asset` each one, then build the composition with the selected clips

### 3. "Match my narration to existing B-roll"
1. Generate the voiceover from the script (per scene, see `voiceover-sync.md`)
2. Break the script into segments
3. Index the B-roll folder once (`start-video-indexing-task` with `folderFilePath`), then `search` per script segment for matching visuals
4. Assign footage clips to script segments
5. Build composition with synced visuals + audio

## Best Practices

1. **Copy source videos to `public/footage/`** — Remotion needs them accessible via `staticFile("footage/<name>.mp4")`, and `create-asset` needs the absolute path to the same file
2. **Analyse without indexing** — `create-asset` plus an analyse call; index only for `search`
3. **Ask for JSON** — a `jsonSchema` (sync or async general mode) or `segmentDefinitions` (scene maps) beats parsing prose
4. **Clean up** — `delete-asset` after every analysis or review
5. **Be specific in prompts and searches** — "person presenting with slides" beats "presentation"
6. **Verify timestamps** — preview clips in Studio before building the full composition
7. **Combine with stock** — fill gaps with Pexels footage if source material is insufficient
