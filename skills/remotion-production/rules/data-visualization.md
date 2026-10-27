# Data Visualization — Animated Charts in Remotion

## Overview

Create animated bar charts, pie charts, line charts, and dashboards in Remotion. All animations must be driven by `useCurrentFrame()` — never use third-party animation libraries (they cause flickering during rendering).

## General Rules

1. **Drive all animations from `useCurrentFrame()`** — No D3 transitions, no CSS `transition`/`animation`, no chart-library animations (disable them)
2. **Inline `interpolate()` in the prop it animates** — `height`, `strokeDashoffset`, text content — with `Easing.spring({ damping: 200 })` for organic motion, as in the official `remotion-markup` skill (timing.md)
3. **Stagger with frame offsets** — Shift each item's input range by `i * STAGGER`
4. **Seconds via `fps`** — Use `0.8 * fps`, not hard-coded frame counts, so charts keep their pace at any frame rate

All snippets assume:

```tsx
import { Easing, interpolate, useCurrentFrame, useVideoConfig } from "remotion";

const frame = useCurrentFrame();
const { fps } = useVideoConfig();
```

## Bar Chart

```tsx
const STAGGER = 5; // frames between each bar
const MAX_BAR = 300; // px

const data = [
  { label: "Jan", value: 120 },
  { label: "Feb", value: 180 },
  { label: "Mar", value: 95 },
  { label: "Apr", value: 210 },
];

const maxValue = Math.max(...data.map((d) => d.value));

return (
  <div style={{ display: "flex", alignItems: "flex-end", gap: 16, height: 400 }}>
    {data.map((item, i) => (
      <div key={item.label} style={{ textAlign: "center", flex: 1 }}>
        <div
          style={{
            height: interpolate(
              frame,
              [i * STAGGER, i * STAGGER + 0.8 * fps],
              [0, (item.value / maxValue) * MAX_BAR],
              { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.spring({ damping: 200 }) },
            ),
            backgroundColor: "#4a9eff",
            borderRadius: 8,
            minHeight: 4,
          }}
        />
        <div style={{ marginTop: 8, fontSize: 18, color: "white" }}>{item.label}</div>
      </div>
    ))}
  </div>
);
```

## Pie Chart (SVG)

```tsx
const data = [
  { label: "Product A", value: 40, color: "#4a9eff" },
  { label: "Product B", value: 30, color: "#ff6b6b" },
  { label: "Product C", value: 30, color: "#51cf66" },
];

const total = data.reduce((sum, d) => sum + d.value, 0);
const progress = interpolate(frame, [0, 1 * fps], [0, 1], {
  extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.spring({ damping: 200 }),
});
let currentAngle = -Math.PI / 2; // Start from 12 o'clock

return (
  <svg width={400} height={400} viewBox="-1 -1 2 2">
    {data.map((item) => {
      const angle = (item.value / total) * 2 * Math.PI * progress;
      const x1 = Math.cos(currentAngle);
      const y1 = Math.sin(currentAngle);
      currentAngle += angle;
      const x2 = Math.cos(currentAngle);
      const y2 = Math.sin(currentAngle);
      const largeArc = angle > Math.PI ? 1 : 0;

      return (
        <path
          key={item.label}
          d={`M 0 0 L ${x1} ${y1} A 1 1 0 ${largeArc} 1 ${x2} ${y2} Z`}
          fill={item.color}
        />
      );
    })}
  </svg>
);
```

The slice geometry depends on the running angle, so `progress` is computed once and shared by every slice. For a single animated slice or donut, `<Pie>` from `@remotion/shapes` also works and accepts `effects` (official `remotion-markup`, effects.md).

## Line Chart

Build the full path once, then reveal it with `pathLength={1}` and an animated `strokeDashoffset`. The line draws smoothly instead of jumping point by point.

```tsx
const points = [10, 45, 30, 70, 55, 80, 65, 90];
const width = 800;
const height = 300;

const pathData = points
  .map((y, i) => {
    const x = (i / (points.length - 1)) * width;
    const yPos = height - (y / 100) * height;
    return `${i === 0 ? "M" : "L"} ${x} ${yPos}`;
  })
  .join(" ");

return (
  <svg width={width} height={height}>
    <path
      d={pathData}
      fill="none"
      stroke="#4a9eff"
      strokeWidth={3}
      pathLength={1}
      strokeDasharray={1}
      strokeDashoffset={interpolate(frame, [0, 2 * fps], [1, 0], {
        extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.bezier(0.16, 1, 0.3, 1),
      })}
    />
  </svg>
);
```

## Counter / Number Animation

```tsx
const targetNumber = 1234;

return (
  <div style={{ fontSize: 96, fontWeight: 800, color: "white", fontVariantNumeric: "tabular-nums" }}>
    {Math.round(
      interpolate(frame, [0, 1.5 * fps], [0, targetNumber], {
        extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.spring({ damping: 200 }),
      }),
    ).toLocaleString("en-US")}
  </div>
);
```

Pass an explicit locale to `toLocaleString()` so the separator doesn't change with the render machine's locale.

## Dashboard Layout

Combine multiple charts in a grid. Use `layout="none"` on each `<Sequence>` so it doesn't add an absolutely positioned wrapper that breaks the grid:

```tsx
<div style={{
  display: "grid",
  gridTemplateColumns: "1fr 1fr",
  gridTemplateRows: "1fr 1fr",
  gap: 24,
  padding: 40,
  width: "100%",
  height: "100%",
}}>
  <Sequence layout="none" name="Bar chart"><BarChart data={barData} /></Sequence>
  <Sequence layout="none" name="Pie chart" from={0.3 * fps}><PieChart data={pieData} /></Sequence>
  <Sequence layout="none" name="Line chart" from={0.6 * fps}><LineChart data={lineData} /></Sequence>
  <Sequence layout="none" name="Users counter" from={1 * fps}><CounterCard value={1234} label="Total Users" /></Sequence>
</div>
```

Stagger the appearance of each chart panel for a polished reveal effect. Each chart's `useCurrentFrame()` starts at 0 when its `<Sequence>` begins. A panel is not rendered before its `from`, so give the grid cells fixed sizes if the layout must not shift.

## Tips

- Use `fontVariantNumeric: "tabular-nums"` for counters (prevents layout shift)
- Use D3 for data transforms (scales, paths) but NOT for animations
- SVG renders well in Remotion — use it for charts
- Keep color palettes consistent — pick 3-5 colors and reuse
- For bar charts driven by audio (spectrum, waveform), follow the official `remotion-markup` skill (audio-visualization.md)
