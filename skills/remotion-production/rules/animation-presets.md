# Animation Presets — Text and Motion Recipes

## Overview

Text and motion recipes that the official skills don't spell out, written in the official `remotion-markup` style:

- `interpolate()` inline in `style`, so Studio can edit the keyframes
- `scale`, `translate` and `rotate` CSS properties instead of `transform` strings
- `Easing.spring({ damping: 200 })` or `Easing.bezier(...)` as the `easing` option, and `output: "perceptual-scale"` on scale animations
- `fps` from `useVideoConfig()` for every seconds-to-frames value
- No CSS `transition`/`animation`, no third-party animation libraries

For basic fades, slides, pops, exits and multi-keyframe enter-hold-exit curves, follow the official `remotion-markup` skill (timing.md). It covers them with the same primitives.

All snippets assume:

```tsx
import { Easing, Interactive, interpolate, useCurrentFrame, useVideoConfig } from "remotion";

const frame = useCurrentFrame();
const { fps, durationInFrames } = useVideoConfig();
```

## Text Animations

### Word-by-word reveal
```tsx
const STAGGER = 5; // frames between words
const words = text.split(" ");

<Interactive.Div name="Headline" style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
  {words.map((word, i) => (
    <span
      key={i}
      style={{
        opacity: interpolate(frame, [i * STAGGER, i * STAGGER + 0.5 * fps], [0, 1], {
          extrapolateLeft: "clamp", extrapolateRight: "clamp",
          easing: Easing.spring({ damping: 200 }),
        }),
        translate: interpolate(frame, [i * STAGGER, i * STAGGER + 0.5 * fps], ["0px 20px", "0px 0px"], {
          extrapolateLeft: "clamp", extrapolateRight: "clamp",
          easing: Easing.spring({ damping: 200 }),
        }),
      }}
    >
      {word}
    </span>
  ))}
</Interactive.Div>
```

The same pattern makes a **staggered list** (feature bullets, logos): map the items instead of words, use `STAGGER = 8` and a horizontal offset such as `["-50px 0px", "0px 0px"]`.

### Letter-by-letter stagger
```tsx
const STAGGER = 2; // frames between letters

<Interactive.Div name="Title" style={{ display: "flex" }}>
  {text.split("").map((char, i) => (
    <span
      key={i}
      style={{
        opacity: interpolate(frame, [i * STAGGER, i * STAGGER + 0.5 * fps], [0, 1], {
          extrapolateLeft: "clamp", extrapolateRight: "clamp",
          easing: Easing.spring({ damping: 200 }),
        }),
        translate: interpolate(frame, [i * STAGGER, i * STAGGER + 0.5 * fps], ["0px 30px", "0px 0px"], {
          extrapolateLeft: "clamp", extrapolateRight: "clamp",
          easing: Easing.spring({ damping: 200 }),
        }),
      }}
    >
      {char === " " ? " " : char}
    </span>
  ))}
</Interactive.Div>
```

For Arabic, Persian, Urdu or Hebrew, animate by word instead: splitting letters breaks the joined script (official `remotion-markup`, arabic-text.md).

### Typewriter
```tsx
const CHARS_PER_SECOND = 15;
const visibleChars = Math.floor(
  interpolate(frame, [0, (fullText.length / CHARS_PER_SECOND) * fps], [0, fullText.length], {
    extrapolateLeft: "clamp", extrapolateRight: "clamp",
  }),
);

<Interactive.Div name="Typed text" style={{ fontFamily: "monospace" }}>
  {fullText.slice(0, visibleChars)}
  <span style={{ opacity: frame % fps < fps / 2 ? 1 : 0 }}>|</span>
</Interactive.Div>
```

Slice the string; don't animate per-character opacity, which reflows the line as characters appear. The cursor blinks once per second at any frame rate. Pair it with a key-click SFX (see `sound-effects.md`).

## Motion Patterns

Loops with no start or end use `Math.sin` on the frame. The value is still a pure function of the frame, so it renders deterministically.

### Subtle float / hover
```tsx
<Interactive.Div
  name="Floating card"
  style={{ translate: `0px ${Math.sin((frame / fps) * 1.5) * 10}px` }} // 10px swing, ~4 s period
/>
```

### Pulse / breathe
```tsx
<Interactive.Div
  name="Pulsing badge"
  style={{ scale: 1 + Math.sin((frame / fps) * 3) * 0.05 }} // 5% pulse, ~2 s period
/>
```

### Parallax
Layers move the same direction at different speeds; the background moves least.

```tsx
<Interactive.Div
  name="Background"
  style={{
    translate: interpolate(frame, [0, durationInFrames], ["0px 0px", "0px -200px"]),
  }}
/>
<Interactive.Div
  name="Foreground"
  style={{
    translate: interpolate(frame, [0, durationInFrames], ["0px 0px", "0px -400px"]),
  }}
/>
```

Make each layer taller than the frame by at least its travel distance so no edge shows.

## Tips

- **Stagger 5-10 frames** feels rhythmic without being slow; 2 frames for letters.
- **`Easing.spring({ damping: 200 })`** is a safe no-bounce default; lower damping (for example 100) adds a slight, playful bounce.
- **Always clamp** with `extrapolateLeft`/`extrapolateRight: "clamp"` so values don't overshoot.
- **`spring()` still works** if a project already uses it, but new code follows the `interpolate` + `Easing.spring()` form above so Studio can edit it.
