# Video Analysis — Using TwelveLabs to Understand Existing Footage

## Overview

TwelveLabs gives Claude "eyes" to understand video content. Use it when:
- The user has existing footage and wants to use specific clips
- You need to find the right timestamps within a long video
- You want to understand what's in a video before incorporating it

## Workflow

### Step 1: Index the Video

First, create an index and upload the video to TwelveLabs:

```
Use TwelveLabs MCP to:
1. Create a new index (if one doesn't exist)
2. Upload/index the video file
3. Wait for indexing to complete
```

Indexing takes time depending on video length. For a 10-minute video, expect 2-5 minutes.

### Step 2: Analyze Content

Once indexed, query the video:

**Semantic Search** — Find specific moments:
```
"Find the part where the speaker introduces the product"
"Show me all scenes with outdoor footage"
"Find close-up shots of the product"
```

**Scene Detection** — Get a breakdown of all scenes with timestamps:
```
"List all scenes in this video with timestamps and descriptions"
```

**Summarization** — Get a quick overview:
```
"Summarize this video in 3-5 sentences"
```

### Step 3: Extract Useful Clips

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

### Step 4: Use Clips in Remotion

With timestamps identified, use `OffthreadVideo` with `startFrom` and `endAt`:

```tsx
import { OffthreadVideo, Sequence, staticFile, useVideoConfig } from "remotion";

export const EditedVideo: React.FC = () => {
  const { fps } = useVideoConfig();

  return (
    <>
      {/* Speaker intro: 0:15-0:25 of source */}
      <Sequence from={0} durationInFrames={10 * fps}>
        <OffthreadVideo
          src={staticFile("footage/source-video.mp4")}
          startFrom={15 * fps}
          endAt={25 * fps}
          style={{ width: "100%", height: "100%", objectFit: "cover" }}
        />
      </Sequence>

      {/* Product demo: 0:45-1:20 of source */}
      <Sequence from={10 * fps} durationInFrames={35 * fps}>
        <OffthreadVideo
          src={staticFile("footage/source-video.mp4")}
          startFrom={45 * fps}
          endAt={80 * fps}
          style={{ width: "100%", height: "100%", objectFit: "cover" }}
        />
      </Sequence>
    </>
  );
};
```

## Use Cases

### 1. "Use the best parts of this conference recording"
1. Index the full recording with TwelveLabs
2. Search for key moments (product reveals, demos, applause)
3. Extract 5-10 best clips
4. Assemble into a highlight reel with transitions

### 2. "I have footage in `public/raw/` — pick the best shots"
1. List files in `public/raw/`
2. Index each video with TwelveLabs
3. Analyze content of each
4. Recommend which clips to use and at what timestamps
5. Build the composition with the selected clips

### 3. "Match my narration to existing B-roll"
1. Generate voiceover from script
2. Break script into segments
3. For each segment, search indexed footage for matching visuals
4. Assign footage clips to script segments
5. Build composition with synced visuals + audio

## Best Practices

1. **Copy source videos to `public/`** — Remotion needs them accessible via `staticFile()`
2. **Index once, query many times** — TwelveLabs indexes are reusable
3. **Be specific in searches** — "person presenting with slides" beats "presentation"
4. **Verify timestamps** — preview clips before building the full composition
5. **Combine with stock** — fill gaps with Pexels footage if source material is insufficient
