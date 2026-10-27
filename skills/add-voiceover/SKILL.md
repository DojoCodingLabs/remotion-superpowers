---
name: add-voiceover
description: Generate a voiceover narration and add it to your Remotion project. Provide a script or describe what the narration should say, and this will generate TTS audio and wire it into your composition.
---

# Add Voiceover — Generate & Integrate Narration

You are helping the user add a voiceover narration to their Remotion project.

**Load the `remotion-production` skill** for the `voiceover-sync` and `audio-integration` rules.

## Workflow

### 0. Preview First

If Studio isn't running yet, start it now with `npx remotion studio` (or `--no-open` with an in-app browser, then open the URL it prints) and keep it open, following the official `remotion-best-practices` skill.

### 1. Get the Script

If the user hasn't provided a script:
- Ask what the video is about
- Ask about tone (professional, casual, energetic, calm)
- Write the narration script, **split into one line or paragraph per scene**
- Present for approval

### 2. Choose Voice

Available voices (via remotion-media generate_speech):
- **Eric** — Warm, professional male (default)
- **Rachel** — Clear, engaging female
- **Aria** — Energetic female
- **Roger** — Deep, authoritative male
- **Sarah** — Friendly, conversational female
- **Laura** — Calm, soothing female
- **Charlie** — Casual, youthful male

14 more are listed in the `voiceover-sync` rule. For voice cloning or custom voices, use the dedicated ElevenLabs MCP (requires `ELEVENLABS_API_KEY`; see the `elevenlabs-advanced` rule).

Use `generate_speech`, not a script calling the ElevenLabs API, and don't ask for an ElevenLabs key for the built-in voices.

### 3. Generate TTS, One File per Scene

```
Use remotion-media generate_speech, once per scene:
- text: [that scene's approved line]
- output_name: vo-scene1, vo-scene2, ...
- voice: [chosen voice, the same for every scene]
```
Files land in `public/` of the directory your agent was launched from, so start your agent (Claude Code, Codex, Gemini CLI…) from the Remotion project root.

The tool returns the **file path only**, not a duration.

### 4. Size the Scenes with calculateMetadata

Measure each `vo-sceneN.mp3` in `calculateMetadata` with Mediabunny and pass the per-scene frame counts (`Math.ceil(seconds * fps)`) as props, as the `voiceover-sync` rule shows. The composition length then follows the audio, and regenerating a line updates the timing in Studio.

### 5. Wire into Composition

Place each scene's file with `<Audio>` from `@remotion/media` inside that scene (install with `npx remotion add @remotion/media`), following the official `remotion-markup` skill (audio.md):

```tsx
import { Audio } from "@remotion/media";
import { staticFile } from "remotion";

// Inside scene 1:
<Audio src={staticFile("vo-scene1.mp3")} volume={1} />
```

### 6. Captions (optional)

Offer captions. Word-level captions follow the official `remotion-captions` skill, with TikTok-style presets from the `captions-workflow` rule. If the user only wants an `.srt` file, use:

```
Use remotion-media generate_subtitles:
- input_file: [voiceover filename inside public/, e.g. vo-scene1.mp3]
```

### 7. Duck Background Music (if present)

If the project already has background music, lower its volume during voiceover. See `audio-integration` rule for the ducking pattern.

### 8. Review in Studio

Ask the user to play it in the open Studio. Don't render unless they ask for an MP4.
