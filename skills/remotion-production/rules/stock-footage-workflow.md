# Stock Footage Workflow — Pexels Search, Download & Remotion Integration

## Searching for Footage

Use the Pexels MCP to find stock footage:

```
videos_search:
  query: "drone footage city skyline sunset"
  orientation: "landscape"
  size: "large"
  per_page: "5"
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

The Pexels MCP has no download tool. Take the file URL from `video_get` (or the search result's `video_files`; pick the `hd` entry closest to your composition size) and download it into the project:

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

Place clips with `<Video>` from `@remotion/media` (install with `npx remotion add @remotion/media`) and photos with `<Img>` or `<CanvasImage>`, following the official `remotion-markup` skill (embedding-videos.md, images.md). Trim with `trimBefore` plus `durationInFrames` (timing-props.md). The one thing to get right on our side is the path: `staticFile()` takes the path relative to `public/`, exactly where `curl` saved it.

```tsx
import { Video } from "@remotion/media";
import { AbsoluteFill, staticFile, useVideoConfig } from "remotion";

export const FootageWithText: React.FC = () => {
  const { fps } = useVideoConfig();

  return (
    <AbsoluteFill>
      {/* Stock clips are long: play seconds 3-8, muted under the voiceover */}
      <Video
        src={staticFile("footage/scene-city.mp4")}
        trimBefore={3 * fps}
        durationInFrames={5 * fps}
        muted
        objectFit="cover"
        style={{ width: "100%", height: "100%" }}
      />

      {/* Dark overlay for text readability */}
      <AbsoluteFill style={{ backgroundColor: "rgba(0,0,0,0.4)" }} />

      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <h1 style={{ color: "white", fontSize: 72, fontWeight: "bold" }}>Your Text Here</h1>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
```

For a cinematic grade or vignette on the footage, use the official effects on the `<Video>` (see `visual-effects.md`).

## Pexels Attribution

Pexels doesn't require attribution, but it's appreciated:
- Add "Photos/Videos provided by Pexels" to the video credits or description
- Credit individual photographers by name when possible (`user.name` on a video result, `photographer` on a photo result)

## Best Practices

1. **Download to `public/footage/`** (videos) and `public/images/` (photos), after `mkdir -p`
2. **Use `<Video>` from `@remotion/media`** — not the older video components from `remotion`
3. **Cover the frame** — `objectFit="cover"` prevents letterboxing/pillarboxing
4. **Add overlays** — dark/gradient overlays make text readable over footage
5. **Trim clips** — stock clips are often longer than needed; use `trimBefore` plus `durationInFrames`
6. **Mute stock audio** — `muted` unless the clip's own sound is wanted
7. **Match aspect ratios** — search with `orientation: "landscape"` for 16:9 output, `"portrait"` for 9:16
