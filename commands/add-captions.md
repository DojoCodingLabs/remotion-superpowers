---
name: add-captions
description: Generate TikTok-style animated captions for your Remotion video. Transcribes audio with Whisper, then creates word-by-word animated subtitles with customizable position, colors, and style.
---

# Add Captions — TikTok-Style Animated Subtitles

You are helping the user add animated word-by-word captions to their Remotion video.

**Load the `remotion-production` skill** for the `captions-workflow` rule.

## Workflow

### 1. Identify the Audio Source

Find the voiceover or primary audio file:

```bash
# Check for existing audio files
ls public/audio/ public/ 2>/dev/null | grep -E '\.(mp3|wav|m4a|ogg)$'
```

If no audio exists, suggest running `/add-voiceover` first.

### 2. Transcribe with Whisper

Generate word-level timestamps:

```
Use remotion-media generate_subtitles:
- input: [path to audio file]
- project_path: [project root path]
```

This returns an SRT file with timestamps. Save to `public/captions/`.

### 3. Install Captions Package

Ensure `@remotion/captions` is installed:

```bash
npx remotion add @remotion/captions
```

### 4. Choose Caption Style

Ask the user what style they want:

- **TikTok style** (default) — Bold, centered, one word at a time, colored highlight
- **YouTube style** — Bottom of screen, sentence at a time
- **Karaoke style** — Words highlight as they're spoken
- **Minimal** — Small, subtle, bottom-left

### 5. Create the Captions Component

```tsx
import { useCurrentFrame, useVideoConfig } from "remotion";
import { createTikTokStyleCaptions } from "@remotion/captions";

// Parse the transcription into Remotion Caption objects
// Apply createTikTokStyleCaptions() for word-by-word timing

export const Captions: React.FC<{ captions: Caption[] }> = ({ captions }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const currentTimeMs = (frame / fps) * 1000;

  const { pages } = createTikTokStyleCaptions({
    captions,
    combineTokensWithinMilliseconds: 800,
  });

  // Find current page based on time
  const currentPage = pages.find(
    (p) => currentTimeMs >= p.startMs && currentTimeMs < p.startMs + p.durationMs
  );

  if (!currentPage) return null;

  return (
    <div style={{
      position: "absolute",
      bottom: "15%",
      left: 0,
      right: 0,
      display: "flex",
      justifyContent: "center",
      padding: "0 40px",
    }}>
      <div style={{
        fontSize: 64,
        fontWeight: 800,
        textAlign: "center",
        textShadow: "2px 2px 8px rgba(0,0,0,0.8)",
        color: "white",
      }}>
        {currentPage.tokens.map((token, i) => {
          const isActive = currentTimeMs >= token.fromMs && currentTimeMs < token.toMs;
          return (
            <span key={i} style={{
              color: isActive ? "#FFD700" : "white",
              transition: "color 0.1s",
            }}>
              {token.text}
            </span>
          );
        })}
      </div>
    </div>
  );
};
```

### 6. Customize Appearance

Offer the user these customization options:

- **Position**: top (10%), center (50%), bottom (15%)
- **Font size**: Small (40px), Medium (56px), Large (72px)
- **Highlight color**: Yellow (#FFD700), Cyan (#00FFFF), Green (#00FF88), custom
- **Background**: None, semi-transparent box, blur
- **Font**: Inter, Poppins, or whatever the project uses
- **Animation**: Pop-in, fade-in, slide-up for each word group

### 7. Wire into Composition

Add the Captions component as an overlay layer on top of everything:

```tsx
// In the main composition, as the LAST visual layer (on top):
<Captions captions={parsedCaptions} />
```

### 8. Preview & Adjust

Tell the user to check captions in the Remotion preview. Common adjustments:
- Text too small/large on mobile? → Adjust font size
- Words moving too fast? → Increase `combineTokensWithinMilliseconds`
- Wrong timing? → Check audio/caption sync
- Overlapping with visuals? → Change position (top vs bottom)
