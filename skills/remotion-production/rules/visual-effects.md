# Visual Effects — Light Leaks & Cinematic Effects

## Overview

Add cinematic visual effects to Remotion videos using `@remotion/light-leaks`, Lottie animations, and CSS-based effects.

## Light Leaks

### Setup
```bash
npx remotion add @remotion/light-leaks
```

### Usage
```tsx
import { LightLeak } from "@remotion/light-leaks";
import { useCurrentFrame, useVideoConfig } from "remotion";

export const CinematicScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames, width, height } = useVideoConfig();

  return (
    <div style={{ position: "relative", width, height }}>
      {/* Your scene content */}
      <YourScene />

      {/* Light leak overlay */}
      <div style={{ position: "absolute", top: 0, left: 0, width: "100%", height: "100%", mixBlendMode: "screen" }}>
        <LightLeak
          frame={frame}
          durationInFrames={durationInFrames}
          width={width}
          height={height}
        />
      </div>
    </div>
  );
};
```

**Blend modes for different feels:**
- `screen` — Classic film light leak (bright, warm)
- `overlay` — Subtle color enhancement
- `soft-light` — Very subtle glow
- `color-dodge` — Intense, blown-out highlights

## Lottie Animations

### Setup
```bash
npx remotion add @remotion/lottie
```

### Usage
```tsx
import { Lottie } from "@remotion/lottie";
import { useCurrentFrame } from "remotion";
import animationData from "./confetti.json"; // Lottie JSON file

export const LottieEffect: React.FC = () => {
  const frame = useCurrentFrame();

  return (
    <Lottie
      animationData={animationData}
      playbackRate={1}
      style={{ width: "100%", height: "100%" }}
    />
  );
};
```

**Where to find Lottie animations:**
- LottieFiles.com — thousands of free animations
- Export from After Effects with Bodymovin plugin

## CSS-Based Effects

### Vignette
```tsx
<div style={{
  position: "absolute",
  top: 0, left: 0, right: 0, bottom: 0,
  boxShadow: "inset 0 0 150px rgba(0,0,0,0.8)",
  pointerEvents: "none",
}} />
```

### Film Grain
```tsx
const frame = useCurrentFrame();
// Use a noise pattern that shifts each frame
<div style={{
  position: "absolute",
  top: 0, left: 0, right: 0, bottom: 0,
  backgroundImage: `url(${staticFile("grain.png")})`,
  backgroundPosition: `${frame * 3}px ${frame * 7}px`,
  opacity: 0.06,
  mixBlendMode: "overlay",
  pointerEvents: "none",
}} />
```

### Gradient Overlay
```tsx
// Cinematic top/bottom darkening
<div style={{
  position: "absolute",
  top: 0, left: 0, right: 0, bottom: 0,
  background: "linear-gradient(to bottom, rgba(0,0,0,0.4) 0%, transparent 30%, transparent 70%, rgba(0,0,0,0.4) 100%)",
  pointerEvents: "none",
}} />
```

### Color Tint
```tsx
// Warm cinematic tint
<div style={{
  position: "absolute",
  top: 0, left: 0, right: 0, bottom: 0,
  backgroundColor: "rgba(255, 165, 0, 0.08)",
  mixBlendMode: "overlay",
  pointerEvents: "none",
}} />
```

### Letterbox (cinematic bars)
```tsx
const BAR_HEIGHT = 60; // pixels
<>
  <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: BAR_HEIGHT, backgroundColor: "black" }} />
  <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, height: BAR_HEIGHT, backgroundColor: "black" }} />
</>
```

## Animated Effects

### Zoom Ken Burns (on images)
```tsx
const frame = useCurrentFrame();
const { durationInFrames } = useVideoConfig();
const scale = interpolate(frame, [0, durationInFrames], [1, 1.2]);
const x = interpolate(frame, [0, durationInFrames], [0, -5]);
const y = interpolate(frame, [0, durationInFrames], [0, -3]);

<Img
  src={staticFile("photo.jpg")}
  style={{
    transform: `scale(${scale}) translate(${x}%, ${y}%)`,
    width: "100%",
    height: "100%",
    objectFit: "cover",
  }}
/>
```

### Glitch effect
```tsx
const frame = useCurrentFrame();
const glitchActive = frame % 120 > 115; // glitch for 5 frames every 4 seconds

{glitchActive && (
  <div style={{
    position: "absolute",
    top: `${Math.random() * 50}%`,
    left: 0, right: 0,
    height: 4,
    backgroundColor: "cyan",
    opacity: 0.8,
    transform: `translateX(${Math.random() * 20 - 10}px)`,
  }} />
)}
```

## Tips

- **Layer effects on top** — Use `position: absolute` and `pointerEvents: "none"`
- **Use `mixBlendMode`** — `screen` for light effects, `overlay` for subtle
- **Keep it subtle** — Effects should enhance, not distract
- **Performance** — Light leaks and Lottie can slow renders; use sparingly on long videos
- **Consistent grade** — Apply the same color tint/vignette to all scenes for cohesion
