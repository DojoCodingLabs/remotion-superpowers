# Production Pipeline — End-to-End Workflow

## Overview

The full pipeline from user prompt to rendered MP4. Follow this order — each step builds on the previous.

## Step 1: Concept Breakdown

When the user describes a video, break it down into:

- **Duration** — How long is the video? (default: 30 seconds if not specified)
- **Scenes** — List of visual scenes with approximate timestamps
- **Script** — Narration text (if voiceover is needed)
- **Audio needs** — Music genre/mood, sound effects, voiceover style
- **Visual style** — Color scheme, typography, animation style
- **Assets needed** — Stock footage queries, images to generate, existing footage to analyze

Present this breakdown to the user for approval before proceeding.

## Step 2: Generate Voiceover (if needed)

Voiceover drives the timing of everything else. Generate it first.

```
Use remotion-media's generate_tts tool:
- text: the narration script
- voice: choose appropriate voice (default: "Eric" for male, "Rachel" for female)
- project_path: path to the Remotion project root
```

The tool saves the audio to `public/` and returns the file path and duration.

**Record the duration** — this determines the composition length.

## Step 3: Generate Music

```
Use remotion-media's generate_music tool:
- prompt: describe the mood/genre (e.g., "upbeat corporate background music, no vocals")
- duration: match or exceed the voiceover duration
- project_path: path to the Remotion project root
```

Music should be slightly longer than the video — it can be trimmed in the composition.

## Step 4: Generate Sound Effects (if needed)

```
Use remotion-media's generate_sfx tool:
- text: describe the sound (e.g., "whoosh transition sound", "notification chime")
- duration_seconds: how long the effect should be
- project_path: path to the Remotion project root
```

## Step 5: Source Visual Assets

### Stock Footage (Pexels)
For each scene that needs stock footage:
```
Use Pexels searchVideos tool:
- query: descriptive keywords (e.g., "drone footage city skyline sunset")
- orientation: "landscape" for standard video
- size: "large"
```

Download selected videos using curl to `public/footage/`:
```bash
curl -o public/footage/scene1.mp4 "VIDEO_URL"
```

### Existing Footage Analysis (TwelveLabs)
If the user has video files in the project:
```
Use TwelveLabs to:
1. Create an index for the video
2. Search for specific moments
3. Get timestamps for relevant scenes
```

### Generated Images
```
Use remotion-media's generate_image tool:
- prompt: describe the image
- project_path: path to the Remotion project root
```

## Step 6: Create the Remotion Composition

Now write the React code. Use the Remotion best practices skill for component patterns.

### Set up the composition in `src/Root.tsx`:
```tsx
import { Composition } from "remotion";
import { MyVideo } from "./MyVideo";

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="MyVideo"
      component={MyVideo}
      durationInFrames={VOICEOVER_DURATION_SECONDS * 30}
      fps={30}
      width={1920}
      height={1080}
    />
  );
};
```

### Layer the composition:
1. **Background layer** — Stock footage or solid color
2. **Visual elements** — Text, images, animations
3. **Voiceover layer** — `<Audio src={staticFile("voiceover.mp3")} />`
4. **Music layer** — `<Audio src={staticFile("music.mp3")} volume={0.3} />`
5. **SFX layer** — `<Audio>` components at specific frames

## Step 7: Preview

```bash
npm run dev
```

Open http://localhost:3000 to preview. Check:
- Audio sync with visuals
- Timing of scene transitions
- Text readability
- Overall feel

## Step 8: Iterate

Make adjustments based on preview:
- Adjust animation timing
- Change audio volumes
- Tweak transitions
- Fix text positioning

## Step 9: Render

```bash
npx remotion render MyVideo out/video.mp4
```

Or with custom settings:
```bash
npx remotion render MyVideo out/video.mp4 --codec h264 --crf 18
```

## File Organization

```
project/
├── public/
│   ├── audio/
│   │   ├── voiceover.mp3
│   │   ├── music.mp3
│   │   └── sfx-whoosh.mp3
│   ├── footage/
│   │   ├── scene1.mp4
│   │   └── scene2.mp4
│   └── images/
│       ├── hero.png
│       └── logo.png
├── src/
│   ├── Root.tsx
│   ├── MyVideo.tsx
│   ├── scenes/
│   │   ├── Intro.tsx
│   │   ├── Scene1.tsx
│   │   └── Outro.tsx
│   └── components/
│       ├── AnimatedText.tsx
│       └── AudioLayer.tsx
└── out/
    └── video.mp4
```
