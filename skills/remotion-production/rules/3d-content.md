# 3D Content — Three.js in Remotion

## Overview

Create 3D scenes, models, and animations in Remotion using Three.js and React Three Fiber via `@remotion/three`.

## Setup

```bash
npx remotion add @remotion/three
```

This also installs `@react-three/fiber` and `three` as dependencies.

## Basic Pattern

```tsx
import { ThreeCanvas } from "@remotion/three";
import { useCurrentFrame, useVideoConfig } from "remotion";

export const My3DScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { width, height, fps } = useVideoConfig();

  // All animations MUST be driven by frame, NOT by Three.js internal clock
  const rotation = (frame / fps) * Math.PI * 0.5; // 90° per second

  return (
    <ThreeCanvas width={width} height={height}>
      <ambientLight intensity={0.4} />
      <directionalLight position={[5, 5, 5]} intensity={0.8} />
      <mesh rotation={[0, rotation, 0]}>
        <boxGeometry args={[2, 2, 2]} />
        <meshStandardMaterial color="#4a9eff" />
      </mesh>
    </ThreeCanvas>
  );
};
```

## Critical Rules

1. **`<ThreeCanvas>` MUST have `width` and `height` props** — Use `useVideoConfig()` values
2. **Drive ALL animations from `useCurrentFrame()`** — Never use Three.js `useFrame()` or `Clock`
3. **Disable self-animating shaders/models** — They cause flickering during rendering
4. **Use `<Sequence layout="none">` inside ThreeCanvas** — For timing 3D elements

```tsx
import { Sequence } from "remotion";
import { ThreeCanvas } from "@remotion/three";

<ThreeCanvas width={width} height={height}>
  <Sequence layout="none" from={0} durationInFrames={60}>
    <MyAnimatedMesh />
  </Sequence>
</ThreeCanvas>
```

## Common 3D Patterns

### Rotating product showcase
```tsx
const frame = useCurrentFrame();
const rotation = interpolate(frame, [0, 150], [0, Math.PI * 2]);
<mesh rotation={[0.3, rotation, 0]}>
  <Model url={staticFile("model.glb")} />
</mesh>
```

### Camera orbit
```tsx
const frame = useCurrentFrame();
const angle = interpolate(frame, [0, 300], [0, Math.PI * 2]);
const x = Math.sin(angle) * 5;
const z = Math.cos(angle) * 5;
// Set camera position based on frame
```

### Logo reveal with 3D depth
```tsx
const frame = useCurrentFrame();
const { fps } = useVideoConfig();
const scale = spring({ frame, fps, config: { damping: 200 } });
<mesh scale={[scale, scale, scale]}>
  <Text3D font={staticFile("font.json")} size={1}>
    BRAND
    <meshStandardMaterial color="#ffffff" />
  </Text3D>
</mesh>
```

## Performance Tips

- Keep polygon count reasonable — complex scenes slow down rendering
- Use simple materials (MeshStandardMaterial) over complex shaders
- Avoid post-processing effects that rely on animation loops
- For long renders, consider simpler 3D with 2D overlays on top
