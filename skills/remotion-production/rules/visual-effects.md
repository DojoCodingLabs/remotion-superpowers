# Visual Effects — Cinematic Looks

## Overview

Remotion ships built-in effects (`@remotion/effects`) that you apply through the `effects` prop of `<Video>` (from `@remotion/media`), `<Img>`, `<CanvasImage>`, `<Solid>` and `<HtmlInCanvas>`. Prefer them over CSS approximations. This file maps cinematic requests to the official files, then adds the two recipes official doesn't cover: letterbox bars and a deterministic glitch.

## Use the official effects

| Request | Use | Official file (`remotion-markup`) |
|---|---|---|
| Light leak, film burn between scenes | `lightLeak()` on a `<Solid>`, usually inside `<TransitionSeries.Overlay>`. Needs Remotion 4.0.500+ | `light-leaks.md`, `transitions.md` |
| Vignette | `vignette()` on the footage or image itself | `effects.md` |
| Film grain, noise, VHS lines | `noise()`, `whiteNoise()`, `scanlines()` | `effects.md` |
| Warm/cool tint, duotone | `tint()`, `duotone()`, or `temperature` in `colorCorrection()` | `effects.md`, `color-correction.md` |
| Color grade, exposure, contrast, `.cube` LUT | `colorCorrection()`, `levels()`, `curves()`, `lut()` | `color-correction.md` |
| Glow, blur, chromatic aberration, TV static | `glow()`, `blur()`, `chromaticAberration()`, `tvSignalOff()` | `effects.md` |
| Lottie (confetti, icons, stickers) | `<Lottie>` from `@remotion/lottie`, JSON fetched inside `delayRender()` and typed as `LottieAnimationData` | `lottie.md` |
| Effect on a group of HTML elements | Wrap the group in `<HtmlInCanvas>` and put `effects` on the wrapper | `html-in-canvas.md` |

Read `effects.md` for each effect's import path and parameters before writing it. Most effects use WebGL2, so renders need `Config.setChromiumOpenGlRenderer("angle")` in `remotion.config.ts`.

**Where to find Lottie animations:** LottieFiles.com (thousands of free animations), or export from After Effects with the Bodymovin plugin. Save the JSON to `public/lottie/<name>.json` and fetch it with `staticFile("lottie/<name>.json")`.

## Letterbox (cinematic bars)

Crops the frame to a wider aspect ratio with black bars that slide in. Bar height comes from the composition size, so it stays right at any resolution.

```tsx
import { AbsoluteFill, Easing, Interactive, interpolate, useCurrentFrame, useVideoConfig } from "remotion";

// ratio: 2.39 = anamorphic "scope", 2.0 = univisium, 1.85 = flat
export const Letterbox: React.FC<{ ratio?: number }> = ({ ratio = 2.39 }) => {
  const frame = useCurrentFrame();
  const { fps, width, height } = useVideoConfig();
  const bar = Math.max(0, Math.round((height - width / ratio) / 2)); // 138px at 1920x1080

  return (
    <AbsoluteFill style={{ pointerEvents: "none" }}>
      <Interactive.Div
        name="Letterbox top"
        style={{
          position: "absolute", top: 0, left: 0, right: 0, backgroundColor: "black",
          height: interpolate(frame, [0, 0.6 * fps], [0, bar], {
            extrapolateLeft: "clamp", extrapolateRight: "clamp",
            easing: Easing.bezier(0.16, 1, 0.3, 1),
          }),
        }}
      />
      <Interactive.Div
        name="Letterbox bottom"
        style={{
          position: "absolute", bottom: 0, left: 0, right: 0, backgroundColor: "black",
          height: interpolate(frame, [0, 0.6 * fps], [0, bar], {
            extrapolateLeft: "clamp", extrapolateRight: "clamp",
            easing: Easing.bezier(0.16, 1, 0.3, 1),
          }),
        }}
      />
    </AbsoluteFill>
  );
};
```

- Put it last in the scene so it sits above footage and titles. Keep titles inside the visible band.
- Skip it on vertical (9:16) video: the bars would eat most of the frame (`bar` clamps to 0 when the ratio is narrower than the frame).

## Glitch (deterministic)

Short bursts of offset colour lines. Every random value comes from `random(seed)` in `remotion`, seeded with the frame, so each frame looks identical in Studio and in every render thread. Never use JavaScript's unseeded random generator in a component: parallel render threads get different values and the output flickers.

```tsx
import { AbsoluteFill, random, useCurrentFrame } from "remotion";

// Glitches for `length` frames at the end of every `every`-frame cycle (default: 5 frames every 4 s at 30 fps)
export const GlitchLines: React.FC<{ every?: number; length?: number; lines?: number }> = ({
  every = 120,
  length = 5,
  lines = 3,
}) => {
  const frame = useCurrentFrame();
  if (frame % every < every - length) return null;

  return (
    <AbsoluteFill style={{ pointerEvents: "none" }}>
      {Array.from({ length: lines }, (_, i) => (
        <div
          key={i}
          style={{
            position: "absolute", left: 0, right: 0,
            top: `${random(`glitch-top-${frame}-${i}`) * 100}%`,
            height: 2 + Math.round(random(`glitch-h-${frame}-${i}`) * 6),
            backgroundColor: i % 2 === 0 ? "cyan" : "magenta",
            opacity: 0.8,
            translate: `${random(`glitch-x-${frame}-${i}`) * 20 - 10}px 0px`,
          }}
        />
      ))}
    </AbsoluteFill>
  );
};
```

For a glitch on the footage itself, add `chromaticAberration()` or `tvSignalOff()` to the `<Video>`'s `effects` only during the same burst frames (see `effects.md`).

## Tips

- **Layer overlays on top** with `<AbsoluteFill>` and `pointerEvents: "none"`.
- **Keep it subtle.** Effects should enhance, not distract.
- **Performance.** WebGL effects, light leaks and Lottie slow renders; use them sparingly on long videos.
- **Consistent grade.** Apply the same `colorCorrection()` or `lut()` to every clip for cohesion.
