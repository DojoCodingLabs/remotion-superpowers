---
name: create-short
description: Create a short-form vertical video (TikTok, Instagram Reels, YouTube Shorts). Optimized 9:16 pipeline with auto-captions, hook-first structure, and background music mood selection.
---

# Create Short — Vertical Short-Form Video Pipeline

You are creating a short-form vertical video optimized for TikTok, Instagram Reels, or YouTube Shorts.

**Load the `remotion-production` skill** for production patterns, plus `remotion-best-practices` for Remotion-specific code.

## Key Differences from `/create-video`

- **Aspect ratio**: 9:16 (1080x1920) — ALWAYS vertical
- **Duration**: 15–60 seconds max (sweet spot: 30s)
- **Hook first**: First 2-3 seconds must grab attention
- **Captions required**: Always add TikTok-style word-by-word captions
- **Background music**: Always include — with mood tags
- **Pacing**: Fast cuts, 2-5 seconds per scene, no slow moments

## Pipeline

### Phase 1: Concept (Keep It Simple)

Ask the user what the short is about, then structure it:

```
📱 Short Video Plan

Platform: [TikTok / Reels / Shorts]
Duration: [15-60 seconds]
Format: 1080x1920 (9:16 vertical)
FPS: 30

Structure:
  🪝 Hook (0-3s): [attention grabber — question, bold claim, visual shock]
  📖 Body (3-Xs): [main content — 2-4 fast scenes]
  📣 CTA (last 3-5s): [call to action — follow, link, comment]

Voiceover: [yes/no] — [style: energetic, conversational, dramatic]
Music Mood: [upbeat, chill, dramatic, inspiring, dark, funny]
Caption Style: [TikTok bold / karaoke / minimal]
```

### Phase 2: Generate Audio (voiceover drives everything)

#### 2a. Voiceover
Write a TIGHT script — every word must earn its place in a short:
```
Use remotion-media generate_speech:
- text: [short, punchy script — no filler words]
- output_name: voiceover-short
- voice: [energetic voice like Aria or Charlie for shorts]
```
Files land in `public/` of the directory your agent was launched from, so start your agent (Claude Code, Codex, Gemini CLI…) from the Remotion project root.

#### 2b. Background Music
```
Use remotion-media generate_music:
- prompt: "[mood] background music for social media short, energetic, no vocals, [genre]"
- output_name: music-short
```

**Good short music prompts:**
- "upbeat trendy pop beat for TikTok, energetic, no vocals"
- "dark cinematic bass, dramatic tension, no vocals, short form"
- "chill lofi beat for educational content, relaxed, no vocals"

### Phase 3: Source Visuals

Search for VERTICAL footage:
```
Use Pexels videos_search:
- query: [keywords]
- orientation: portrait  ← IMPORTANT: portrait for 9:16
- size: large
```

Or generate images/clips:
```
Use remotion-media generate_image / generate_video_from_text (or generate_video_from_image to animate an image)
```

### Phase 4: Build the Composition

Create the composition with vertical dimensions:

```tsx
<Composition
  id="MyShort"
  component={MyShort}
  durationInFrames={Math.ceil(voiceoverDuration * 30) + 60}
  fps={30}
  width={1080}
  height={1920}
/>
```

**Short-form composition structure:**

```tsx
// Hook — first 3 seconds, grab attention
<Sequence from={0} durationInFrames={3 * fps}>
  <HookScene />
</Sequence>

// Body — main content, fast-paced scenes
<Sequence from={3 * fps} durationInFrames={bodyDuration}>
  <BodyScenes />
</Sequence>

// CTA — last 3-5 seconds
<Sequence from={totalFrames - 4 * fps} durationInFrames={4 * fps}>
  <CTAScene />
</Sequence>

// Audio layers
<Audio src={staticFile("audio/voiceover.mp3")} volume={1} />
<Audio src={staticFile("audio/music.mp3")} volume={musicVolume} />

// Captions — ALWAYS on top
<Captions captions={parsedCaptions} />
```

**Typography for vertical:**
- Title text: 72-96px bold (fills width)
- Body text: 48-64px
- Captions: 56-72px bold with shadow
- Keep text in the center 60% of screen (safe zone for platform UI)

### Phase 5: Add Captions

Captions are MANDATORY for shorts. Use the same workflow as `/add-captions`:

1. Transcribe the voiceover with Whisper
2. Use `createTikTokStyleCaptions()` from `@remotion/captions`
3. Style with bold font, high contrast, animated highlight
4. Position in lower-center (above platform UI controls)

### Phase 6: Preview & Render

```bash
npm run dev
# Preview at 1080x1920 — check on mobile dimensions

npx remotion render MyShort out/short.mp4 --codec h264 --crf 18
```

## Short-Form Best Practices

- **Hook or die** — If the first 2 seconds aren't compelling, viewers scroll away
- **One idea per short** — Don't try to fit everything, pick ONE topic
- **Text on screen** — Reinforce key points with bold text overlays
- **Fast pacing** — Cut every 2-4 seconds, no scene longer than 5s
- **Captions always** — 85% of social media videos are watched without sound
- **End with CTA** — "Follow for more", "Link in bio", "Comment below"
- **Safe zones** — Keep text away from edges (platform UI overlaps)
- **Loop-friendly** — Consider making the end transition into the beginning
