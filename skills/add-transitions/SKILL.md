---
name: add-transitions
description: Add professional scene transitions to your Remotion video. Choose from fade, slide, wipe, flip, clock-wipe and more — with spring physics or linear timing.
---

# Add Transitions — Scene Transition Wizard

You are helping the user add professional transitions between scenes in their Remotion composition using `@remotion/transitions`.

## Workflow

### 1. Install Transitions Package

```bash
npx remotion add @remotion/transitions
```

### 2. Audit Current Scenes

Look at the current composition and identify where transitions should go:

```bash
# Find scene components
grep -r "Sequence" src/ --include="*.tsx" --include="*.ts" -l
```

List the scenes and ask where the user wants transitions.

### 3. Choose Transition Types

Available transitions from `@remotion/transitions`:

| Transition | Effect | Best For |
|---|---|---|
| `fade` | Cross-dissolve between scenes | Universal, subtle |
| `slide` | Scene slides in from a direction | Energetic, modern |
| `wipe` | New scene wipes over old | Dramatic, reveals |
| `flip` | 3D card flip | Playful, eye-catching |
| `clockWipe` | Clock-hand reveal | Creative, unique |

**Slide directions:** `from-left`, `from-right`, `from-top`, `from-bottom`

### 4. Choose Timing

| Timing | Feel | Code |
|---|---|---|
| Linear | Constant speed, mechanical | `linearTiming({ durationInFrames: 20 })` |
| Spring | Organic, natural bounce | `springTiming({ config: { damping: 200 }, durationInFrames: 25 })` |

**Recommended:** Spring timing for most transitions — feels more natural.

### 5. Refactor to TransitionSeries

Convert from `<Sequence>` to `<TransitionSeries>`:

**Before (hard cuts):**
```tsx
<Sequence from={0} durationInFrames={90}>
  <SceneA />
</Sequence>
<Sequence from={90} durationInFrames={90}>
  <SceneB />
</Sequence>
<Sequence from={180} durationInFrames={90}>
  <SceneC />
</Sequence>
```

**After (smooth transitions):**
```tsx
import { TransitionSeries, linearTiming, springTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";

<TransitionSeries>
  <TransitionSeries.Sequence durationInFrames={90}>
    <SceneA />
  </TransitionSeries.Sequence>

  <TransitionSeries.Transition
    presentation={fade()}
    timing={springTiming({ config: { damping: 200 }, durationInFrames: 20 })}
  />

  <TransitionSeries.Sequence durationInFrames={90}>
    <SceneB />
  </TransitionSeries.Sequence>

  <TransitionSeries.Transition
    presentation={slide({ direction: "from-right" })}
    timing={linearTiming({ durationInFrames: 15 })}
  />

  <TransitionSeries.Sequence durationInFrames={90}>
    <SceneC />
  </TransitionSeries.Sequence>
</TransitionSeries>
```

### 6. Adjust Total Duration

**Important:** Transitions OVERLAP adjacent scenes, so the total duration shrinks:

```
Total = Sum of all sequence durations - Sum of all transition durations

Example: 3 scenes × 90 frames + 2 transitions × 20 frames
Total = 270 - 40 = 230 frames
```

Update the `durationInFrames` in the `<Composition>` registration accordingly.

### 7. Common Patterns

**All fade (cinematic):**
```tsx
// Same transition everywhere — clean and professional
const defaultTransition = (
  <TransitionSeries.Transition
    presentation={fade()}
    timing={springTiming({ config: { damping: 200 }, durationInFrames: 20 })}
  />
);
```

**Slide carousel (social media):**
```tsx
// Each scene slides in from the right — like swiping
presentation={slide({ direction: "from-right" })}
```

**Mixed (dynamic):**
```tsx
// Fade for intro/outro, slide for body scenes, wipe for reveals
// Mix transitions to match the energy of each cut
```

### 8. Preview

```bash
npm run dev
```

Check transitions in the Remotion preview. Pay attention to:
- Transition speed — too fast feels jarring, too slow feels sluggish
- Direction — slides should follow the visual flow
- Consistency — don't use too many different transitions (2-3 types max)

Adjust `durationInFrames` and `damping` until it feels right.
