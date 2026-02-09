# Audio Integration in Remotion

## The `<Audio>` Component

Always use Remotion's `<Audio>` component. Never use HTML `<audio>` tags.

```tsx
import { Audio, staticFile } from "remotion";

// Basic usage
<Audio src={staticFile("audio/voiceover.mp3")} />

// With volume control (0 to 1)
<Audio src={staticFile("audio/music.mp3")} volume={0.3} />

// Starting at a specific frame
<Audio src={staticFile("audio/sfx-whoosh.mp3")} startFrom={0} />
```

## Layering Multiple Audio Tracks

Use `<Sequence>` to layer and time audio tracks:

```tsx
import { Audio, Sequence, staticFile, useVideoConfig } from "remotion";

export const AudioLayer: React.FC = () => {
  const { fps } = useVideoConfig();
  
  return (
    <>
      {/* Background music — plays from the start, lower volume */}
      <Audio src={staticFile("audio/music.mp3")} volume={0.2} />
      
      {/* Voiceover — plays from the start, full volume */}
      <Audio src={staticFile("audio/voiceover.mp3")} volume={1} />
      
      {/* Sound effect at 3 seconds */}
      <Sequence from={3 * fps}>
        <Audio src={staticFile("audio/sfx-whoosh.mp3")} volume={0.8} />
      </Sequence>
      
      {/* Sound effect at 10 seconds */}
      <Sequence from={10 * fps}>
        <Audio src={staticFile("audio/sfx-chime.mp3")} volume={0.6} />
      </Sequence>
    </>
  );
};
```

## Dynamic Volume (Ducking)

Lower music volume when voiceover is playing:

```tsx
import { Audio, interpolate, useCurrentFrame, useVideoConfig } from "remotion";

export const MusicWithDucking: React.FC<{
  voiceoverStartFrame: number;
  voiceoverEndFrame: number;
}> = ({ voiceoverStartFrame, voiceoverEndFrame }) => {
  const frame = useCurrentFrame();
  
  // Duck music to 10% during voiceover, 40% otherwise
  const musicVolume = interpolate(
    frame,
    [
      voiceoverStartFrame - 15, // Fade down over 0.5s
      voiceoverStartFrame,
      voiceoverEndFrame,
      voiceoverEndFrame + 15, // Fade up over 0.5s
    ],
    [0.4, 0.1, 0.1, 0.4],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
  );
  
  return <Audio src={staticFile("audio/music.mp3")} volume={musicVolume} />;
};
```

## Getting Audio Duration

After generating audio with remotion-media, you get the duration in seconds. Use it to set composition length:

```tsx
// If voiceover is 25.3 seconds and fps is 30:
const durationInFrames = Math.ceil(25.3 * 30); // = 759 frames
```

Use Remotion's `getAudioDurationInSeconds` for existing files:

```tsx
import { getAudioDurationInSeconds } from "@remotion/media-utils";

// In calculateMetadata or a data-fetching context:
const duration = await getAudioDurationInSeconds(staticFile("audio/voiceover.mp3"));
const durationInFrames = Math.ceil(duration * fps);
```

## File Naming Conventions

Save generated audio to `public/audio/` with descriptive names:
- `public/audio/voiceover.mp3` — Main narration
- `public/audio/music.mp3` — Background music
- `public/audio/sfx-whoosh.mp3` — Transition sound
- `public/audio/sfx-chime.mp3` — Notification sound

## Common Patterns

### Fade-in/Fade-out Music
```tsx
const frame = useCurrentFrame();
const { durationInFrames, fps } = useVideoConfig();

const musicVolume = interpolate(
  frame,
  [0, 1 * fps, durationInFrames - 2 * fps, durationInFrames],
  [0, 0.3, 0.3, 0],
  { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
);

<Audio src={staticFile("audio/music.mp3")} volume={musicVolume} />
```

### Trim Audio (play only a portion)
```tsx
// Play from second 5 to second 15 of the audio file
<Sequence from={0} durationInFrames={10 * fps}>
  <Audio
    src={staticFile("audio/long-track.mp3")}
    startFrom={5 * fps}
  />
</Sequence>
```
