---
name: create-video
description: Full video production pipeline — from a text prompt to a rendered MP4 with voiceover, music, sound effects, stock footage, and motion graphics. The flagship command of Remotion Superpowers.
---

# Create Video — Full Production Pipeline

You are the Video Director. The user wants to create a complete video. Follow this pipeline step by step.

**IMPORTANT:** Load the `remotion-production` skill for detailed patterns and code examples. Also load the Remotion best practices skill (`remotion-best-practices`) for component-level guidance.

## Pre-flight Check

Before starting, verify:
1. You're in a Remotion project (has `remotion.config.ts`)
2. MCP servers are available — check with `/mcp` if unsure
3. If anything is missing, suggest running `/setup`

## Pipeline

### Phase 1: Concept Breakdown

Ask the user to describe their video (or use their existing description). Then break it down:

```
📋 Video Production Plan

Duration: [X seconds]
Aspect Ratio: [16:9 / 9:16 / 1:1]
Style: [describe visual style]

Scenes:
1. [0:00-0:05] Intro — [description]
2. [0:05-0:15] Main content — [description]  
3. [0:15-0:25] Supporting content — [description]
4. [0:25-0:30] Outro/CTA — [description]

Audio Plan:
- Voiceover: [yes/no] — [voice style]
- Music: [genre/mood description]
- Sound Effects: [list any needed SFX]

Visual Assets Needed:
- Stock footage: [list queries]
- Generated images: [list descriptions]
- Existing footage: [list files to analyze]
```

**Present this plan to the user and get approval before proceeding.**

### Phase 2: Generate Audio Assets

Do this FIRST — audio determines timing.

#### 2a. Voiceover (if needed)
Write the narration script, then generate:
```
Use remotion-media generate_speech:
- text: [full narration script]
- output_name: narration-intro
- voice: [chosen voice name]
```
Files land in `public/` of the directory Claude Code was launched from, so start Claude Code from the Remotion project root.
**Record the returned duration — this sets the video length.**

#### 2b. Background Music
```
Use remotion-media generate_music:
- prompt: [music description, always include "no vocals"]
- output_name: music-background
```

#### 2c. Sound Effects (if needed)
For each SFX:
```
Use remotion-media generate_sound_effect:
- prompt: [sound description]
- output_name: sfx-whoosh
- duration_seconds: [length]
```

### Phase 3: Source Visual Assets

#### 3a. Stock Footage (Pexels)
For each scene needing stock footage:
```
Use Pexels videos_search:
- query: [descriptive keywords]
- orientation: landscape
- size: large
```
Download best matches to `public/footage/`.

#### 3b. Analyze Existing Footage (TwelveLabs)
If user has footage files:
```
Use TwelveLabs to:
- Index the video(s)
- Search for relevant scenes
- Get timestamps for best clips
```

#### 3c. Generate Images (if needed)
```
Use remotion-media generate_image:
- prompt: [image description]
- output_name: image-scene1
```

### Phase 4: Build the Remotion Composition

Now write the React/TypeScript code:

1. **Create scene components** in `src/scenes/` — one per scene
2. **Create the main composition** that sequences all scenes
3. **Add audio layers** — voiceover, music (with fade in/out + ducking), SFX at correct frames
4. **Register the composition** in `src/Root.tsx` with correct duration

Follow Remotion best practices:
- Use `useCurrentFrame()` and `interpolate()` for animations
- Use `<Sequence>` for scene timing
- Use `<Audio>` with `staticFile()` for all audio
- Use `<OffthreadVideo>` for video clips
- Use `spring()` for natural motion

### Phase 5: Preview & Iterate

Start the dev server:
```bash
npm run dev
```

Tell the user to open http://localhost:3000 to preview.

Ask for feedback and make adjustments:
- Timing changes
- Visual tweaks
- Audio volume adjustments
- Text/copy changes

### Phase 6: Render

When the user is satisfied:
```bash
npx remotion render [CompositionId] out/video.mp4
```

Or with quality settings:
```bash
npx remotion render [CompositionId] out/video.mp4 --codec h264 --crf 18
```

## Guidelines

- **Keep visuals simple** — clean text, smooth transitions, not too many moving elements
- **Iterate incrementally** — get basics working, then add polish
- **Test audio sync** — preview after adding each audio layer
- **Use consistent styling** — pick a color palette and font family, stick with them
- **Organize files** — `public/audio/`, `public/footage/`, `public/images/`, `src/scenes/`
