# Captions Workflow — Animated Subtitles for Remotion

## Overview

Add TikTok-style word-by-word animated captions to any Remotion video. Captions are essential for social media — 85% of videos are watched without sound.

## Package Setup

```bash
npx remotion add @remotion/captions
```

## Transcription Sources

### Via remotion-media MCP (Whisper)
```
Use remotion-media generate_subtitles:
- input: path/to/audio.mp3
- project_path: /path/to/project
```
Returns an SRT file. Parse it into Caption objects.

### Via @remotion/install-whisper-cpp (local)
```typescript
import { installWhisperCpp, transcribe } from "@remotion/install-whisper-cpp";
import { toCaptions } from "@remotion/install-whisper-cpp";

const { transcription } = await transcribe({
  inputPath: "public/audio/voiceover.mp3",
  whisperPath: ".whisper",
  model: "medium.en",
  tokenLevelTimestamps: true,
});

const captions = toCaptions({ transcription });
```

### Via OpenAI Whisper API
```typescript
import { openAiWhisperApiToCaptions } from "@remotion/openai-whisper";

const response = await openai.audio.transcriptions.create({
  file: fs.createReadStream("public/audio/voiceover.mp3"),
  model: "whisper-1",
  response_format: "verbose_json",
  timestamp_granularities: ["word"],
});

const { captions } = openAiWhisperApiToCaptions({ transcription: response });
```

## Creating TikTok-Style Captions

```typescript
import { createTikTokStyleCaptions } from "@remotion/captions";

const { pages } = createTikTokStyleCaptions({
  captions,                             // Array of Caption objects
  combineTokensWithinMilliseconds: 800, // Group words within 800ms
});
```

Each `page` contains:
- `startMs` — When this group of words appears
- `durationMs` — How long it stays
- `tokens` — Individual words with `fromMs`, `toMs`, `text`

## Caption Component Pattern

```tsx
import { useCurrentFrame, useVideoConfig, spring } from "remotion";

export const TikTokCaptions: React.FC<{ pages: Page[] }> = ({ pages }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const currentTimeMs = (frame / fps) * 1000;

  const currentPage = pages.find(
    (p) => currentTimeMs >= p.startMs && currentTimeMs < p.startMs + p.durationMs
  );

  if (!currentPage) return null;

  // Pop-in animation for each new page
  const pageFrame = Math.round(((currentTimeMs - currentPage.startMs) / 1000) * fps);
  const scale = spring({ frame: pageFrame, fps, config: { damping: 200, mass: 0.5 } });

  return (
    <div style={{
      position: "absolute",
      bottom: "15%",
      left: 0, right: 0,
      display: "flex",
      justifyContent: "center",
      padding: "0 60px",
      transform: `scale(${scale})`,
    }}>
      <div style={{
        fontSize: 64,
        fontWeight: 800,
        fontFamily: "'Inter', sans-serif",
        textAlign: "center",
        lineHeight: 1.2,
      }}>
        {currentPage.tokens.map((token, i) => {
          const isActive = currentTimeMs >= token.fromMs && currentTimeMs < token.toMs;
          return (
            <span key={i} style={{
              color: isActive ? "#FFD700" : "white",
              textShadow: "2px 2px 8px rgba(0,0,0,0.9)",
              WebkitTextStroke: isActive ? "1px rgba(0,0,0,0.3)" : "none",
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

## Style Variations

### YouTube Style (bottom bar)
```tsx
// Position at bottom with semi-transparent background
style={{
  position: "absolute",
  bottom: 40,
  left: 0, right: 0,
  backgroundColor: "rgba(0,0,0,0.7)",
  padding: "12px 24px",
  fontSize: 32,
  textAlign: "center",
}}
```

### Karaoke Style (full sentence, word highlights)
```tsx
// Show full sentence, highlight current word
{sentence.words.map((word, i) => (
  <span style={{
    backgroundColor: isCurrentWord ? "#FFD700" : "transparent",
    color: isCurrentWord ? "#000" : "#FFF",
    borderRadius: 4,
    padding: "2px 4px",
  }}>
    {word.text}
  </span>
))}
```

## Positioning for Platforms

- **TikTok/Reels**: Bottom 15-25% (above UI controls)
- **YouTube**: Bottom 5-10% (standard subtitle area)
- **YouTube Shorts**: Same as TikTok
- **General**: Center of screen for maximum impact

## Key Rules

1. **Always use `@remotion/captions`** — Don't build caption timing from scratch
2. **Font size matters** — At least 48px for mobile, 64px+ for TikTok style
3. **High contrast** — White text with dark shadow, or colored highlight on dark
4. **Test on mobile** — Captions must be readable on phone screens
5. **Don't overlap UI** — Leave margins for platform controls (like/share/comment buttons)
