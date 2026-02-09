---
name: analyze-footage
description: Analyze existing video files using TwelveLabs AI. Understand what's in your footage — find specific scenes, detect objects and speakers, get timestamps for the best clips.
---

# Analyze Footage — AI Video Understanding

You are helping the user understand their existing video files using TwelveLabs MCP. This gives Claude "eyes" to see what's in video footage.

**Load the `remotion-production` skill** for the `video-analysis` rule.

## Workflow

### 1. Identify Video Files

Ask the user which video files to analyze, or look for them:

```bash
# Check common locations
ls public/footage/ public/raw/ public/video/ public/ 2>/dev/null | grep -E '\.(mp4|mov|avi|mkv|webm)$'
```

If no files found, ask the user where their footage is located.

### 2. Index with TwelveLabs

For each video file:

```
Use TwelveLabs MCP to:
1. Create an index (or use existing one)
2. Upload/index the video file
3. Wait for indexing to complete
```

Tell the user indexing may take a few minutes for longer videos.

### 3. Analyze Content

Run these analyses and present results:

**Scene Breakdown:**
```
Request: "List all distinct scenes with timestamps and descriptions"
```

Present as:
```
📹 Video Analysis: [filename]

Scenes:
  0:00 - 0:15  │ Logo animation, dark background
  0:15 - 0:45  │ Speaker at podium, introducing topic, conference setting
  0:45 - 1:20  │ Product demo on laptop screen, close-up
  1:20 - 1:45  │ Audience reaction, medium shot, clapping
  1:45 - 2:00  │ Call to action slide, company branding

Key Elements Detected:
  - People: 1 speaker, audience (~30 people)
  - Objects: laptop, projector screen, podium, microphone
  - Text on screen: company logo, product name
  - Setting: conference room, professional lighting
```

### 4. Targeted Search (if user has specific needs)

Ask if they want to find specific moments:

```
Use TwelveLabs semantic search:
- "Find the part where the product is demonstrated"
- "Show me all outdoor scenes"
- "Find close-up shots"
```

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

For each recommended clip, show the Remotion code:

```tsx
<Sequence from={0} durationInFrames={5 * fps}>
  <OffthreadVideo
    src={staticFile("footage/source-video.mp4")}
    startFrom={45 * fps}
    endAt={50 * fps}
    style={{ width: "100%", height: "100%", objectFit: "cover" }}
  />
</Sequence>
```

## Tips

- Ensure video files are in `public/` so Remotion can access them via `staticFile()`
- For very long videos (>30 min), indexing may take 10+ minutes
- TwelveLabs indexes are reusable — index once, search many times
- Combine analyzed footage with stock clips from Pexels to fill gaps
