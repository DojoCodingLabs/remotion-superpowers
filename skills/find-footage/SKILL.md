---
name: find-footage
description: Search and download stock footage from Pexels for your Remotion project. Provide a description of what you need and this will find, preview, and download matching clips.
---

# Find Footage — Stock Video & Photo Search

You are helping the user find stock footage for their Remotion project using the Pexels MCP.

**Load the `remotion-production` skill** for the `stock-footage-workflow` rule.

## Workflow

### 1. Understand the Need

Ask the user what they're looking for if not already clear. Get:
- **Subject** — What should be in the footage? (people, nature, tech, food, etc.)
- **Style** — Cinematic, aerial/drone, close-up, time-lapse, slow motion?
- **Orientation** — Landscape (16:9), portrait (9:16), or square (1:1)?
- **Mood** — Bright, dark, warm, cool, energetic, calm?

### 2. Search Pexels

Craft a descriptive search query and run:

```
Use Pexels videos_search:
- query: [descriptive keywords — be specific]
- orientation: [landscape/portrait/square]
- size: large
- per_page: 5
```

For photos:
```
Use Pexels photos_search:
- query: [descriptive keywords]
- orientation: [landscape/portrait/square]
- size: large
- per_page: 5
```

### 3. Present Results

Show the user the results with:
- Thumbnail/preview URL
- Duration (for videos)
- Resolution
- Photographer credit

Ask which ones they want to download.

### 4. Download Selected Assets

The Pexels MCP has no download tool. Get the file URL with `video_get` (or from the search result's `video_files`, picking the `hd` entry closest to the composition size), then:

```bash
mkdir -p public/footage  # or public/images for photos

# Download each selected clip
curl -L -o public/footage/[descriptive-name].mp4 "[video_url]"
```

### 5. Show Usage

After downloading, show how to use the clip in Remotion. `<Video>` comes from `@remotion/media` (`npx remotion add @remotion/media`); trimming, volume and effects follow the official `remotion-markup` skill (embedding-videos.md).

```tsx
import { Video } from "@remotion/media";
import { staticFile } from "remotion";

<Video
  src={staticFile("footage/[descriptive-name].mp4")}
  muted
  objectFit="cover"
  style={{ width: "100%", height: "100%" }}
/>
```

### 6. Attribution Reminder

Remind the user:
> Pexels doesn't require attribution, but it's appreciated.
> Consider adding "Videos provided by Pexels" and the creator's name to your video credits or description.
