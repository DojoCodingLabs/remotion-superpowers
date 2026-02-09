# Data Visualization — Animated Charts in Remotion

## Overview

Create animated bar charts, pie charts, line charts, and dashboards in Remotion. All animations must be driven by `useCurrentFrame()` — never use third-party animation libraries (they cause flickering during rendering).

## General Rules

1. **Drive all animations from `useCurrentFrame()`** — No D3 transitions, no CSS animations
2. **Use `spring()` for organic motion** — Stagger bar entries with delays
3. **Use `interpolate()` for linear progress** — Line chart drawing, percentage fills
4. **Disable third-party animations** — They break frame-by-frame rendering

## Bar Chart

```tsx
const STAGGER_DELAY = 5; // frames between each bar
const frame = useCurrentFrame();
const { fps } = useVideoConfig();

const data = [
  { label: "Jan", value: 120 },
  { label: "Feb", value: 180 },
  { label: "Mar", value: 95 },
  { label: "Apr", value: 210 },
];

const maxValue = Math.max(...data.map((d) => d.value));

return (
  <div style={{ display: "flex", alignItems: "flex-end", gap: 16, height: 400 }}>
    {data.map((item, i) => {
      const height = spring({
        frame,
        fps,
        delay: i * STAGGER_DELAY,
        config: { damping: 200 },
      });
      return (
        <div key={i} style={{ textAlign: "center", flex: 1 }}>
          <div
            style={{
              height: height * (item.value / maxValue) * 300,
              backgroundColor: "#4a9eff",
              borderRadius: 8,
              minHeight: 4,
            }}
          />
          <div style={{ marginTop: 8, fontSize: 18, color: "white" }}>
            {item.label}
          </div>
        </div>
      );
    })}
  </div>
);
```

## Pie Chart (SVG)

```tsx
const frame = useCurrentFrame();
const { fps } = useVideoConfig();

const data = [
  { label: "Product A", value: 40, color: "#4a9eff" },
  { label: "Product B", value: 30, color: "#ff6b6b" },
  { label: "Product C", value: 30, color: "#51cf66" },
];

const total = data.reduce((sum, d) => sum + d.value, 0);
const progress = spring({ frame, fps, config: { damping: 200 } });
let currentAngle = -Math.PI / 2; // Start from 12 o'clock

return (
  <svg width={400} height={400} viewBox="-1 -1 2 2">
    {data.map((item, i) => {
      const angle = (item.value / total) * 2 * Math.PI * progress;
      const x1 = Math.cos(currentAngle);
      const y1 = Math.sin(currentAngle);
      currentAngle += angle;
      const x2 = Math.cos(currentAngle);
      const y2 = Math.sin(currentAngle);
      const largeArc = angle > Math.PI ? 1 : 0;

      return (
        <path
          key={i}
          d={`M 0 0 L ${x1} ${y1} A 1 1 0 ${largeArc} 1 ${x2} ${y2} Z`}
          fill={item.color}
        />
      );
    })}
  </svg>
);
```

## Line Chart

```tsx
const frame = useCurrentFrame();
const { fps } = useVideoConfig();

const points = [10, 45, 30, 70, 55, 80, 65, 90];
const width = 800;
const height = 300;

// Animate drawing progress
const drawProgress = interpolate(frame, [0, 60], [0, 1], {
  extrapolateRight: "clamp",
});

const totalPoints = Math.floor(drawProgress * points.length);
const pathData = points
  .slice(0, totalPoints + 1)
  .map((y, i) => {
    const x = (i / (points.length - 1)) * width;
    const yPos = height - (y / 100) * height;
    return `${i === 0 ? "M" : "L"} ${x} ${yPos}`;
  })
  .join(" ");

return (
  <svg width={width} height={height}>
    <path d={pathData} fill="none" stroke="#4a9eff" strokeWidth={3} />
  </svg>
);
```

## Counter / Number Animation

```tsx
const frame = useCurrentFrame();
const { fps } = useVideoConfig();

const targetNumber = 1234;
const progress = spring({ frame, fps, config: { damping: 200 } });
const displayNumber = Math.round(targetNumber * progress);

return (
  <div style={{ fontSize: 96, fontWeight: 800, color: "white", fontVariantNumeric: "tabular-nums" }}>
    {displayNumber.toLocaleString()}
  </div>
);
```

## Dashboard Layout

Combine multiple charts in a grid:

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
  <Sequence from={0}><BarChart data={barData} /></Sequence>
  <Sequence from={10}><PieChart data={pieData} /></Sequence>
  <Sequence from={20}><LineChart data={lineData} /></Sequence>
  <Sequence from={30}><CounterCard value={1234} label="Total Users" /></Sequence>
</div>
```

Stagger the appearance of each chart panel for a polished reveal effect.

## Tips

- Use `fontVariantNumeric: "tabular-nums"` for counters (prevents layout shift)
- Use D3 for data transforms (scales, paths) but NOT for animations
- SVG renders well in Remotion — use it for charts
- Keep color palettes consistent — pick 3-5 colors and reuse
