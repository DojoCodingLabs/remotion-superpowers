# Animation Presets — Reusable Patterns for Remotion

## Overview

Common animation patterns for Remotion videos. All animations use `useCurrentFrame()`, `interpolate()`, and `spring()` — never CSS animations or third-party animation libraries.

## Entrance Animations

### Fade In
```tsx
const frame = useCurrentFrame();
const opacity = interpolate(frame, [0, 20], [0, 1], { extrapolateRight: "clamp" });
<div style={{ opacity }}>{children}</div>
```

### Scale In (pop)
```tsx
const frame = useCurrentFrame();
const { fps } = useVideoConfig();
const scale = spring({ frame, fps, config: { damping: 200 } });
<div style={{ transform: `scale(${scale})` }}>{children}</div>
```

### Slide In from Left
```tsx
const frame = useCurrentFrame();
const { fps } = useVideoConfig();
const translateX = spring({ frame, fps, config: { damping: 200 } });
const x = interpolate(translateX, [0, 1], [-100, 0]);
<div style={{ transform: `translateX(${x}%)` }}>{children}</div>
```

### Slide Up + Fade
```tsx
const frame = useCurrentFrame();
const { fps } = useVideoConfig();
const progress = spring({ frame, fps, config: { damping: 200 } });
const y = interpolate(progress, [0, 1], [40, 0]);
<div style={{ transform: `translateY(${y}px)`, opacity: progress }}>{children}</div>
```

## Exit Animations

### Fade Out
```tsx
const frame = useCurrentFrame();
const { durationInFrames } = useVideoConfig();
const opacity = interpolate(
  frame,
  [durationInFrames - 20, durationInFrames],
  [1, 0],
  { extrapolateLeft: "clamp" }
);
```

### Scale Out
```tsx
const frame = useCurrentFrame();
const { durationInFrames } = useVideoConfig();
const scale = interpolate(
  frame,
  [durationInFrames - 15, durationInFrames],
  [1, 0],
  { extrapolateLeft: "clamp" }
);
```

## Text Animations

### Word-by-word reveal
```tsx
const frame = useCurrentFrame();
const { fps } = useVideoConfig();
const words = text.split(" ");

return (
  <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
    {words.map((word, i) => {
      const delay = i * 5; // 5 frames between each word
      const opacity = spring({ frame, fps, delay, config: { damping: 200 } });
      const y = interpolate(opacity, [0, 1], [20, 0]);
      return (
        <span key={i} style={{ opacity, transform: `translateY(${y}px)` }}>
          {word}
        </span>
      );
    })}
  </div>
);
```

### Typewriter effect
```tsx
const frame = useCurrentFrame();
const charsPerFrame = 0.5; // typing speed
const visibleChars = Math.floor(frame * charsPerFrame);
const displayText = fullText.slice(0, visibleChars);
const showCursor = frame % 30 < 15; // blinking cursor

return (
  <span style={{ fontFamily: "monospace" }}>
    {displayText}
    {showCursor && <span style={{ opacity: 1 }}>|</span>}
  </span>
);
```

### Letter-by-letter stagger
```tsx
const frame = useCurrentFrame();
const { fps } = useVideoConfig();

return (
  <div style={{ display: "flex" }}>
    {text.split("").map((char, i) => {
      const delay = i * 2;
      const progress = spring({ frame, fps, delay, config: { damping: 200 } });
      const y = interpolate(progress, [0, 1], [30, 0]);
      return (
        <span key={i} style={{ opacity: progress, transform: `translateY(${y}px)` }}>
          {char === " " ? "\u00A0" : char}
        </span>
      );
    })}
  </div>
);
```

## Combining Animations

### Entrance + Hold + Exit
```tsx
const frame = useCurrentFrame();
const { durationInFrames } = useVideoConfig();

const enterEnd = 20;
const exitStart = durationInFrames - 20;

const opacity = interpolate(
  frame,
  [0, enterEnd, exitStart, durationInFrames],
  [0, 1, 1, 0],
  { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
);
```

### Staggered group entrance
```tsx
const items = ["Feature 1", "Feature 2", "Feature 3", "Feature 4"];
const STAGGER = 8; // frames between each item

{items.map((item, i) => {
  const delay = i * STAGGER;
  const progress = spring({ frame, fps, delay, config: { damping: 200 } });
  const x = interpolate(progress, [0, 1], [-50, 0]);
  return (
    <div key={i} style={{ opacity: progress, transform: `translateX(${x}px)` }}>
      {item}
    </div>
  );
})}
```

## Motion Patterns

### Subtle float / hover
```tsx
const frame = useCurrentFrame();
const y = Math.sin(frame * 0.05) * 10; // gentle floating
<div style={{ transform: `translateY(${y}px)` }} />
```

### Pulse / breathe
```tsx
const frame = useCurrentFrame();
const scale = 1 + Math.sin(frame * 0.1) * 0.05; // subtle 5% pulse
<div style={{ transform: `scale(${scale})` }} />
```

### Parallax scroll
```tsx
const frame = useCurrentFrame();
const bgY = interpolate(frame, [0, durationInFrames], [0, -200]);
const fgY = interpolate(frame, [0, durationInFrames], [0, -400]);
// Background moves slower than foreground
```

## Tips

- **Spring for entrances** — Natural, organic feel
- **Interpolate for exits** — Predictable, smooth
- **Stagger delay = 5-10 frames** — Feels rhythmic without being slow
- **damping: 200** — Safe default for most springs (no bounce)
- **damping: 100** — Slight bounce, more playful
- **Always clamp** — Use `extrapolateLeft/Right: "clamp"` to prevent overshoot
