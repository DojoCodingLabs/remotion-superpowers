# Stock Footage Workflow — Pexels Search, Download & Remotion Integration

## Searching for Footage

Use the Pexels MCP to find stock footage:

```
searchVideos:
  query: "drone footage city skyline sunset"
  orientation: "landscape"
  size: "large"
  per_page: 5
```

### Search Tips

- Use **descriptive keywords**: "drone footage beach sunset" not "beach"
- Combine **subject + action + style**: "person typing laptop office"
- Add **cinematic qualifiers**: "slow motion", "time lapse", "aerial", "close up"
- Specify **orientation**: "landscape" for 16:9 video, "portrait" for 9:16 (reels/shorts)

### Good Search Queries by Category

| Category | Example Queries |
|---|---|
| Technology | "person using laptop modern office", "code on screen dark room", "smartphone app scrolling" |
| Nature | "drone forest aerial green", "ocean waves slow motion", "mountain sunrise timelapse" |
| Business | "team meeting conference room", "handshake business deal", "startup office coworking" |
| Lifestyle | "coffee shop morning warm", "jogging park morning light", "cooking kitchen overhead" |
| Abstract | "particles floating dark background", "light leaks film", "bokeh lights night" |

## Downloading Footage

After finding suitable clips, download them to the project:

```bash
# Create footage directory
mkdir -p public/footage

# Download video (use the video file URL from Pexels results)
curl -L -o public/footage/scene-city.mp4 "https://videos.pexels.com/..."
```

For photos:
```bash
mkdir -p public/images
curl -L -o public/images/hero-bg.jpg "https://images.pexels.com/..."
```

## Using Stock Footage in Remotion

### Video Clips

```tsx
import { OffthreadVideo, Sequence, staticFile, useVideoConfig } from "remotion";

export const StockFootageScene: React.FC = () => {
  const { fps } = useVideoConfig();

  return (
    <Sequence from={0} durationInFrames={5 * fps}>
      <OffthreadVideo
        src={staticFile("footage/scene-city.mp4")}
        style={{ width: "100%", height: "100%", objectFit: "cover" }}
      />
    </Sequence>
  );
};
```

### Trimming Video Clips

Play only a specific portion of a stock clip:

```tsx
<OffthreadVideo
  src={staticFile("footage/long-clip.mp4")}
  startFrom={3 * fps}  // Start from 3 seconds into the clip
  endAt={8 * fps}       // End at 8 seconds
  style={{ width: "100%", height: "100%", objectFit: "cover" }}
/>
```

### Overlay Text on Stock Footage

```tsx
import { AbsoluteFill, OffthreadVideo, staticFile } from "remotion";

export const FootageWithText: React.FC = () => {
  return (
    <AbsoluteFill>
      {/* Background footage */}
      <OffthreadVideo
        src={staticFile("footage/city-aerial.mp4")}
        style={{ width: "100%", height: "100%", objectFit: "cover" }}
      />
      
      {/* Dark overlay for text readability */}
      <AbsoluteFill style={{ backgroundColor: "rgba(0,0,0,0.4)" }} />
      
      {/* Text overlay */}
      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <h1 style={{ color: "white", fontSize: 72, fontWeight: "bold" }}>
          Your Text Here
        </h1>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
```

### Stock Photos as Backgrounds

```tsx
import { AbsoluteFill, Img, staticFile } from "remotion";

<AbsoluteFill>
  <Img
    src={staticFile("images/hero-bg.jpg")}
    style={{ width: "100%", height: "100%", objectFit: "cover" }}
  />
</AbsoluteFill>
```

## Pexels Attribution

When using Pexels content, include attribution:
- Show "Photos/Videos provided by Pexels" in the video credits
- Credit individual photographers when possible

## Best Practices

1. **Download to `public/footage/`** — consistent path for all stock clips
2. **Use `OffthreadVideo`** — not `<Video>`, for better rendering performance
3. **Always use `objectFit: "cover"`** — prevents letterboxing/pillarboxing
4. **Add overlays** — dark/gradient overlays make text readable over footage
5. **Trim clips** — stock clips are often longer than needed, use `startFrom`/`endAt`
6. **Match aspect ratios** — search with `orientation: "landscape"` for 16:9 output
